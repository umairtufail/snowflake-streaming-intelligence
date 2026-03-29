# Collate

[Collate](https://www.getcollate.io/) (powered by [OpenMetadata](https://open-metadata.org/)) is a data catalog and governance platform. Use it to explore table schemas, understand data relationships, and document your work.

## Connection

- **URL**: your Collate instance URL
- **Username**: your email address
- **Password**: your Collate password

## What's cataloged

Collate is connected to the Snowflake account and has ingested the full dataset:

| What's ingested | What you can explore |
| --------------- | -------------------- |
| `DB_JW_SHARED.CHALLENGE` — all 6 tables (T1–T4, OBJECTS, PACKAGES) | Schemas, column types, descriptions, data profiles, sample rows |

### Connect your work (optional)

As you build dbt models and Lightdash dashboards, you can connect those to Collate for a unified catalog across your entire stack:

| Service | What it adds to Collate | Setup guide |
| ------- | ----------------------- | ----------- |
| **dbt** | Model definitions, source mappings, test results, transformation logic | [dbt connector docs](https://docs.getcollate.io/connectors/database/dbt/configure-dbt-workflow) |
| **Lightdash** | Dashboard metadata, chart definitions, connections to dbt models | [Lightdash connector docs](https://docs.getcollate.io/connectors/dashboard/lightdash) |

## The CHALLENGE schema

Every table and column has been cataloged with descriptions, so you can browse the complete data model without writing any SQL.

### Event tables — T1, T2, T3, T4

All four tables share the same 25-column schema — they differ only in volume and geography.

| Table | Rows | Geography | Period |
| ----- | ---- | --------- | ------ |
| `T1` | 9.2M | Germany only | Dec 2025 |
| `T2` | 40M | 8 EU markets | Dec 2025 |
| `T3` | 128M | 8 EU markets | Nov 2025 – Jan 2026 |
| `T4` | 254M | 15 global markets | Nov – Dec 2025 |

Key column groups:

- **Identity & session** — `USER_ID`, `LOGIN_ID`, `SESSION_ID`, `SESSION_IDX`
- **Timestamps** — `COLLECTOR_TSTAMP` (server-side UTC), `DERIVED_TSTAMP` (clock-drift corrected)
- **Event classification** — `EVENT` (`page_view` or `struct`). Structured events use `SE_CATEGORY`, `SE_ACTION`, `SE_LABEL`, `SE_PROPERTY`, `SE_VALUE`
- **Geography** — `GEO_COUNTRY`, `GEO_REGION_NAME`, `GEO_CITY`
- **Semi-structured context columns** (VARIANT/JSON):
  - `CC_TITLE` — content metadata: `jwEntityId`, `objectType`, `seasonNumber`, `episodeNumber`
  - `CC_CLICKOUT` — provider/offer details: `providerId`. Clickout events only
  - `CC_PAGE_TYPE` — `pageType`, `appLocale` (user's chosen market)
  - `CC_YAUAA` — parsed user agent: `deviceClass`, `agentName`
  - `CC_SEARCH` — `searchEntry` (what the user typed)

### OBJECTS table — ~13M rows

| Column group | Key columns |
| ------------ | ----------- |
| Identity | `OBJECT_ID`, `OBJECT_TYPE`, `TITLE_ID`, `PARENT_ID` |
| Content | `TITLE`, `ORIGINAL_TITLE`, `SHORT_DESCRIPTION`, `RELEASE_YEAR`, `RUNTIME`, `ORIGINAL_LANGUAGE` |
| Classification (arrays) | `GENRE_TMDB`, `PRODUCTION_COUNTRIES`, `TALENT_CAST`, `TALENT_DIRECTOR` |
| Ratings | `IMDB_SCORE`, `ID_IMDB` |

### PACKAGES table — 1,526 rows

| Column | Description |
| ------ | ----------- |
| `ID` | Provider identifier (join key from `CC_CLICKOUT:providerId`) |
| `TECHNICAL_NAME` | Slug for code (e.g. `netflix`, `amazon_prime_video`) |
| `CLEAR_NAME` | Display name for charts (e.g. "Netflix", "Disney+") |
| `MONETIZATION_TYPES` | Comma-separated: `flatrate`, `free`, `rent`, `buy`, `cinema` |

### How the tables connect

```
Events (T1–T4)                         OBJECTS
  CC_TITLE:jwEntityId::TEXT  ───────▶  OBJECT_ID

Events (T1–T4)                         PACKAGES
  CC_CLICKOUT:providerId::NUMBER ────▶ ID
```

## Key features

### Search & Discovery
Use the global search bar to find tables, columns, and metadata — no SQL required.

### Schema Exploration
Click into any table to see every column with its data type and description. Especially useful for the VARIANT/JSON fields (`CC_TITLE`, `CC_CLICKOUT`, etc.).

### Data Profiler & Sample Data
Column-level statistics — row counts, distinct values, null percentages, value distributions — without running a query.

### Documentation & Tagging
Add descriptions, tags, and notes to any table or column as a shared knowledge base.

### Chrome Extension

Install the [Collate Browser Extension](https://chromewebstore.google.com/detail/collate/ndjnpiadedlmgddlpeklbnobebkpkdgb) to access metadata directly inside Snowflake without switching tabs.

1. Install from the Chrome Web Store and pin it to your toolbar
2. Click the extension icon and enter your Collate instance URL
3. Sign in with your credentials

### AskCollate — AI-powered data assistant

Ask questions in natural language:
- _"List all tables in the CHALLENGE schema"_
- _"What columns in T1 are related to user identity?"_
- _"Generate a SQL query to count clickout events by provider"_

### MCP Server

Collate exposes an MCP server that lets AI tools like Claude interact with the catalog programmatically.

```json
{
  "mcpServers": {
    "collate": {
      "url": "https://<your-collate-instance>/mcp",
      "headers": {
        "Authorization": "Bearer <YOUR_PERSONAL_ACCESS_TOKEN>"
      }
    }
  }
}
```

## Quick start

1. Install the Chrome extension and set your instance URL
2. Sign in to Collate
3. Search for `T1` or `OBJECTS`, browse columns, profiler stats, and sample data
4. Add tags and notes as you explore

## Resources

| Resource | What you'll learn |
| -------- | ----------------- |
| [Interactive demos](https://www.getcollate.io/learning-center/resource/demos) | Search, discovery, data quality, and the catalog UI |
| [Tutorials](https://www.getcollate.io/learning-center/resource/tutorials) | Step-by-step guides for common tasks |
