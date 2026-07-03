---

description: Git workflow and source control
alwaysApply: true
-----------------

# Git Workflow

One feature per commit.

Avoid mixing unrelated changes.

---

# File Changes

Only modify files required for the current task.

Avoid formatting unrelated files.

Avoid unnecessary refactoring.

---

# Commit Quality

Commits should be:

* Small
* Focused
* Reversible

---

# Before Large Changes

Explain:

* Which files will change
* Why they need to change
* Possible risks

---

# Existing Code

Prefer extending existing systems.

Do not duplicate functionality.

Do not rewrite stable code without justification.

---

# Respect Existing Architecture

Before creating a new Manager,

confirm that an existing one cannot be extended cleanly.

Avoid introducing parallel systems that solve the same problem.

---

# Goal

Maintain a clean project history that is easy to review and debug.
