---

description: Never take shortcuts or introduce technical debt
alwaysApply: true
-----------------

# No Shortcuts Policy

Long-term maintainability always has higher priority than short-term speed.

Never implement temporary workarounds unless explicitly requested.

---

## Never

* Hardcode game content
* Duplicate code
* Ignore architecture
* Ignore existing systems
* Introduce technical debt silently

---

## Always

Prefer extending an existing reusable system over creating a new one.

Explain architectural conflicts before coding.

Ask for clarification instead of making assumptions.

---

## Refactoring

If existing code should be improved,

explain:

* Why
* Benefits
* Risks

before changing it.

---

## Quality

If a feature cannot be implemented cleanly,

stop and explain the problem.

Do not hide architectural issues.

---

## Goal

Every implementation should make the project easier to maintain,

not harder.
