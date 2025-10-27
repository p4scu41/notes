## 🧩 **Code Review Checklist**

### 1. **Code Quality & Readability**

* [ ] Code is easy to read and understand.
* [ ] Variable and function names are descriptive and follow naming conventions.
* [ ] Code is modular — large functions or classes are broken down into smaller, reusable pieces.
* [ ] No unnecessary comments — code is self-explanatory where possible.
* [ ] Comments (if present) explain the *why*, not the *what*.
* [ ] No commented-out code remains.

---

### 2. **Correctness & Functionality**

* [ ] The logic is correct and meets the requirements or acceptance criteria.
* [ ] All new and modified features behave as expected.
* [ ] Edge cases, boundary conditions, and failure paths are handled properly.
* [ ] Input validation and error handling are implemented.
* [ ] No obvious bugs, exceptions, or race conditions.

---

### 3. **Security**

* [ ] User inputs are sanitized and validated.
* [ ] Sensitive data (passwords, tokens, personal info) is properly encrypted or masked.
* [ ] No secrets or credentials are committed in the code.
* [ ] API endpoints enforce proper authentication and authorization.
* [ ] Dependencies are secure and up-to-date.

---

### 4. **Performance**

* [ ] Code avoids unnecessary computation, loops, or database queries.
* [ ] N+1 query issues are prevented.
* [ ] Caching or pagination is used where appropriate.
* [ ] Resource-intensive tasks are handled asynchronously or with queues.
* [ ] Memory and CPU usage are reasonable for the context.

---

### 5. **Testing**

* [ ] Unit tests are written for new logic.
* [ ] Integration and/or end-to-end tests are added where relevant.
* [ ] Tests cover edge cases and error paths.
* [ ] All tests pass locally and in CI/CD.
* [ ] No flaky or redundant tests.

---

### 6. **Consistency & Standards**

* [ ] Code follows project or language style guides (e.g., PEP8, ESLint, PSR-12).
* [ ] Consistent formatting (indentation, spacing, braces, quotes, etc.).
* [ ] File and folder structure follows conventions.
* [ ] Logging and error messages follow consistent patterns.
* [ ] Proper use of environment variables and configuration management.

---

### 7. **Documentation**

* [ ] Public APIs, methods, and components are documented.
* [ ] Complex or non-obvious logic has inline documentation.
* [ ] README or setup instructions are updated if needed.
* [ ] Changelog or release notes are updated (if applicable).

---

### 8. **DevOps & Deployment**

* [ ] Build scripts and pipelines are not broken by changes.
* [ ] Environment-specific configurations are properly separated.
* [ ] Rollback or migration plans are included for schema changes.
* [ ] No debug logs, print statements, or test code left in production files.

---

### 9. **UX / Frontend (if applicable)**

* [ ] UI follows design specs.
* [ ] Layout is responsive and accessible (a11y).
* [ ] No console errors or warnings in the browser.
* [ ] Components are reusable and optimized for re-rendering.
* [ ] Proper loading and error states are handled.

---

### 10. **General Sanity Check**

* [ ] PR title and description clearly explain the change.
* [ ] Commits are clean, meaningful, and follow conventional commit rules (if used).
* [ ] No large, unrelated changes mixed in the same PR.
* [ ] Reviewer understands *why* each change was made.
