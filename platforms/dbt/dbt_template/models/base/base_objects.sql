-- JustWatch content metadata | ~13M rows
-- Join to events: cc_title:jwEntityId::TEXT = object_id

select *
from {{ source('jw_shared', 'OBJECTS') }}
