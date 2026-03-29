# Lightdash Setup

## GUI Access

- **URL**: [app.lightdash.cloud](https://app.lightdash.cloud)
- **Login**: use your Lightdash account credentials
- **Project**: select your project from the project switcher

## Install and authenticate the Lightdash CLI

```bash
# Install
npm install -g @lightdash/cli

# Verify
lightdash --version

# Authenticate
lightdash login https://app.lightdash.cloud --token <YOUR_PERSONAL_ACCESS_TOKEN>
```

To get your personal access token:

1. Log in to Lightdash
2. Click your avatar (bottom-left) → **Settings**
3. Go to **Personal Access Tokens** → **Create new token**
4. Copy the token and use it in the command above

## Set your project

```bash
# List available projects to find your project UUID
lightdash config list-projects

# Set your project as default
lightdash config set-project --project <PROJECT_UUID>
```

## Deploy dbt models to Lightdash

From your dbt project directory:

```bash
# Compile dbt and deploy models to Lightdash
lightdash deploy
```

After deploying, your dbt models appear under **Explore** in the Lightdash UI.

## Adding models and re-deploying

After adding or changing dbt models:

```bash
dbt run
lightdash deploy
```

## End-to-end flow

```text
┌─────────────────────────────────────────────────────────────────┐
│  DB_JW_SHARED.CHALLENGE     DB_TEAM_<N>        Lightdash       │
│  (shared, read-only)        (your DB)          (your project)  │
│                                                                 │
│  T1, T2, T3, T4  ──dbt──▶  base.base_events   ──deploy──▶     │
│  OBJECTS          ──dbt──▶  base.base_objects      Explore      │
│  PACKAGES         ──dbt──▶  base.base_packages     (charts &   │
│                             marts.your_model        dashboards) │
└─────────────────────────────────────────────────────────────────┘
```

## Resources

- [Lightdash documentation](https://docs.lightdash.com/)
- [Lightdash AI agent documentation](https://docs.lightdash.com/guides/ai-agents)
