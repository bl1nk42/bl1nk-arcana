# Common Rules for Blink Arcana

## Before Any Implementation

1. **Check PRD first** — Use `/prd check <feature>` to verify feature exists in PDR.md
2. **Read Spec Sheet** — Use `/spec <feature>` to read or create spec
3. **Confirm understanding** — Use `/understand <feature>` before coding
4. **No unauthorized features** — If not in PRD, ask user first

## Change Control

- All feature changes require **Change Request** (`/change <details>`)
- CR must include: Current state, Proposed change, Reason, Impact Analysis, Approval, Rollback Plan
- No direct implementation without approval

## Quality Gates (must pass before commit)

```bash
just fmt      # Format all code
just lint     # Lint all code (Clippy, gdlint, typos, etc.)
just quality  # All quality gates
just precommit # Pre-commit checks
```

## Banned Terms (from GLOSSARY.md)

| Banned | Use Instead |
|--------|-------------|
| Card (generic) | Unit Display / Party Slot |
| Deck | Party / Unit Roster |
| Hand | Party Slots |

## Documentation Standards

- All comments in **Thai language**
- Explain **WHY** not **WHAT**
- TODO comments must include Task ID: `// TODO(TASK-123): ...`
- Update docs/CHANGELOG.md on every feature change

## Code Style

- Rust: Edition 2024, no `unwrap()` in production
- GDScript: Type hints required, early return pattern
- Conventional Commits: `feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert`

## Workflow

1. `/standup` — Daily tasks & blockers
2. `/spec` + `/understand` — Read spec, confirm
3. Code → `just fmt` → `just lint` → `just quality`
4. Commit (Conventional) + Push
5. Update ClickUp + Linear + docs
