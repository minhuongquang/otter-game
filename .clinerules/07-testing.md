---

description: Testing and validation
alwaysApply: true
-----------------

# Testing Philosophy

Every implemented feature should include a validation plan.

Never assume code works because it compiles.

---

# Validation Checklist

Before considering a task complete:

* No syntax errors
* No obvious runtime errors
* No broken references
* Existing functionality still works
* Edge cases considered

---

# Feature Testing

For every feature explain:

* How to test it
* Expected result
* Failure conditions

---

# Regression

When modifying an existing system,

consider whether the change may affect:

* Save system
* UI
* Input
* Scene transitions
* Signals

Mention potential regressions when relevant.

---

# Error Handling

Prefer explicit error handling.

Avoid silent failures.

If a failure is possible,

log meaningful messages for debugging.
