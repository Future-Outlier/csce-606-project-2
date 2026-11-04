# Sprint 1 Daily Scrum

## October 19 and 20, 2026

### Han-Ju

- Update: build the authentication and judge system

### Ian Beckett

- Done: reinitialized project as a rails app, created the project tracker and
  MVP burnup, published 4 PRs for CI and automated repo management. Also
  drafted project deadlines (adjustable, but needed to ensure satisfactory
  progress for mid-project deliverables).
- Next (Oct 21): Implement US1 - Roadmap and Problem Discovery. Merge PRs for
  CI if reviewed.

### Chibuzo

- Done: Started US3 (AI Code Review, #6). Built the review service layer: AI
  reply parser with line-number mapping, reviewer with failure handling and
  prompt-injection protection, and an AI client interface with a fake for tests
  (24 RSpec examples passing). Branch us3-ai-code-review.
- Next (Oct 21): Review PR #4 and build US3 on its User/Attempt/login models.
- Blockers: Need PR #4 (User/login/Attempt) merged or shared to continue US3.

### Salvador

- Done: Mapped out and structured the feature requirements for US6 (Learning
  History & Analytics) and reviewing potential model relationships
- Next: Begin implementing controller actions and route handling for user
  history.

## October 21, 2026

### Eugene

- Done:
  - Reviewed some of Ian's PR
  - Set up the repo and installed the needed ruby version
  - Mapped out the design of Socratic Auditing
  - Created a draft of the prompt for the AI
- Tomorrow:
  - Refine design of socratic auditing
  - Set-up RSpec in the code base
  - Create tests for the Socratic Auditing
  - Vibe code to pass the tests

### Ian Beckett

- Today:
  - reviewed PR https://github.com/ianebeckett/csce-606-project-2/pull/4
  - discussed feature review strategy with Eugene
  - increased minimum coverage for merging to 90% per instructor's
    requirements
  - cleaned up issue descriptions for all features
  - created a new PR to enforce quality of work standards for all features
  - merged CI message check PR
  - Added PR to fix docker permission issues when running the bootstrap script
  - Implemented US1. Ready for review @Yung Grug:
    https://github.com/ianebeckett/csce-606-project-2/pull/42
- Tomorrow's Plan:
  - Merge US1
  - more code cleanup and project planning
  - discuss sprint planning and other required artifacts with the team

### Han-Ju

- merge PR #4
- read chibo's comment
- tomorrow:
  - create PRs and address Chibo's comment
  - review Chibo's PR
- will review tmr, tks Chibo

### Chibuzo

- Done: Reviewed and approved PR #4 (fixes now in #36–38). Built the US3 AI
  code review page and opened PR #40 (tests passing, CI green).
- Next: Get #40 reviewed and merged.
- Blockers: Need a review for my PR @Han-Ru (Future-Outlier).

### Salvador

- Done: Built and tested the core components of US6, implementing the
  controller logic, routes, views, and local MVP database tables.
- Next: Write acceptance tests covering happy paths and empty-history sad
  paths.

## October 22, 2026

### Han-Ju

- done: review chibo's pr, 2 pr ready for review (related to judge system)
- next: address more comment in the judge system pr, and review chibo's
  followup pr

### Chibuzo

- Done: Merged PR #40 (US3 AI code review). Built the OpenAI client (tested
  live with a real key) and opened PR #45 with tests, docs, and an ADR.
- Next: Get #45 reviewed and merged @Han-Ru (Future-Outlier).
- Blockers: US3 will need OPENAI_API_KEY set on the host.

### Ian Beckett

- Done: resolved merge conflicts on US1 feature branch
- Next: merge US1 feature branch

## October 23, 2026

### Eugene

- Done:
  - Merged Ian's branches.
  - Wrote integration test and unit test for Socratic Auditing.
- Tomorrow:
  - Finish writing more integration tests and unit tests for Socratic Auditing.
  - Set up OpenAI API Token for the team.
  - Finish the implementation for the tests with TDD and AI.

### Ian Beckett

- Done: Tentatively assigned each issue to a Sprint based on feature
  dependency
- Next:
  - Align project management and documentation with requirements
  - Review features as the team submits PRs leading up to the mid-project
    deadline

### Mick

- Done: Implemented US2 backend scheduling and tests. All tests passed and
  pushed to github
- Next: Work on the due reviews page, finish testing and create a PR

### Chibuzo

- Done: Reviewed #36 and #37 (tested with Docker). Fixed blank submissions so
  they don't call the AI. Resolved #45's merge conflict with main.
- Next: Get #45 merged and start saving AI reviews.
- Blockers: Need a reviewer for #45.

## October 24, 2026

### Han-Ju

- done:
  - merge chibo's pr about US3 followup (openai, ai codereview)
  - merge mine US7 PR followup (blank ruby submission edgecase and submission
    exits error)
- next: take a look at the scrum meeting requirements

### Salvador Pruneda

- Done:
  - Reimplemented US6 (Learning History & Analytics) backend models, controller
    actions, and server-rendered views.
  - Configured local database migrations and verified the test suite execution.
- Next: open the PR for review, stylize History page, and finalize test coverage
  reports.

### Ian Beckett

- Done: Make lint, quality, and commit message CI check block merge when
  failing
- Next:
  - Align project documentation with requirements
  - Prepare missing mid-project deliverables

## October 25, 2026

### Eugene

- Done:
  - Finish writing unit, integration, and UI tests
  - Finish implementation that passes all tests.
  - Set-up openai account & added credit
  - Created a PR
- Next:
  - Improve UI experience for socratic auditing.
  - Read about Scrum requirements

### Ian Beckett

- Done:
  - Started reviewingUS4 PR
  - Added two PRs (#48, #51) for documentation to support install, run, grading
  - Added issues #49, #50 for more data and features needed
- Next: Finish reviewing US4 PR

## October 26, 2026

### Mick

- Done: Finished due reviews page to display scheduled problems. Added tests to
  verify functionality, and all tests passed.
- Next:
  - Implement the review interval updates after a user completes scheduled
    reviews
  - Final testing, and then create a PR
- Done:
  - Implemented perfomance ratings (1-5),
  - automatic review scheduling
  - due reviews dashboard
  - created a PR
- Next:
  - review PR's
  - address questions regarding US2

### Chibuzo

- Done: #45 merged (OpenAI client, docs, ADR). Reviewed and approved #36 and
  #37. Built saving AI reviews in draft #52 (builds on #47).
- Next: Get #52 into main once #47 merges.
- Blockers: Waiting on #47.

## October 28, 2026

### Mick

- Done:
  - Merged US2 into main
  - Reviewed and approved US6, PR54
- Next: Work on US5

### Salvador

- Done:
  - Merged US6 into main
  - Reviewed and approved US2

## October 30, 2026

### Ian Beckett

- done:
  - Revised docs for the Roadmap feature
  - Distributed scrum events as separate issues for each scrum
- next:
  - prepare for and conduct sprint review and retro
  - prepare and submit mid-project deliverables by EOD Monday.

### Chibuzo

- Done: Merged main into #52 and resolved the conflicts with #47. Also hid
  saved reviews from the learning history page. CI passes and #52 is ready for
  review.
- Next: Get #52 reviewed and merged @Han-Ru (Future-Outlier)

### Han-Ju

- will review tmr

## October 31, 2026

### Han-Ju

- I am sick today, will review tmr, sorry

## November 1, 2026

### Han-Ju

- DONE: reviewed and merged Chibuzo's pr

### Ian Beckett

- done:
  - Fix CI by pinning Ruby version
  - Update branch protection rules
- next: deliver mid-project artifacts
