# Task Workflow — BillingCube Dev Process

Reference document for the end-to-end process of working on a ClickUp task.

---

## 1. Read & Document the Task

1. Open the ClickUp task (parent + subtask if applicable)
   - **Option A:** Share the ClickUp link (e.g., `https://app.clickup.com/t/25526866/FS-XXXX`) — Claude can fetch task details via API
   - **Option B:** Copy-paste task content or share screenshot (for attachments, comments, custom fields with data)
2. Create a task file at `tasks/FS-XXXX.md` using the structure below
3. Include ClickUp links for both parent and subtask

> **Note:** ClickUp API provides: task metadata, parent description, status, assignee, tags. It does NOT provide: attachment contents (.msg, videos), technical analysis (requires code reading), or git/PR info.

**Minimum content for the task file:**
- Task info (ID, title, parent, status, assignee, due date, estimate, tags)
- ClickUp links
- Background & target audience (from parent)
- Functional requirements
- Acceptance criteria
- Git conventions (branch, commit, PR — see section 2)
- Open Points — list any ambiguities or missing info that need clarification before dev starts (e.g. AC/FR mismatch, missing sprint branch, unresolved dependencies). Resolve before coding; update the task file once answered.

---

## 2. Git Conventions

> **ID convention:** Branch uses the **subtask ID** (FS-XXXX). Commit/PR title includes **both subtask and parent IDs** (FS-XXXX, FS-YYYY) for traceability. Commit/PR titles use a `#` prefix on each ID (e.g. `#FS-XXXX, #FS-YYYY - ...`); **branch names have no `#` prefix.**

### Branch naming
Single task:
```
FS-XXXX_ShortPascalCaseDescription
```
Example: `FS-7897_AddFieldsInUserListing`

Bug/subtask related to a parent feature — include both IDs:
```
FS-XXXX_FS-YYYY_ShortPascalCaseDescription
```
Example: `FS-7966_FS-7896_FixSkipEmailSendingColumnPosition`

### Create branch (both repos if needed)

**Always branch off the current sprint branch — pull it first before creating your feature branch:**

```bash
git checkout PS_YYYYMMDD
git pull origin PS_YYYYMMDD
git checkout -b "FS-XXXX_ShortDescription"
```

### Commit message
```
#FS-XXXX - Short description of what was done
```
- Use the **task's own ID** (`#FS-XXXX`, with a `#` prefix) as the prefix
- If the task is a bug/subtask that also relates to a parent feature, include both IDs (each `#`-prefixed):
  ```
  #FS-XXXX, #FS-YYYY - Short description
  ```
  Example: `#FS-8213, #FS-8214, #FS-8199 - Add SG CAP form V2`
- Use a second commit for fixes found during testing, same ID rule applies

### PR title
```
#FS-XXXX - Short description
```
- Same ID rule as commit (including the `#` prefix on each ID): include parent ID if relevant
  Example: `#FS-7966, #FS-7896 - Fix Skip Email Sending column position in user listing`

### PR target branch
```
PS_YYYYMMDD  (current sprint branch, e.g. PS_20250727)
```

---

## 3. Explore the Codebase

Before making changes:
- Find the relevant component, service, and model files
- Understand the data flow (API → DTO → frontend binding)
- Check for pre-existing fields to avoid duplicates
- Note any dependencies on other tasks/features

---

## 3a. Prepare Test Cases (before coding)

Before writing any code, draft the test suite in the task file under a `## Test Cases` section. This forces clarity on the AC and gives QA a head start.

Include:
- **Pre-conditions** — environment, sprint branch, dependencies merged
- **Test data setup** — table of test users/records covering all field permutations (Yes/No, null, empty, edge values)
- **Functional test cases** — table with `ID | Title | Steps | Expected`, one row per AC item plus one per shifted/inserted column
- **Permission/role tests** — one case per role that can access the feature (e.g. LOCAL SYS ADMIN, SYS ADMIN)
- **Negative / edge cases** — nulls, empty strings, unicode, very long values, special chars
- **Regression checklist** — bullet list of pre-existing behaviour that must still work (file name, formatting, related pages unaffected)

Test case IDs use the pattern `TC-NN` and should be referenced in commit messages or PR descriptions when fixing issues found during testing.

### Automating with Playwright (`BO.BillingCube/e2e-playwright`)

When the change is verifiable end-to-end (UI flow, file download, API response), add a spec under `BO.BillingCube/e2e-playwright/tests/fs<XXXX>-<short>.spec.ts` mirroring the TC-NN cases. Reuse the existing auth state — `auth.setup.ts` saves to `playwright/.auth/user.json` once via Azure AD and is reused by all tests.

**Requires Node 18+.** The project default is Node 16 (for Angular CLI), but Playwright `@playwright/test@1.40.1` requires Node 18+. Switch before running:

```bash
nvm use 22
cd BO.BillingCube/e2e-playwright
npx playwright test fs<XXXX>-*.spec.ts --reporter=list
```

Switch back to Node 16 for Angular builds (`nvm use 16`).

For Excel export verification, parse the downloaded `.xlsx` with `exceljs` (already a devDependency) and assert headers, cell values, and formatting directly — do not rely on visual inspection.

### Selector pitfalls to avoid

- **Angular interpolation splits text nodes.** A label like `{{ "Total" | translate }} {{ count }} {{ "Results" | translate }}` is rendered as three sibling text nodes. Playwright's `:text-matches` is per-text-node, so `:text-matches("Total\\s+\\d+\\s+Results")` will never match. Use a parent locator + `.innerText()` (which concatenates child text) instead.
- **Stale selectors after sibling refactors.** When another task refactors a shared page (e.g. FS-7900 hiding the global keyword search on the user listing), specs that rely on the old DOM will silently match nothing and skip their setup. Always assert that the precondition state is reached (e.g. `await expect(input).toBeVisible()`) before proceeding, and re-run sibling specs after touching shared components.

---

## 4. Make Changes

- Stage **only task-related files** — do not stage unrelated modified files (e.g. `angular.json`, `config.json`, `appsettings.json`, `launchSettings.json`, `package-lock.json`)
- Both repos (`BO.BillingCube` and `BO.BillingCube-Backend`) get the **same branch name**

### Typical files touched per change type

| Change type | Frontend | Backend |
|---|---|---|
| Add listing columns | `setting-*.component.html` | Model, DTO, Repository query |
| Add form field | `setting-*-detail.component.html` + `.ts` | DTO, Repository save/update |
| New API endpoint | Service `.ts` | Controller, Service, Repository |

---

## 5. Lint (Frontend)

After coding is complete, run lint on the frontend and fix any errors introduced by the new changes:

```bash
cd BO.BillingCube
npm run lint
```

- Fix only errors in files you changed — do not fix pre-existing lint errors in unrelated files.
- Re-run after fixing to confirm the new errors are cleared.

---

## 6. Stage → Commit → Push

```bash
# Stage only relevant files
git add <file1> <file2>

# Commit
git commit -m "FS-XXXX - Description"

# Push
git push -u origin "FS-XXXX_ShortDescription"
```

Repeat for each repo.

---

## 7. Raise PRs on Azure DevOps

URLs:
- FE: `https://dev.azure.com/savills-asia/BO.BillingCube/_git/BO.BillingCube/pullrequests`
- BE: `https://dev.azure.com/savills-asia/BO.BillingCube/_git/BO.BillingCube-Backend/pullrequests`

**Required reviewer:** Vincent Lin (add as required reviewer on every PR)

> ⚠️ **Verify target branch before submitting.** Azure DevOps defaults new PRs to the repo's default branch (often `master`), **not** the current sprint branch. If you leave it as `master`, the PR diff will include the entire sprint's backlog of changes (hundreds of files) instead of just your commit. Always set the target to `PS_YYYYMMDD` before creating the PR. If you've already created one with the wrong target, abandon it and raise a new PR — Azure DevOps' "change target branch" option may reopen the diff against the wrong base.

**PR template:**
```
## Summary
- <bullet points of what was changed>

## Changes
**Frontend**
- <file>: <what changed>

**Backend**
- <file>: <what changed>

## Notes
- <any caveats, dependencies, follow-up tasks>

## ClickUp
- FS-XXXX: https://app.clickup.com/t/25526866/FS-XXXX
- FS-YYYY (parent): https://app.clickup.com/t/25526866/FS-YYYY
```

---

## 8. Update Task File

After each step, keep `tasks/FS-XXXX.md` up to date:

| Step completed | Update |
|---|---|
| Codebase explored | Add "Changes Made" section with file paths |
| Committed | Add commit hashes to git status table |
| Pushed | Mark pushed in git status table |
| PR raised | Add PR links to git status table |
| PR merged | Append ` — merged YYYY-MM-DD` to the PR cell |
| Status change | Update Status field in Task Info |

### Git status table (include in every task file)
```markdown
| Repo | Branch | Staged | Committed | Push | PR |
|---|---|---|---|---|---|
| `BO.BillingCube` | `FS-XXXX_...` | Yes | Yes (`abc1234`) | Yes | [PR #XXXXX](...) — merged YYYY-MM-DD |
| `BO.BillingCube-Backend` | `FS-XXXX_...` | Yes | Yes (`def5678`) | Yes | [PR #XXXXX](...) — merged YYYY-MM-DD |
```

---

## 9. Fill in ClickUp Fields

After dev is done, fill these fields on the ClickUp subtask:

| Field | Notes |
|---|---|
| Acceptance Criteria | Scope to dev deliverables |
| FS Module | Match parent task |
| Solution Proposed | Brief technical description |
| Impact Analysis | Which pages/modules are affected |
| Track time | Log actual time spent |
| Status | Change to **subtask done** |

---

## Task File Template

```markdown
# FS-XXXX — Dev (Subtask of FS-YYYY)

## Task Info
| Field | Value |
|---|---|
| ID | [FS-XXXX](https://app.clickup.com/t/25526866/FS-XXXX) |
| Title | Dev |
| Parent | [FS-YYYY](https://app.clickup.com/t/25526866/FS-YYYY) — <parent title> |
| Status | TO DO |
| Assignee | Pham Anh Nguyen Hong |
| Due Date | YYYY-MM-DD |
| Time Estimate | Xh |
| Priority | Low |
| Tags | api, frontend |

---

## Parent Task: FS-YYYY — <title>

### Background
<from parent task>

### Target Audience
<from parent task>

---

## Functional Requirements
<list>

---

## Acceptance Criteria
<list>

---

## Git Conventions

| | Value |
|---|---|
| **Branch (both repos)** | `FS-XXXX_ShortDescription` |
| **Commit** | `FS-XXXX - Description` |
| **PR title** | `FS-XXXX - Short title` |

| Repo | Branch | Staged | Committed | Push | PR |
|---|---|---|---|---|---|
| `BO.BillingCube` | `FS-XXXX_...` | No | No | No | — |
| `BO.BillingCube-Backend` | `FS-XXXX_...` | No | No | No | — |

**PR target branch:** `PS_YYYYMMDD`

---

## Changes Made
<fill after implementation>

---

## Notes
<caveats, dependencies>

---

## Related Tasks
<list>
```

---

## Working Checklist

Use this checklist when working on a task to ensure all steps are completed in order. Copy into the task file or use as a reference.

### Before coding
- [ ] Read ClickUp task (parent + subtask), understand AC and FR
- [ ] Create `tasks/FS-XXXX.md` using template (task info, background, FR, AC, git conventions, open points)
- [ ] Resolve all open points (sprint branch, backend scope, dependencies, ambiguities)
- [ ] Explore codebase — find relevant files, understand data flow, check for duplicates
- [ ] Draft test cases in task file (before writing code)
- [ ] Create feature branch from sprint branch (`git checkout PS_YYYYMMDD && git pull && git checkout -b "FS-XXXX_..."`)

### During coding
- [ ] Implement changes (TS, HTML, LESS/CSS, etc.)
- [ ] Run lint on changed files (`npm run lint` or `npx eslint <files>`) — fix only errors you introduced
- [ ] Create/update Playwright spec (`e2e-playwright/tests/fs<XXXX>-<short>.spec.ts`)
- [ ] Run Playwright tests — all must pass. **Requires Node 18+** (project default is Node 16; switch with `nvm use 22` before running):
  ```bash
  nvm use 22
  cd BO.BillingCube/e2e-playwright
  npx playwright test fs<XXXX>-*.spec.ts --reporter=list
  ```
  Auth state is reused from `playwright/.auth/user.json`. If expired, re-run `npm run auth` (headed browser, Azure AD login).

### After coding
- [ ] Update `tasks/FS-XXXX.md` — fill "Changes Made" section with file paths and descriptions
- [ ] Stage only task-related files (not `angular.json`, `config.json`, `package-lock.json`, etc.)
- [ ] Commit with message: `FS-XXXX - Short description`
- [ ] Push to remote: `git push -u origin "FS-XXXX_..."`
- [ ] Raise PR on Azure DevOps targeting sprint branch, add Vincent Lin as required reviewer
- [ ] Update `tasks/FS-XXXX.md` — add commit hash, PR link, mark pushed/PR in git status table

### Closing
- [ ] Fill ClickUp fields (Acceptance Criteria, FS Module, Solution Proposed, Impact Analysis, Track time)
- [ ] Change ClickUp subtask status to **subtask done**
