# Code Coach

## Install

- Git
- Ruby 4.0.1
- Bundler 4.0.19
- GNU Make
- Docker Desktop (macOS or Windows) or Docker Engine with the Compose plugin (Linux)

## Run

1. Clone this repository.
2. Start Docker and confirm `docker info` succeeds without `sudo`.
   On Linux, after joining the `docker` group, run `newgrp docker` or log out
   and back in, then retry. See [Docker permissions](#docker-permissions-on-linux).
3. Run `make run` from the project directory to start local development.

Setup starts PostgreSQL 17 in Docker, waits until it is ready, and prepares the
development and test databases. PostgreSQL data persists in a Docker volume.
To stop the database without deleting data, run `docker compose stop db`.

For an existing database, run `bin/rails db:migrate db:seed` to install the
roadmap's prerequisite links. Seeding preserves accounts and submissions.

See the [user guide](docs/user_guide.md) for roadmap states and practice, and
[roadmap implementation](docs/roadmap.md) for model contracts and validation.

## Configuration

### Database

All environments use PostgreSQL. Local defaults are `127.0.0.1:5432`, user and
password `codecoach`, with separate `codecoach_development` and `codecoach_test`
databases. The Docker port is bound only to localhost. If port 5432 is occupied,
use `PGPORT=5433 make run` and use the same `PGPORT` for later Rails/test commands.

To use an existing PostgreSQL server, set `PGHOST`, `PGPORT`, `PGUSER`, and
`PGPASSWORD`, or set `DATABASE_URL`. Setup skips the Docker database when
`PGHOST` or `DATABASE_URL` is set. The local role needs permission to create the
development and test databases. For source builds of the `pg` gem, install
PostgreSQL development headers (`libpq-dev` on Debian/Ubuntu or `libpq` on
Homebrew, with `pg_config` on `PATH`).

Tests use `codecoach_test` by default. `DATABASE_URL` overrides the database
name too: unset it for local tests, or supply a URL for a dedicated test database.
Never run tests with a development or production URL.

In production, set `DATABASE_URL` to the provisioned PostgreSQL connection
string and set `RAILS_MASTER_KEY`. Run
`RAILS_ENV=production bin/rails db:prepare` before serving traffic; the Docker
entrypoint already does this. Kamal also forwards `DATABASE_URL` from the
deployment environment. The local Compose database and its demo credentials
are for development only. This configuration does not provision or deploy a
production database.

Existing `storage/*.sqlite3` files are preserved, but Rails no longer reads them.
`db:prepare` creates a fresh PostgreSQL database; it does not copy SQLite data.
Keep a backup and transfer existing records before switching an installation
that needs to retain accounts or practice history.

### AI

AI code review uses OpenAI. Set these environment variables before starting the server:

| Variable | Required | Purpose |
|---|---|---|
| `OPENAI_API_KEY` | For AI features | Your OpenAI API key. Without it, AI code review shows "AI code review is unavailable right now" instead of failing. |
| `OPENAI_MODEL` | No | The OpenAI model to use. Defaults to `gpt-6-luna`. |

For example:

```sh
OPENAI_API_KEY="your-key" make run
```

Never commit the key. In production, set it in the hosting provider's environment settings. The test suites never call OpenAI, so CI does not need a key.

### Premium accounts

Premium is the account role that grants access to AI features. New accounts
start as Free.

#### Local grader account

After completing the setup under **Run**, create a Premium demo account in the
local development database. Run this from the project directory:

```sh
bin/rails runner -e development '
  user = User.find_or_initialize_by(email: "grader@example.com")
  user.update!(role: "Premium", password: "CodeCoach-Grader-2026!")
  puts "Premium account ready: #{user.email}"
'
```

Open <http://127.0.0.1:3000/session/new> while `make run` is running and sign in:

- **Email:** `grader@example.com`
- **Password:** `CodeCoach-Grader-2026!`

These are local demo credentials. The command creates the account if missing;
running it again restores its Premium role and demo password while preserving
its practice history. The account is stored in the local database, so a grader
using a fresh clone must run the command too.

To try AI code review, configure `OPENAI_API_KEY` as described above, submit a
solution, and select **Get AI code review** on the attempt page. The Premium
role alone does not configure the AI service.

#### Promote an existing account

To keep your own account and password, register through the app, then run this
with your registered email and refresh the page:

```sh
bin/rails runner -e development 'User.find_by!(email: "you@example.com").update!(role: "Premium")'
```

## Tests and quality checks

Install the Ruby version in `.ruby-version` and run `bundle install`, then:

```sh
bin/judge-build
docker compose up -d --wait db
RAILS_ENV=test bin/rails db:prepare
export COVERAGE_ROOT="$(mktemp -d)"
bundle exec rspec
bundle exec cucumber --no-profile --strict
bin/rails test
bundle exec ruby test_support/merge_coverage.rb
bin/rubocop --fail-level info
```

CI runs these application suites and requires separate RSpec, Cucumber, and
combined Ruby line coverage of at least 90%, plus zero RuboCop offenses.
Feature owners must add meaningful tests for their acceptance criteria.

See [Quality checks and Definition of Done](docs/quality.md) for report
locations, test authoring, CI activation, and the evidence requiring human review.

### Docker permissions on Linux

If `docker info` reports permission denied while Docker is running, add your
user to the Docker Engine installation's `docker` group:

```sh
sudo usermod -aG docker "$USER"
```

Adding your user to the group does not update an existing shell's permissions.
Starting or restarting Docker does not refresh them either. If you already ran
the command above, activate the membership by running these commands one at a
time in your terminal:

```sh
newgrp docker
docker info
make run
```

`newgrp docker` starts a new shell with Docker group access; run the next two
commands in that shell. Continue to `make run` only after `docker info` succeeds.
Run the application as your normal user, without `sudo`.

Alternatively, fully log out of your desktop or SSH session and log back in,
then run `docker info` and `make run`. Opening another terminal in the same
login session may still inherit the old group permissions.

The `docker` group grants root-level privileges. See Docker's official
[Linux post-installation instructions](https://docs.docker.com/engine/install/linux-postinstall/).

## Troubleshooting

**Ruby 4.0.1 fails to install on macOS 26 with a `miniruby` segmentation fault.** This is [Ruby bug #22311](https://bugs.ruby-lang.org/issues/22311): the macOS 27 SDK declares `pipe2()` and `dup3()`, which macOS 26 does not have. Install with:

```sh
ac_cv_func_dup3=no ac_cv_func_pipe2=no rbenv install 4.0.1
```
