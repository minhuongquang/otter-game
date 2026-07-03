# Technical Debt

> **Purpose**: Track known technical debt, workarounds, and cleanup items.  
> **Type**: Living document — add entries as debt is identified.  
> **Last Updated**: 2026-06-28

---

## How to Use

- Add new debt items when introducing workarounds or shortcuts.
- Assign a priority and estimate effort.
- Move to "Resolved" when the debt is paid.
- Review quarterly.

---

## Open Items

| ID | Description | Area | Priority | Effort | Added | Status |
|----|-------------|------|----------|--------|-------|--------|
| — | — | — | — | — | — | — |

---

## Prioritization

| Priority | Meaning | Timeline |
|----------|---------|----------|
| CRITICAL | Must fix before next release | Immediate |
| HIGH | Should fix this milestone | This sprint |
| MEDIUM | Fix when in the area | Next sprint |
| LOW | Fix if time permits | Backlog |

---

## Debt Entry Template

```markdown
### TDEBT-NNN: [Title]

**Area**: [System/Module]
**Priority**: [CRITICAL | HIGH | MEDIUM | LOW]
**Effort**: [X hours/days]
**Added**: YYYY-MM-DD
**Status**: [Open | In Progress | Resolved]

**Description**:
Brief explanation of the debt, why it exists, and what the ideal solution would be.

**Impact**:
What problems does this cause now or in the future?

**Resolution Plan**:
Steps to fix this properly.

**Related**:
- [decisions.md](decisions.md) — ADR if applicable
- [current_tasks.md](current_tasks.md) — Task tracking
```

---

## Accepted Workarounds

These are intentional shortcuts that are acceptable to keep for now.

| ID | Workaround | Reason | Review Date |
|----|------------|--------|-------------|
| — | — | — | — |

---

## Resolved Items

| ID | Description | Resolved | Resolution |
|----|-------------|----------|------------|
| — | — | — | — |

---

## Related

- [decisions.md](decisions.md) — Design decisions
- [current_tasks.md](current_tasks.md) — Active tasks
- [testing.md](testing.md) — Testing requirements
