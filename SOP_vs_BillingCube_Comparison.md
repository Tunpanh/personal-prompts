# Comparison: Official SOP vs. BillingCube Project Practice

> **Date:** 2026-06-04
> **Purpose:** Compare the official Savills SOP with the actual BillingCube project workflow, **and provide an action plan to map BillingCube's git strategy onto the SOP**.
> **Verified:** 2026-06-04 — SOP claims re-checked against the four source artifacts in this folder: `Source Control & Release Process.pdf`, `PMO_Development_SOP.docx`, `PMO_Release Process_SOP.docx`, and the new **`SOP_git_branch_strategy.png`** (updated branch-strategy diagram). §1 and §4 have been updated to the **Release-branch** model shown in the new diagram, which **supersedes** the 2023 PDF's dedicated-per-environment-branch interpretation and closes most of the previously-reported gap. BillingCube-side claims (branch/commit examples) carry over from the prior verification — the project's `docs/` and `tasks/*.md` files are **not present in this folder**, so they were not re-checked this round.

---

## Source Documents

| **Official SOP (this folder)** | **Project Docs** |
|---|---|
| **`SOP_git_branch_strategy.png`** — **updated branch-strategy diagram (newest SOP artifact)**. Shows `Main (Front End)` → Feature `F#(BR)` → Working `W#(PBI)`, a `Bug` branch off Main, and a single **versioned `Release 1.0.1`** branch deployed to **Dev / QA / UAT**. This is the authoritative branching model used in §1/§4. | `docs/task-workflow.md`, `docs/CONVENTIONS.md`, `tasks/*.md` *(not present in this folder; carried over from prior verification)* |
| `Source Control & Release Process.pdf` (V1.0, 09 Feb 2023, Jignesh Parmar) — original branching model (Main / Feature / Working / **Environment** branches) & commit format. **Superseded on the env-branch point** by the PNG above. | |
| `PMO_Development_SOP.docx` (Savills Development SOP, V1.0, 03 Jul 2023 — Sprint governance & PBI statuses; §7.1 repeats the commit format `#D3-1234 Merge PBU` and points to the PDF for version control) | |
| `PMO_Release Process_SOP.docx` (V1.0, 03 Jul 2023, Cherry Wong — release/deployment governance: ClickUp Release Lists, release numbers `{ENV}-{Version}.{Release#}`, status-driven *Promote to UAT*, CAB approval, Tech-Lead deployment) | |

> **`BR` = Business Request, `PBI` = Product Backlog Item.** In ClickUp a Business Request contains one or more PBIs — the diagram's `F#(BR)` (Feature) / `W#(PBI)` (Working) hierarchy mirrors that parent/child relationship.

---

## 1. Branching Model

### Official SOP

| Branch Type | Description |
|---|---|
| **Main / Master** (`Main (Front End)`) | Latest **Live / production** code base; source for Feature and Bug branches |
| **Feature Branch** (`F#(BR)`) | One per **Business Request** — entire Module / ad-hoc CR. Minor enhancements may use the Feature branch directly, without Working branches |
| **Working Branch** (`W#(PBI)`) | Created under a Feature Branch for large-scale modules — one per **PBI** under that Business Request; synced with the Feature branch over time |
| **Bug Branch** (`Bug 1`) | Bug / hotfix branch taken directly off Main |
| **Release Branch** (`Release 1.0.1`) | **(updated SOP)** Single **versioned** integration branch that gathers ready Features and is **deployed to the Dev / QA / UAT environments**. Version follows the Release Process SOP convention (`{Version}.{Release#}`). **Replaces** the 2023 PDF's dedicated-branch-per-environment idea |

> The 2023 PDF listed a dedicated **Environment Branch** per environment (Dev/QA/UAT/Prod). The newer `SOP_git_branch_strategy.png` consolidates those into the single **Release branch → Dev/QA/UAT** model below, with **Main = production**.

**Flow (per `SOP_git_branch_strategy.png`):**
```
Main (Front End)          ← Live / production code base
  ├── F1 (BR)             ← Feature branch, one per Business Request
  │     ├── W1 (PBI 1)    ← Working branch per PBI
  │     └── W2 (PBI 2)
  ├── F2 (BR)
  ├── Bug 1               ← bug / hotfix off Main
  └── Release 1.0.1       ← versioned Release / integration branch
         └──► Dev | QA | UAT     (deployed to each environment; Main = Prod)
```

### Project Practice (BillingCube)

| Branch Type | Description |
|---|---|
| **master** | Live production code |
| **PS_YYYYMMDD** (Sprint Branch) | Current sprint; acts as integration branch for all PRs |
| **FS-XXXX_Description** (Feature Branch) | Per-task feature branch, created from sprint branch |

**Actual Flow:**
```
master
  └── PS_20250727 (Sprint Branch)
       ├── FS-8228_FS-8227_AddCSLogIRIntegrationPanel
       ├── FS-8203_FS-8202_SGCapFormVersioning
       └── FS-8072_FS-8071_IrSummaryDashboard
```

### Differences

| Aspect | SOP (updated) | Project Practice | Gap |
|---|---|---|---|
| Integration branch | **`Release 1.0.1`** — versioned branch → Dev/QA/UAT | **`PS_YYYYMMDD`** — dated sprint branch (integrates PRs, tested in QA) | **Now aligned in shape** — both use one integration branch; differs only in **naming/versioning** (versioned Release vs. dated Sprint) |
| Branch hierarchy | Main → Feature `(BR)` → Working `(PBI)` | master → Sprint → flat per-task feature branch | **Project skips the Feature(BR)/Working(PBI) two-tier grouping** |
| Deployment targets | Release branch → **Dev + QA + UAT**; Main = Prod | Sprint → **QA**; master = Prod (Dev/UAT not documented) | **Project documents QA only** |
| Hotfix path | `Bug` branch off Main | Not clearly documented | **Gap** — define a hotfix-off-master path |
| Branch naming | `F#(BR)` / `W#(PBI)` / `Release {ver}` | `FS-XXXX_Description` (task ID + PascalCase) | Both are structured; names differ |

---

## 2. Commit Message Format

### Official SOP

**Format:** `#<Custom Task Id> <Commit Message>`

**Example:** `#D3-999 My DevOps commit message`

- Uses `#` prefix before task ID
- Links DevOps commit to ClickUp task via Custom Task ID

### Project Practice

**Format:** `#FS-XXXX - Description` or `#FS-XXXX, #FS-YYYY - Description`

**Examples from task files:**
- `#FS-8228, #FS-8227 - Add CS log processed error in IR integration panel`
- `#FS-8203, #FS-8202 - Add SG CAP form versioning`
- `#FS-8072, #FS-8071 - IR summary dashboard enhancement`

### Differences

| Aspect | SOP | Project Practice | Gap |
|---|---|---|---|
| Format | `#TaskId Message` (space) | `#TaskId - Message` (dash separator) | **Different** — Project adds ` - ` separator |
| Multiple IDs | Not mentioned | `#FS-XXXX, #FS-YYYY - Description` | Project extends for parent+subtask linking |
| Task ID prefix | Generic (e.g., `D3-999`) | BillingCube uses `FS-XXXX` | Consistent with ClickUp custom IDs |

---

## 3. Branch Creation Flow

### Official SOP

1. Create Feature Branch from **Main/Master**
2. (Optional) Create Working Branches under Feature for large modules
3. Sync Working Branch with Feature Branch periodically
4. Ensure Main Branch changes synced before Production Deployment

### Project Practice

From `task-workflow.md`:
```bash
git checkout PS_YYYYMMDD      # Sprint branch (NOT master)
git pull origin PS_YYYYMMDD
git checkout -b "FS-XXXX_ShortDescription"
```

### Differences

| Aspect | SOP | Project Practice | Gap |
|---|---|---|---|
| Base branch | **master** | **PS_YYYYMMDD** (sprint branch) | **Different** — Sprint branch isolates sprint work |
| Pre-prod sync | Sync Main changes to Working Branch | Sprint branch merged to master after QA | Similar outcome via different mechanism |

---

## 4. Environment Deployment Flow

### Official SOP — updated model (`SOP_git_branch_strategy.png`)

The newest SOP artifact replaces the four dedicated environment branches with **one versioned Release branch** that is deployed out to each environment:
```
Main (Front End)  ───────────────────────────►  (Live / Production)
   │
   └── Release 1.0.1 ──┬──► Dev   environment
                       ├──► QA    environment
                       └──► UAT   environment
```
- A single **`Release {Version}.{Release#}`** branch is the deployable integration point; it is rolled out to Dev, QA and UAT (deployments fan out **in parallel** — *not* a chained `Dev→QA→UAT` branch-to-branch promotion).
- **Main = production**: once a release passes UAT and CAB approval, it merges to Main / goes Live.
- Release promotion across environments is still governed by `PMO_Release Process_SOP.docx` — ClickUp statuses *QA Verified → Promote to UAT → Ready to UAT → UAT Verified*, CAB approval (ServiceNow), and Tech-Lead deployment.

> **Earlier 2023 PDF model (superseded on this point):** the PDF showed a *dedicated branch per environment* (Dev/QA/UAT/Prod), each fed independently from the Feature/Module & Hotfix branches — *"it'd be possible to rollout Feature Branch change independently to specific Environment."* The updated diagram consolidates these into the single Release-branch model above.

### Project Practice

Observable pattern:
```
Feature Branch → PR to Sprint Branch → Sprint tested in QA → Sprint merged to master → Prod deploy
```

- One integration branch (`PS_YYYYMMDD`) — same shape as the SOP Release branch
- Sprint branch serves as the integration point; tested in QA, merged to master for prod
- Azure DevOps URLs for PR target: `dev.azure.com/savills-asia/BO.BillingCube`

### Differences (vs. updated SOP)

| Aspect | SOP (updated) | Project Practice | Gap |
|---|---|---|---|
| Integration branch | Versioned **Release** branch deployed to Dev/QA/UAT | **Sprint** branch (`PS_YYYYMMDD`) integrating PRs | **Aligned in shape** — naming/versioning only |
| Environments fed | Dev + QA + UAT from the Release branch; Main = Prod | QA from the sprint branch; master = Prod | **Partial** — document/automate Dev + UAT deploys |
| Hotfix path | `Bug` branch off Main | Not clearly documented | **Gap** — define a hotfix-off-master path |

---

## 5. PR Target Branch

### Official SOP

Not explicitly specified in the PDF (focus is on branch types, not PR mechanics).

### Project Practice

From `task-workflow.md`:
> **Verify target branch before submitting.** Azure DevOps defaults new PRs to the repo's default branch (often `master`), **not** the current sprint branch. If you leave it as `master`, the PR diff will include the entire sprint's backlog...

**PR target:** `PS_YYYYMMDD` (current sprint branch)

### Differences

| Aspect | SOP | Project Practice | Gap |
|---|---|---|---|
| PR target | Not specified | Sprint branch (`PS_YYYYMMDD`) | Project adds explicit guidance |

---

## 6. Working Branch Sync

### Official SOP

> "Sync Working Branch time to time from Feature Branch."
> "Ensure to sync Main Branch changes to Working Branch, has been created before Production Deployment."

### Project Practice

- No Working Branches used
- Feature branches are short-lived (1 task = 1 branch)
- No documented sync process needed

### Differences

| Aspect | SOP | Project Practice | Gap |
|---|---|---|---|
| Working Branch | Used for large modules | **Not used** | Project simplifies |
| Sync requirement | Feature → Working periodically | N/A (no Working branches) | N/A |

---

## Action Plan: Map BillingCube Git Strategy → SOP

**Goal:** evolve the current sprint-based BillingCube workflow so it maps onto the updated SOP branch-strategy (`SOP_git_branch_strategy.png`) while keeping what already conforms. **The new SOP's Release-branch model is structurally the same as BillingCube's sprint-branch model**, so this is mostly a *naming + grouping + documentation* exercise — **not a re-architecture**.

### A. Element mapping (SOP → BillingCube)

| SOP element (`SOP_git_branch_strategy.png`) | BillingCube today | Mapping action |
|---|---|---|
| `Main (Front End)` — Live / prod | `master` | ✅ Already equivalent — keep `master` as production |
| `Release 1.0.1` — versioned integration branch → Dev/QA/UAT | `PS_YYYYMMDD` — dated sprint integration branch | Treat the sprint branch **as** the Release branch. Attach a Release version (`{Version}.{Release#}`, e.g. `1.0.1`) per `PMO_Release Process_SOP.docx`. Either rename to `Release_<version>` or keep `PS_` and carry the version in the ClickUp Release List |
| `F#(BR)` — Feature branch per **Business Request** | *(none — tasks branch straight off the sprint)* | Introduce a **Feature branch per Business Request** that groups its child tasks, branched from the Release/sprint branch |
| `W#(PBI)` — Working branch per **PBI** | `FS-XXXX_Description` — one per task | Re-cast per-task `FS-XXXX` branches as **Working branches under their Feature(BR)** for multi-PBI work; small standalone items may still branch directly (SOP allows this) |
| `Bug 1` — bug / hotfix off Main | *(not documented)* | Define a **hotfix branch off `master`** for production bugs |
| Release → **Dev / QA / UAT** | Sprint tested in **QA** only | Document (and where possible automate via Azure Pipelines) **Dev, QA and UAT** deploys from the Release/sprint branch |
| Commit `#<TaskId> <msg>` (space) | `#FS-XXXX - <msg>` (dash) | Drop the ` - ` separator → `#FS-8228, #FS-8227 Add CS log...` to match `#D3-1234 Merge PBU` |

### B. Phased rollout

1. **Phase 1 — Low-effort conformance (do now)**
   - Adopt commit format `#<TaskId> <message>` (remove the ` - `); update `docs/task-workflow.md` and `docs/CONVENTIONS.md`.
   - Attach a Release version (`{Version}.{Release#}`) to each sprint in the ClickUp Release List so the sprint branch is traceable as a Release.
2. **Phase 2 — Branch hierarchy**
   - For multi-task Business Requests, create a **Feature branch `F<BR-id>_…`** and move related `FS-XXXX` task branches under it as **Working branches**; PR Working → Feature, then Feature → Release.
   - Keep the direct-to-sprint path for genuinely small / standalone items (SOP-permitted).
3. **Phase 3 — Release branch & environments**
   - Relabel the sprint branch to the Release model and wire **Dev / QA / UAT** deployments from it in Azure DevOps Pipelines.
   - Define the **hotfix-off-master** branch + fast-track release path.
4. **Phase 4 — Governance alignment**
   - Map the existing PR/QA flow to the ClickUp statuses *QA Verified → Promote to UAT → Ready to UAT → UAT Verified* and the CAB-approval + Tech-Lead-deployment steps from `PMO_Release Process_SOP.docx`.

### C. Required documentation to update

| Doc | Change |
|---|---|
| `docs/task-workflow.md` | New branch hierarchy (Feature/BR → Working/PBI → Release), commit format, PR targets, env-deploy steps |
| `docs/CONVENTIONS.md` | Branch-naming + commit-message conventions aligned to the SOP |
| ClickUp Release List | Release version per sprint; UAT/Prod release numbers, CAB date, Tech/QA lead |
| Azure Pipelines | Dev / QA / UAT deploy definitions from the Release branch |

---

## Recommendation

The 2023 PDF made BillingCube look divergent (dedicated env branches vs. a single sprint branch). The **updated SOP diagram (`SOP_git_branch_strategy.png`) closes most of that gap** — its versioned **Release branch → Dev/QA/UAT** model is structurally the same integration-branch pattern BillingCube already uses. BillingCube's remaining work is to:

1. Map its **sprint branch ↔ the SOP Release branch** (add release versioning)
2. Add the **Feature(BR) → Working(PBI)** grouping for multi-task Business Requests
3. Document **Dev / UAT** deploys and a **hotfix-off-master** path
4. Align the **commit format** (drop the ` - `)

See the **Action Plan** above for the concrete mapping and phased steps.

### Key Gaps That May Need Alignment (vs. updated SOP)

| Gap | Severity | Notes |
|---|---|---|
| Integration-branch model | **Low** (was High) | Updated SOP's single **Release branch → Dev/QA/UAT** matches BillingCube's **sprint branch**. Only naming/versioning differs — no re-architecture |
| Feature(BR)/Working(PBI) two-tier hierarchy | **Medium** | Project branches tasks flat off the sprint; SOP groups Working(PBI) under a Feature(BR). Affects coordination of multi-task Business Requests |
| Dev + UAT environment deploys | **Medium** | SOP deploys the Release branch to Dev/QA/UAT; project documents QA only |
| Hotfix-off-master path | **Medium** | SOP shows a `Bug` branch off Main; project path undocumented |
| Commit message format | **Low** | Minor ` - ` separator difference |

### Options

**Option A: Full SOP alignment (recommended target)**
- Map the sprint branch to a versioned **Release branch** with Dev/QA/UAT deploys
- Add the **Feature(BR) → Working(PBI)** hierarchy for multi-task Business Requests
- Define the **hotfix-off-master** path
- Drop the ` - ` separator in commit messages
- *(This is the **Action Plan** above.)*

**Option B: Document as an approved adaptation**
- Formalize the current sprint workflow as the "BillingCube Development Process"
- Record it as an approved adaptation of the SOP (sprint branch = Release branch), noting the few intentional differences

**Option C: Feed back into the SOP**
- The updated SOP already moved toward BillingCube's integration-branch model; propose folding BillingCube's explicit guidance (PR target, multi-ID commits, task-file tracking) back into the official SOP

---

## Appendix: Branch Naming Examples

### SOP Example (per `SOP_git_branch_strategy.png`)
```
Main (Front End)              # = Live / production
├── F1 (BR)                   # Feature branch — Business Request
│   ├── W1 (PBI 1)            # Working branch — PBI
│   └── W2 (PBI 2)
├── F2 (BR)
├── Bug 1                     # hotfix off Main
└── Release 1.0.1             # versioned Release branch
        └──► Dev | QA | UAT   # environment deployments
```

### BillingCube Example (Actual)
```
master
└── PS_20250727
    ├── FS-8228_FS-8227_AddCSLogIRIntegrationPanel
    ├── FS-8203_FS-8202_SGCapFormVersioning
    ├── FS-8072_FS-8071_IrSummaryDashboard
    ├── FS-8080_FS-8079_IrListPageSummaryDashboard
    └── FS-8074_FS-8071_PsListPageSummaryDashboard
```

---

## Appendix: Commit Message Examples

### SOP Format
```
#D3-999 My DevOps commit message      (PDF, Points of Consideration)
#D3-1234 Merge PBU                     (PMO_Development_SOP.docx §7.1)
#FS-8228 Add CS log processed error
```

### BillingCube Format
```
#FS-8228, #FS-8227 - Add CS log processed error in IR integration panel
#FS-8203, #FS-8202 - Add SG CAP form versioning
#FS-8072, #FS-8071 - IR summary dashboard enhancement
```

---

## Appendix: Task File Structure (BillingCube Addition)

The project adds detailed task documentation not mentioned in SOP:

```
tasks/
├── FS-8228.md    # Full task documentation
├── FS-8203.md    # Including git status tracking
├── FS-8072.md    # Test cases, changes made
└── ...
```

Each task file includes:
- Task Info (ID, parent, status, assignee, due date)
- Functional Requirements
- Acceptance Criteria
- Git Conventions (branch, commit, PR)
- Open Points (resolved before coding)
- Technical Analysis
- Changes Made (file-by-file)
- Test Cases
- Related Tasks

This level of documentation exceeds SOP requirements and provides traceability.
