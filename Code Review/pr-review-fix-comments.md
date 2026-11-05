Resolve every unresolved inline review comment on the pull request provided by the user.

**Start by pulling the comments.** Identify the PR for the link provided and fetch only the unresolved inline review threads (using `gh`, the GitHub API, or whatever tooling is available). Ignore resolved and outdated threads. Read each comment with its surrounding diff context and the file it targets, so you judge it against the actual code rather than the comment text alone.

**Evaluate each comment on its merits.** Reviewers can be wrong, can lack context, or can ask for something that conflicts with another comment or with the PR's intent. Classify each one as:
- **Valid:** a real bug, a correctness or security issue, a clear improvement, or a request that matches the codebase's conventions.
- **No change required:** a question, a misunderstanding, a stylistic preference the codebase doesn't follow, a point already handled elsewhere, or a suggestion you disagree with for a concrete technical reason.

**Act on each classification.**
- For valid comments, make the smallest change that fully addresses the feedback, matching the surrounding code's style and patterns. Don't refactor beyond what the comment asks for, and don't touch unrelated code. Run only the tests related to the change, and fix any breakage you introduce. Group related fixes into sensible commits that reference the comment they address, then push to the PR branch.
- For comments where no change is required, reply directly on that thread with a concise, respectful explanation: the reasoning, plus a pointer to the relevant code or decision if useful. Never dismiss a comment without a stated reason.
- If a comment is ambiguous or two comments conflict, pick the most defensible interpretation, act on it, and say in your reply which interpretation you chose so the reviewer can correct you.

**Boundaries.** Don't resolve the threads yourself; leave that to the reviewer. Don't force-push or rewrite history unless I tell you to. Don't leave a thread unanswered: each one gets either a pushed fix or a posted reply.

When finished, give me a summary listing each comment with its outcome (fixed, replied, or flagged as ambiguous), the commit hashes for the fixes, and anything you want me to double-check before the reviewer sees it.
