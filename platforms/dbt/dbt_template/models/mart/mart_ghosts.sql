-- Ghost Content Score Model
-- Identifies content gaps: high user demand but low/no supply quality
-- Grain: 1 row per search_query
--
-- Ghost Score = demand_volume × (1 - supply_quality) × frustration_bonus
--   demand_volume   = unique users who searched this term
--   supply_quality  = normalized avg IMDB of matching titles (0 = no match = full ghost)
--   frustration_bonus = 1.5× if >70% of search sessions had no clickout

{{ config(materialized='table') }}

-- Step 1: aggregate demand per query term (cheap group-by on search events only)
with demand as (
    select
        search_query,
        count(distinct user_id)    as searcher_count,
        count(distinct session_id) as search_session_count,

        -- frustration: what % of search sessions never led to a clickout
        1.0 - (
            count(distinct case when is_clickout then session_id end)::float
            / nullif(count(distinct session_id), 0)
        ) as no_clickout_rate,

        -- top provider clicked from search sessions (mode)
        mode(case when is_clickout then provider_id end) as top_provider_id

    from {{ ref('fct_events') }}
    where is_search_session = true
      and search_query is not null
      and trim(search_query) != ''
    group by search_query
),

-- Step 2: keep only meaningful queries (≥3 searchers) before the expensive ILIKE
filtered_demand as (
    select * from demand
    where searcher_count >= 3
),

-- Step 3: match queries to content — ILIKE only runs on filtered set now
supply as (
    select
        d.search_query,
        avg(coalesce(c.imdb_score, 0)) as avg_matched_imdb,
        count(c.title_id)              as matched_title_count
    from filtered_demand d
    left join {{ ref('dim_content') }} c
        on c.title ilike '%' || d.search_query || '%'
        or c.original_title ilike '%' || d.search_query || '%'
    group by d.search_query
),

-- Step 4: resolve top provider name
final as (
    select
        d.search_query,
        d.searcher_count,
        d.search_session_count,
        d.no_clickout_rate,
        d.top_provider_id,
        p.platform_name                                            as top_provider_name,

        -- supply quality: IMDB normalized to 0–1
        round(coalesce(su.avg_matched_imdb, 0) / 10.0, 4)        as supply_quality,
        coalesce(su.matched_title_count, 0)                       as matched_title_count,

        -- frustration bonus
        case when d.no_clickout_rate > 0.7 then 1.5 else 1.0 end as frustration_bonus,

        -- ghost score
        round(
            d.searcher_count
            * (1.0 - coalesce(su.avg_matched_imdb, 0) / 10.0)
            * case when d.no_clickout_rate > 0.7 then 1.5 else 1.0 end
        , 2) as ghost_score

    from filtered_demand d
    left join supply su       on d.search_query = su.search_query
    left join {{ ref('dim_providers') }} p on d.top_provider_id = p.provider_id
)

select
    search_query,
    ghost_score,
    searcher_count,
    search_session_count,
    supply_quality,
    matched_title_count,
    no_clickout_rate,
    frustration_bonus,
    top_provider_id,
    top_provider_name
from final
order by ghost_score desc
