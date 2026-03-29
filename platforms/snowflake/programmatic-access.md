# Programmatic Access to Snowflake

## Snow CLI (recommended)

Install the Snowflake CLI:

```bash
brew install snowflakecli
# or
pip install snowflake-cli-labs
```

Set up your connection config:

```toml
# ~/.snowflake/connections.toml
[snowflake_conn]
account = "<ACCOUNT_ID>"
user = "you@example.com"
password = "<your-password>"
warehouse = "WH_TEAM_<N>_XS"
database = "DB_TEAM_<N>"
```

Test your connection:

```bash
snow sql -q "SELECT CURRENT_USER(), CURRENT_WAREHOUSE()" -c snowflake_conn
```

## Common queries

```bash
# Run a query
snow sql -q "SELECT COUNT(*) FROM T1" -c snowflake_conn

# Use a bigger warehouse for heavy queries
snow sql -q "USE WAREHOUSE WH_TEAM_1_S; SELECT COUNT(*) FROM T3" -c snowflake_conn

# JSON output (useful for wide tables or semi-structured data)
snow sql -q "SELECT * FROM PACKAGES LIMIT 5" -c snowflake_conn --format json

# Run SQL from a file
snow sql -f my_query.sql -c snowflake_conn

# Write results to your database
snow sql -q "USE DATABASE DB_TEAM_1; CREATE OR REPLACE TABLE analysis.results AS SELECT ..." -c snowflake_conn
```

## Python connector

```python
import snowflake.connector

conn = snowflake.connector.connect(
    account="<ACCOUNT_ID>",
    user="<your-email>",
    password="<your-password>",
    warehouse="WH_TEAM_<N>_XS",
    database="DB_JW_SHARED",
    schema="CHALLENGE"
)

cur = conn.cursor()
cur.execute("SELECT COUNT(*) FROM T1")
print(cur.fetchone())
```

## Snowpark (Python DataFrames)

```python
from snowflake.snowpark import Session

session = Session.builder.configs({
    "account": "<ACCOUNT_ID>",
    "user": "<your-email>",
    "password": "<your-password>",
    "warehouse": "WH_TEAM_<N>_XS",
    "database": "DB_JW_SHARED",
    "schema": "CHALLENGE"
}).create()

df = session.table("T1")
df.filter(df["SE_CATEGORY"] == "clickout").count()
```
