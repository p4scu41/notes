Code review comments examples:

---

## 🧠 1. **Clarity & Readability**

**❌ Poor comment:**

> This is confusing.

**✅ Excellent comment:**

> This logic is a bit hard to follow at first glance. Could we extract the condition into a well-named helper method or variable (e.g., `isUserActiveAndVerified`) to improve readability?

---

**❌ Poor comment:**

> Too many nested ifs.

**✅ Excellent comment:**

> This block has several nested conditionals. Consider using early returns or guard clauses to make the flow easier to understand.

---

## ⚙️ 2. **Code Quality / Design**

**❌ Poor comment:**

> This function is too long.

**✅ Excellent comment:**

> This function handles multiple responsibilities — validation, transformation, and persistence. Could we split it into smaller functions (e.g., `validateInput()`, `saveRecord()`)? That’ll make it easier to test and maintain.

---

**❌ Poor comment:**

> Don’t repeat code.

**✅ Excellent comment:**

> I noticed this logic also appears in `UserService`. Maybe we can refactor it into a shared helper or utility function to reduce duplication.

---

## 🧩 3. **Correctness & Functionality**

**❌ Poor comment:**

> This might be wrong.

**✅ Excellent comment:**

> I think this condition might not handle users with null emails. Can you confirm what should happen in that case? Maybe we should explicitly check for `null` before calling `.includes()`.

---

**❌ Poor comment:**

> Doesn’t work for all cases.

**✅ Excellent comment:**

> This looks good for normal inputs, but what happens if the API returns an empty array? It might be worth adding a test for that scenario.

---

## 🛡️ 4. **Security & Performance**

**❌ Poor comment:**

> You shouldn’t do that.

**✅ Excellent comment:**

> Using string concatenation for this SQL query could allow injection if any user input slips through. Could we switch to parameterized queries or ORM binding for safety?

---

**❌ Poor comment:**

> This is slow.

**✅ Excellent comment:**

> The `map().filter()` chain here creates multiple iterations over the list. We could optimize by combining them into a single loop, especially if this runs frequently.

---

## 🧪 5. **Testing & Validation**

**❌ Poor comment:**

> Add more tests.

**✅ Excellent comment:**

> The new logic in `calculateDiscount()` seems untested. Could you add a unit test for cases like expired coupons or zero-value inputs to ensure full coverage?

---

**❌ Poor comment:**

> Missing tests.

**✅ Excellent comment:**

> We should verify that the `POST /orders` endpoint handles invalid payloads correctly. Maybe add one negative test case for malformed JSON.

---

## 🧭 6. **Style & Consistency**

**❌ Poor comment:**

> Wrong formatting.

**✅ Excellent comment:**

> Nit: please run the linter — looks like the spacing here doesn’t match our style guide.

*(Short, polite “nit” comments are okay for style issues.)*

---

**❌ Poor comment:**

> This doesn’t follow convention.

**✅ Excellent comment:**

> Our naming convention for React hooks is `useX`. Could we rename `fetchData` to `useFetchData` to stay consistent with the rest of the codebase?

---

## ❤️ 7. **Positive Reinforcement**

**❌ Poor comment:**

> (no comment)

**✅ Excellent comment:**

> Great use of async/await here — it makes the flow much easier to follow.
> Nice catch handling the edge case for empty results!
> This refactor significantly simplifies the logic — great improvement 👏

✅ **Why it matters:** Acknowledging good work encourages collaboration and motivates better code.

---

## 🧩 8. **Tone Examples — Be Collaborative**

**Instead of this:**

> You should do X.

**Try this:**

> What do you think about doing X?
> Could we consider an alternative approach here?
> Would it make sense to handle this in the service layer instead of the controller?

This phrasing:

* Invites discussion, not commands.
* Encourages learning.
* Builds mutual respect.

---

### 💬 Example of a Full, High-Quality Comment

> Great work on this feature — I like how you’ve separated validation and persistence.
> One small suggestion: the `updateUserProfile` function currently logs an error but doesn’t return an error response to the caller.
> Could we return a structured error (e.g., `{ success: false, message: ... }`) instead? That would help clients handle it gracefully.

---
