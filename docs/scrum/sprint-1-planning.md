## Round 1 — Parallel Development (All 6 Members)

| Person | User Story | Story Points |
|---|---|---|
| A | US1 — Roadmap & Problem Discovery | 8 |
| B | US2 — Spaced Repetition | 5 |
| C | US3 — AI Code Review | 8 |
| D | US4 — Socratic Conceptual Auditing | 8 |
| E | US6 — Learning History & Analytics | 8 |
| F | **US7 — Online Judge & Error Recovery** | 8 |

All six members can start in parallel, using mock data where dependencies are not yet implemented. US7 is the highest priority.

## Round 2 — Remaining User Stories

| Person | User Story | Story Points |
|---|---|---|
| B | US5 — Post-Session Feedback | 3 |

B starts US5 after completing US2. Integration requires US4.

## Integration Order (Topological Sort)

| Wave | User Stories | Dependencies |
|---|---|---|
| 1 | US1, US4, US7 | None |
| 2 | US2, US3, US5 | US7 for US2/US3; US4 for US5 |
| 3 | US6 | US2, US3, US4, US7 |

**Total: 7 MVP User Stories, 48 Story Points, 6 Members (8 points each).**

Development can overlap across waves using mocks, but final integration should respect these dependencies.
