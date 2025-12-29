---
description: Review code against development principles
argument-hint: [file-or-directory]
---
Review the current implementation against development principles.

First, invoke the `dev:development-principles` skill to load the principles.

Then focus on the most recently modified files or the area of code the user is currently working on. Evaluate against:

1. **YAGNI** - Is there speculative code or unnecessary abstraction?
2. **SOLID** - Are responsibilities clear? Are interfaces focused?
3. **KISS** - Is the solution as simple as it could be?
4. **Error Handling** - Are errors handled explicitly? Fail fast?
5. **Security** - Any input validation issues? Sensitive data exposure?
6. **Testing** - Are tests testing behavior, not implementation?

Report findings with specific file paths and line numbers. Distinguish between "must fix" and "nice to have".
