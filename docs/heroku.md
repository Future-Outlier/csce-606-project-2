# Heroku deployment

The Rails application runs on Heroku. Submitted code does not run inside a
Heroku dyno. Production sends source and test inputs to an HTTPS judge that
executes each submission outside the Rails application and returns only the
verdict and outputs.

## Required Heroku configuration

Provision Heroku Postgres and set these config vars in the Heroku dashboard:

- `RAILS_MASTER_KEY`: the Rails production credentials key.
- `JUDGE_URL`: the complete HTTPS endpoint for the isolated judge.
- `JUDGE_TOKEN`: a dedicated bearer token accepted only by that endpoint.

Do not put config-var values in Git, `.env` files committed to Git, commands
written to application logs, request parameters, or judge payloads. Rotate the
judge token if it is exposed. The application filters parameters containing
`secret`, `token`, or `_key` from Rails logs.

The `Procfile` starts Puma with Heroku's `PORT` and runs database migrations
and the idempotent judge seed during the release phase. Production never falls
back to local process execution or Docker when judge configuration is missing.

## Judge request

The application sends one `POST` request to `JUDGE_URL` with these headers:

```text
Authorization: Bearer <JUDGE_TOKEN>
Content-Type: application/json
Accept: application/json
```

The JSON body contains submitted source, the selected language and fixed
runtime, the problem method and input shape, and test inputs. It never contains
expected outputs, database credentials, Rails credentials, or the judge token.

The configured endpoint must support exactly these runtime values:

- `Ruby 4.0.1`
- `Python 3.15.2`
- `Go 1.27.3`
- `C++23 (GCC 16.2.0)`

The response must use HTTP 200 and contain JSON with `status`, `outputs`, and
the same `runtime` value. Any redirect, non-200 response, TLS error, timeout,
oversized response, invalid JSON, unsupported status, or mismatched runtime is
stored as `Judge Unavailable`. Remote response bodies are not shown to users.

## Judge requirements

The service behind `JUDGE_URL` must execute submitted code with no Rails source,
database access, Heroku config vars, host mounts, or unrestricted network. It
must enforce the configured one-CPU, 512 MiB memory, 32-process, output,
15-second compile, and four-second per-case limits. The bearer token must be
checked before execution and must not be present in the submitted process
environment. Go 1.27.3 compilation was measured to exceed 256 MiB in the pinned
image, so the previous Ruby-only 128 MiB container limit cannot support the
selected Go compiler.

## Production verification

After deployment, verify `/up`, submit correct solutions in all four languages,
and submit invalid syntax, an exception, an endless loop, and a wrong answer.
Confirm the fixed runtime shown for each saved submission, the generic error
text, ownership checks, passed-case counts, and absence of secrets from Heroku
and judge logs.
