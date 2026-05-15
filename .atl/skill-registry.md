# Skill Registry — noveles

## Project Standards (auto-resolved)

### User Skills

| Skill | Path | Triggers |
|-------|------|----------|
| branch-pr | `~/.claude/skills/branch-pr/SKILL.md` | Creating a pull request, opening a PR, preparing changes for review |
| issue-creation | `~/.claude/skills/issue-creation/SKILL.md` | Creating a GitHub issue, reporting a bug, requesting a feature |
| skill-creator | `~/.claude/skills/skill-creator/SKILL.md` | Creating a new skill, adding agent instructions, documenting patterns for AI |
| go-testing | `~/.claude/skills/go-testing/SKILL.md` | Writing Go tests, using teatest, adding test coverage |
| judgment-day | `~/.claude/skills/judgment-day/SKILL.md` | "judgment day", "judgment-day", "review adversarial", "dual review", "doble review", "juzgar", "que lo juzguen" |
| find-skills | `~/.agents/skills/find-skills/SKILL.md` | "how do I do X", "find a skill for X", "is there a skill that can...", extending capabilities |
| supabase | `~/.agents/skills/supabase/SKILL.md` | Any Supabase task (Database, Auth, Edge Functions, Realtime, Storage, Vectors, Cron, Queues); supabase-js, @supabase/ssr; auth issues; Supabase CLI or MCP server; schema changes, migrations |
| supabase-postgres-best-practices | `~/.agents/skills/supabase-postgres-best-practices/SKILL.md` | Writing, reviewing, or optimizing Postgres queries, schema designs, or database configurations |

### SDD Skills (built-in)

| Skill | Path |
|-------|------|
| sdd-init | `~/.claude/skills/sdd-init/SKILL.md` |
| sdd-explore | `~/.claude/skills/sdd-explore/SKILL.md` |
| sdd-propose | `~/.claude/skills/sdd-propose/SKILL.md` |
| sdd-spec | `~/.claude/skills/sdd-spec/SKILL.md` |
| sdd-design | `~/.claude/skills/sdd-design/SKILL.md` |
| sdd-tasks | `~/.claude/skills/sdd-tasks/SKILL.md` |
| sdd-apply | `~/.claude/skills/sdd-apply/SKILL.md` |
| sdd-verify | `~/.claude/skills/sdd-verify/SKILL.md` |
| sdd-archive | `~/.claude/skills/sdd-archive/SKILL.md` |
| sdd-onboard | `~/.claude/skills/sdd-onboard/SKILL.md` |

### Project Conventions

No project-level convention files found (CLAUDE.md, AGENTS.md, .cursorrules, etc.).

### Compact Rules

**Flutter/Dart project** — match on `.dart` files:
- Use BLoC pattern for state management (flutter_bloc)
- Use get_it for dependency injection
- Clean Architecture: data/repositories → domain/use_cases → presentation/bloc
- Supabase backend: supabase_flutter for client, supabase CLI for local dev
- Lint: flutter_lints with default rules
- Format: `dart format` (default Dart formatter)
- Test: `flutter test` for unit/widget tests

**Supabase** — match on `supabase/` path or supabase_flutter usage:
- Load supabase skill for all Supabase-related work
- Use supabase-postgres-best-practices for schema and query work
- Migrations in `supabase/migrations/` directory
- Local config in `supabase/config.toml`
