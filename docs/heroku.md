# Heroku deployment

The Rails application and submitted-code execution run in separate Heroku
apps. Rails uses Heroku Postgres. The judge app uses the Container stack and
keeps its worker formation at zero. Rails creates one attached one-off worker
dyno for each submission through the Heroku Platform API.

## Rails app configuration

Set these config vars in the Rails app's Heroku dashboard:

- `RAILS_MASTER_KEY`: the Rails production credentials key.
- `JUDGE_HEROKU_APP`: the Container-stack judge app name.
- `JUDGE_HEROKU_TOKEN`: an OAuth token that can create dynos in the judge app.

Use a dedicated Heroku user that can access only the judge app and an OAuth
`write` scope, which excludes config-var access. Do not use the account-wide CLI
token for a long-lived production deployment. Never put token values in Git,
request parameters, submitted-code payloads, or application logs.

The `Procfile` starts Puma with Heroku's `PORT` and runs database migrations
and the idempotent judge seed during the release phase. Production never falls
back to local process execution or Docker when judge configuration is missing.

## Judge app deployment

Create a separate app with the Heroku Container stack. Build
`judge/Dockerfile` for `linux/amd64`, push it as the `worker` process image,
release it, and leave the worker formation scaled to zero. The image contains
exactly these runtimes:

- `Ruby 4.0.1`
- `Python 3.15.2`
- `Go 1.27.3`
- `C++23 (GCC 16.2.0)`

The app needs no database, Rails credentials, API token, or other config vars.
Each one-off dyno gets a fresh ephemeral filesystem and exits after one judge
request. Heroku bills only the one-off dyno runtime while the formation remains
at zero.

## Submission flow

Rails calls `POST /apps/:judge_app/dynos` with `attach: true`, the `worker`
process type, no custom environment, and a 60-second time-to-live. The Platform
API returns a TLS rendezvous URL. Rails sends the source and test inputs through
the attached stdin stream and reads the verdict and outputs from stdout.

Source code is not placed in a dyno command, config var, or Heroku log. The
payload never contains expected outputs, database credentials, Rails
credentials, or the Platform API token. Rails keeps expected outputs and makes
the final Accepted/Wrong Answer decision.

Missing configuration, Platform API errors, TLS errors, timeouts, oversized or
invalid JSON, unsupported statuses, and runtime mismatches are stored as
`Judge Unavailable` without exposing remote output to the user.

## Judge limits

The image enforces a 15-second compile limit, four seconds per case, bounded
output, and a 55-second whole-process deadline. The Heroku Eco/Basic one-off
dyno supplies a 512 MiB memory limit. Removing an unnecessary Ruby orchestration
fork keeps Go 1.27.3 compilation within that limit.

Common Runtime dynos can make outbound internet requests. The one-off dyno
therefore isolates Rails source, database credentials, and application secrets,
but does not establish the earlier Docker `--network none` condition. Treat
network denial as unverified unless a separately tested syscall filter is added.

## Measured Heroku result

On 2026-11-09, `codecoach-judge-20261109` ran the pinned `linux/amd64` image in
fresh Heroku one-off dynos. Ruby, Python, Go, and C++ each compiled/executed the
same two inputs and returned `{"status":"ok","outputs":[true,false]}`. A direct
Rails `HerokuDynoRunner` probe also created Go and C++ dynos through the Platform
API, transferred payloads through rendezvous, and validated the fixed runtime
in each response.

## Production verification

After deploying the Rails app, verify `/up`, submit correct solutions in all
four languages, and submit invalid syntax, an exception, an endless loop, and a
wrong answer. Confirm the fixed runtime, generic error text, ownership checks,
passed-case counts, and absence of secrets from Rails and Heroku logs.
