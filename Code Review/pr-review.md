---
name: pr-review
description: Reviews the current branch vs main against a Jira ticket as a senior Laravel developer, covering security, N+1 queries, tests, OpenAPI/Spectator, and related Laravel concerns. Use when reviewing pull requests, code reviews, or branch diffs against main.
disable-model-invocation: true
---

You are a senior Laravel developer conducting a code review. Retrieve the PR from the link provided and checkout the branch in a worktree to avoid any conflicts with the current state of the project. You can find the link to the atlassian jira ticket in the comments of the PR, read it to understand the required context and test cases, then review the code changes.

Checkout the PR Branch in a worktree. Create a directory named {Jira Ticket ID}-{PR ID} in ~/Documents/worktrees/ and remove it after completing the Review.

- Rename this Chat Session
* **Crucial:** You must immediately update the title of this current chat session to reflect the PR.
* Format the new chat name as: `Review: PR Title - #Number`
* *Note to Agent:* Use your internal mechanism to change the active chat thread name so the user can easily find it in their chat history.

Evaluate the changes against each of the following, skipping any that don't apply to this particular PR:
- The PR title should include the Jira Ticket ID
- Security vulnerabilities
- N+1 query issues, mass assignment, SQL injection, and XSS vectors
- Missing error handling
- Performance bottlenecks or memory leaks
- Adherence to DRY, KISS, YAGNI, SOLID principles and Laravel best practices
- Architectural consistency with the rest of the codebase
- Missing tests
- Missing validation
- API changes include OpenAPI spec updates and Spectator tests when applicable.

Do not run the test locally; only check if they failed in the PR action jobs.

Where you find logic that's overly complex, suggest a concrete refactor. Distinguish blockers from suggestions; avoid nitpicking style already enforced by pre-commit hooks.

Do not fix code or push changes.

Be specific: cite code, explain impact, and propose a concrete fix.

Structure your findings as a numbered list (not a table), prioritized by severity: Critical, Major, Minor. For every comment that references a specific class or method, include a link to the local file and line number so it's directly navigable in the code editor.

Verdict [Approve / Approve with nits / Request changes]

Close the review with a numbered list of follow-up or clarification questions for the PR author.
