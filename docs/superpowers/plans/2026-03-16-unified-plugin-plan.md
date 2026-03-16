# Claude Stack Unified Plugin - Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a single Claude Code plugin (`claude-stack`) that unifies 18 tools into 27 skills, 12 agents (+4 subagent templates), 6 hooks, 8 rules.

**Architecture:** Layered single plugin. Skills grouped by phase (_core, _quality, _ship, _browser, _auto). Shared protocols in lib/. Templates for project scaffolding. Browser binary lazy-downloaded.

**Tech Stack:** Claude Code Plugin API (SKILL.md frontmatter + markdown), shell hooks, Playwright MCP for browser.

**Spec:** `docs/superpowers/specs/2026-03-16-unified-plugin-design.md`

---

## File Structure

```
claude-stack/
├── .claude-plugin/plugin.json
├── CLAUDE.md
├── skills/_core/s-new/SKILL.md          # /s:new
├── skills/_core/s-discuss/SKILL.md      # /s:discuss
├── skills/_core/s-plan/SKILL.md         # /s:plan
├── skills/_core/s-build/SKILL.md        # /s:build
├── skills/_core/s-status/SKILL.md       # /s:status
├── skills/_core/s-resume/SKILL.md       # /s:resume
├── skills/_core/s-pause/SKILL.md        # /s:pause
├── skills/_core/s-note/SKILL.md         # /s:note
├── skills/_quality/s-brainstorm/SKILL.md
├── skills/_quality/s-review/SKILL.md
├── skills/_quality/s-verify/SKILL.md
├── skills/_quality/s-debug/SKILL.md
├── skills/_quality/s-ceo-review/SKILL.md
├── skills/_quality/s-eng-review/SKILL.md
├── skills/_ship/s-ship/SKILL.md
├── skills/_ship/s-compound/SKILL.md
├── skills/_ship/s-retro/SKILL.md
├── skills/_ship/s-docs/SKILL.md
├── skills/_browser/s-qa/SKILL.md
├── skills/_browser/s-qa-only/SKILL.md
├── skills/_browser/s-browse/SKILL.md
├── skills/_browser/s-cookies/SKILL.md
├── skills/_auto/s-auto/SKILL.md
├── skills/_auto/s-quick/SKILL.md
├── skills/_auto/s-do/SKILL.md
├── skills/_auto/s-map/SKILL.md
├── skills/_auto/s-help/SKILL.md
├── agents/architect.md
├── agents/code-reviewer.md
├── agents/security-reviewer.md
├── agents/database-reviewer.md
├── agents/tdd-guide.md
├── agents/qa-engineer.md
├── agents/frontend-dev.md
├── agents/backend-dev.md
├── agents/mobile-dev.md
├── agents/debugger.md
├── agents/performance-eng.md
├── agents/deployment-eng.md
├── agents/subagent-templates/implementer-prompt.md
├── agents/subagent-templates/spec-reviewer-prompt.md
├── agents/subagent-templates/code-quality-reviewer-prompt.md
├── agents/subagent-templates/plan-reviewer-prompt.md
├── hooks/hooks.json
├── rules/uncodixfy.md
├── rules/tdd.md
├── rules/verification.md
├── rules/debugging.md
├── rules/context-persist.md
├── rules/ask-user.md
├── rules/quality.md
├── rules/confidence.md
├── templates/planning/PROJECT.md
├── templates/planning/REQUIREMENTS.md
├── templates/planning/ROADMAP.md
├── templates/planning/STATE.md
├── templates/planning/phase/CONTEXT.md
├── templates/planning/phase/PLAN.md
├── templates/planning/phase/RESEARCH.md
├── templates/planning/phase/SUMMARY.md
├── templates/planning/phase/DISCOVERY.md
├── templates/planning/phase/VALIDATION.md
├── templates/planning/phase/UI-SPEC.md
├── templates/planning/phase/UAT.md
├── templates/docs/brainstorms/.gitkeep
├── templates/docs/plans/.gitkeep
├── templates/docs/solutions/.gitkeep
├── lib/context-system.md
├── lib/tdd-protocol.md
├── lib/verification-protocol.md
├── lib/review-protocol.md
├── lib/debug-protocol.md
├── lib/agent-dispatch.md
├── lib/visual-companion.md
├── lib/defense-in-depth.md
├── lib/root-cause-tracing.md
├── lib/find-polluter.sh
├── bin/setup-browser.sh
└── README.md
```

---

## Chunk 1: Foundation Scaffold (Phase 1a)

### Task 1: Plugin Metadata

**Files:**
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Create plugin.json**

```json
{
  "name": "claude-stack",
  "version": "1.0.0",
  "description": "Unified development workflow: 29 skills, 12 agents, 6 hooks. Replaces GSD + Superpowers + Compound + gstack.",
  "author": { "name": "bdarbaz" },
  "repository": "https://github.com/bdarbaz/claude-stack-plugin",
  "license": "MIT",
  "keywords": ["workflow", "tdd", "debugging", "code-review", "project-management"]
}
```

- [ ] **Step 2: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add plugin.json metadata"
```

---

### Task 2: Shared Protocols (lib/)

**Files:**
- Create: `lib/context-system.md`
- Create: `lib/tdd-protocol.md`
- Create: `lib/verification-protocol.md`
- Create: `lib/review-protocol.md`
- Create: `lib/debug-protocol.md`
- Create: `lib/agent-dispatch.md`

- [ ] **Step 1: Write context-system.md**

Context persistence protocol. Covers:
- .planning/ directory structure and purpose
- docs/ directory structure and purpose
- STATE.md update rules (who updates, when, format)
- Session resume protocol (what to read first)
- Never-delete rules

Source: GSD's context system + Compound's docs/ pattern. Merge both.

- [ ] **Step 2: Write tdd-protocol.md**

TDD protocol. Covers:
- Iron Law: no prod code without failing test
- RED > GREEN > REFACTOR cycle
- Test file naming convention
- When to commit (after each GREEN)
- What counts as "minimal implementation"

Source: Superpowers TDD skill + wshobson tdd-red/tdd-green.

- [ ] **Step 3: Write verification-protocol.md**

Verification protocol. Covers:
- Evidence table format (claim | evidence | command | result)
- No completion claims without fresh evidence
- What counts as evidence (test output, screenshot, curl response)
- Verification checklist template

Source: Superpowers verification-before-completion.

- [ ] **Step 4: Write review-protocol.md**

Review protocol. Covers:
- 5 review aspects: plan alignment, code quality, architecture, security, docs
- Multi-perspective approach (CEO view, eng view, security view)
- Review output format
- When to dispatch which reviewer agent

Source: Superpowers code-reviewer + gstack /review + Compound ce-review.

- [ ] **Step 5: Write debug-protocol.md**

Debug protocol. Covers:
- 4 phases: Root Cause Analysis > Hypothesis > Test > Fix
- No guessing rule
- Defense-in-depth approach
- find-polluter script reference

Source: Superpowers systematic-debugging.

- [ ] **Step 6: Write agent-dispatch.md**

Agent dispatch protocol. Covers:
- When to use split-pane teammate vs subagent
- Agent selection guide (which agent for which task)
- Teammate communication protocol
- File conflict avoidance rules

Source: CLAUDE.md agent team rules.

- [ ] **Step 7: Write visual-companion.md, defense-in-depth.md, root-cause-tracing.md**

Superpowers sub-files adapted for unified plugin:
- `visual-companion.md` ← brainstorming/visual-companion.md
- `defense-in-depth.md` ← systematic-debugging/defense-in-depth.md
- `root-cause-tracing.md` ← systematic-debugging/root-cause-tracing.md

- [ ] **Step 8: Write find-polluter.sh**

Test pollution finder script from Superpowers systematic-debugging.
Source: superpowers/skills/systematic-debugging/find-polluter.sh

- [ ] **Step 9: Commit**

```bash
git add lib/
git commit -m "feat: add shared protocol library (10 files: 6 protocols + 4 assets)"
```

---

### Task 3: Templates

**Files:**
- Create: `templates/planning/PROJECT.md`
- Create: `templates/planning/REQUIREMENTS.md`
- Create: `templates/planning/ROADMAP.md`
- Create: `templates/planning/STATE.md`
- Create: `templates/planning/phase/CONTEXT.md`
- Create: `templates/planning/phase/PLAN.md`
- Create: `templates/planning/phase/RESEARCH.md`
- Create: `templates/planning/phase/SUMMARY.md`
- Create: `templates/planning/phase/DISCOVERY.md`
- Create: `templates/planning/phase/VALIDATION.md`
- Create: `templates/planning/phase/UI-SPEC.md`
- Create: `templates/planning/phase/UAT.md`
- Create: `templates/docs/brainstorms/.gitkeep`
- Create: `templates/docs/plans/.gitkeep`
- Create: `templates/docs/solutions/.gitkeep`

- [ ] **Step 1: Write planning templates**

Each template has placeholder sections with comments explaining what goes where.
Source: GSD's .planning/ file formats.

PROJECT.md template:
```markdown
# {PROJECT_NAME}

## Vision
{One paragraph: what is this project and why does it exist?}

## Core Values
- {Value 1}
- {Value 2}

## Constraints
- {Technical constraint}
- {Business constraint}

## Tech Stack
- {Language/framework}

## Created
{DATE}
```

REQUIREMENTS.md template:
```markdown
# Requirements

## Functional
| ID | Requirement | Acceptance Criteria | Status |
|----|-------------|---------------------|--------|
| R1 | {requirement} | {criteria} | pending |

## Non-Functional
| ID | Requirement | Metric | Status |
|----|-------------|--------|--------|
| NF1 | {requirement} | {metric} | pending |
```

ROADMAP.md template:
```markdown
# Roadmap

## Phase 1: {Name}
**Goal:** {one sentence}
**Success Criteria:** {measurable}
**Tasks:**
- [ ] {task 1}
- [ ] {task 2}

## Phase 2: {Name}
...
```

STATE.md template:
```markdown
# Project State

**Status:** initialized
**Active Phase:** -
**Last Updated:** {DATE}

## Current Focus
Project just created. Run `/s:discuss` to define requirements.

## Decisions
| Date | Decision | Rationale |
|------|----------|-----------|
| {DATE} | Project created | - |

## Blockers
None.
```

Phase templates (CONTEXT.md, PLAN.md, RESEARCH.md, SUMMARY.md): minimal headers with section placeholders.

- [ ] **Step 2: Create docs templates**

```bash
mkdir -p templates/docs/brainstorms templates/docs/plans templates/docs/solutions
touch templates/docs/brainstorms/.gitkeep templates/docs/plans/.gitkeep templates/docs/solutions/.gitkeep
```

- [ ] **Step 3: Commit**

```bash
git add templates/
git commit -m "feat: add project scaffolding templates"
```

---

### Task 4: Hooks

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: Write hooks.json**

6 hooks merged into one file. See spec section 5 for exact content.
Events: SessionStart, PreToolUse (tdd-check), PostToolUse (lint/format), PreCompact (snapshot), Stop (reminder).

All commands must be sh-compatible (no bash-specific syntax).
Test each command standalone before adding.

- [ ] **Step 2: Test hooks locally**

```bash
# Test session-start hook
sh -c 'if [ -f .planning/STATE.md ]; then head -15 .planning/STATE.md; fi'

# Test post-edit hook (with a dummy file)
sh -c 'filepath="test.ts"; ext="${filepath##*.}"; echo "Extension: $ext"'
```

- [ ] **Step 3: Commit**

```bash
git add hooks/
git commit -m "feat: add 6 merged hooks (session, tdd, lint, compact, stop)"
```

---

### Task 5: Rules

**Files:**
- Create: `rules/uncodixfy.md`
- Create: `rules/tdd.md`
- Create: `rules/verification.md`
- Create: `rules/debugging.md`
- Create: `rules/context-persist.md`
- Create: `rules/ask-user.md`
- Create: `rules/quality.md`
- Create: `rules/confidence.md`

- [ ] **Step 1: Write all 8 rule files**

Each rule file is a concise markdown with:
- Title
- Rules (numbered list)
- Examples (when applicable)

Sources:
- `uncodixfy.md` ← Uncodixfy's 33 categories + 24 hard-no + palettes
- `tdd.md` ← lib/tdd-protocol.md summary + enforcement rules
- `verification.md` ← lib/verification-protocol.md summary
- `debugging.md` ← lib/debug-protocol.md summary
- `context-persist.md` ← Never delete .planning/ or docs/
- `ask-user.md` ← gstack's Re-ground > Simplify > Recommend > Options
- `quality.md` ← No `any` type, no emoji icons, Lucide/Heroicons, code standards
- `confidence.md` ← Confidence score before decisions (1-10 scale)

- [ ] **Step 2: Commit**

```bash
git add rules/
git commit -m "feat: add 8 rule sets (uncodixfy, tdd, verification, debugging, context, ask-user, quality, confidence)"
```

---

### Task 6: Plugin CLAUDE.md

**Files:**
- Create: `CLAUDE.md` (plugin root - different from project CLAUDE.md)

- [ ] **Step 1: Write plugin CLAUDE.md**

This is auto-loaded by Claude Code when plugin is active. Content:
- Skill usage order (workflow hierarchy)
- Reference to all rules/ files
- Agent dispatch rules
- Context persistence rules
- Skill chaining suggestions (each skill suggests next)
- Yasaklar (prohibitions list)

Keep under 200 lines. Reference lib/ and rules/ instead of duplicating.

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add plugin CLAUDE.md with workflow rules"
```

---

## Chunk 2: Core Skills (Phase 1b)

### Task 7: /s:new skill

**Files:**
- Create: `skills/_core/s-new/SKILL.md`

- [ ] **Step 1: Write SKILL.md frontmatter**

```yaml
---
name: s-new
description: "Initialize a new project with .planning/ and docs/ structure, CLAUDE.md, and git repo"
---
```

- [ ] **Step 2: Write skill body**

Skill instructions:
1. Ask project name and one-line description
2. Create .planning/ by copying from `{CLAUDE_PLUGIN_ROOT}/templates/planning/`
3. Create docs/ by copying from `{CLAUDE_PLUGIN_ROOT}/templates/docs/`
4. Generate CLAUDE.md for the project (tech stack, rules references)
5. `git init` if not already a repo
6. Initial commit
7. Update STATE.md with "Project created"
8. Suggest: "Run `/s:discuss` to define requirements"

- [ ] **Step 3: Commit**

```bash
git add skills/_core/s-new/
git commit -m "feat: add /s:new skill - project initialization"
```

---

### Task 8: /s:discuss skill

**Files:**
- Create: `skills/_core/s-discuss/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Skill instructions:
1. Read .planning/PROJECT.md for context
2. Ask questions one at a time (GSD discuss-phase style)
3. Focus: functional requirements, non-functional requirements, constraints, success criteria
4. Write results to .planning/REQUIREMENTS.md (ID'd requirements with acceptance criteria)
5. Update STATE.md
6. Suggest: "Run `/s:plan` to create implementation roadmap"

Source: GSD /gsd:discuss-phase workflow.

- [ ] **Step 2: Commit**

```bash
git add skills/_core/s-discuss/
git commit -m "feat: add /s:discuss skill - requirements gathering"
```

---

### Task 9: /s:plan skill

**Files:**
- Create: `skills/_core/s-plan/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Skill instructions:
1. Read .planning/REQUIREMENTS.md
2. Brainstorm architecture (2-3 approaches, recommend one)
3. Break into phases with tasks
4. Write .planning/ROADMAP.md
5. Create .planning/phases/1/PLAN.md for first phase
6. Update STATE.md (active phase = 1)
7. Reference lib/tdd-protocol.md for task structure
8. Suggest: "Run `/s:build` to start implementing phase 1"

Source: GSD /gsd:plan-phase + Superpowers writing-plans + Compound /ce-plan merged.

- [ ] **Step 2: Commit**

```bash
git add skills/_core/s-plan/
git commit -m "feat: add /s:plan skill - roadmap and phase planning"
```

---

### Task 10: /s:build skill

**Files:**
- Create: `skills/_core/s-build/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Skill instructions:
1. Read .planning/STATE.md for active phase
2. Read .planning/phases/N/PLAN.md for current tasks
3. For each task, enforce TDD (reference lib/tdd-protocol.md):
   - Write failing test (RED)
   - Implement minimal code (GREEN)
   - Refactor
   - Commit
4. Update STATE.md after each task completion
5. When phase complete, write .planning/phases/N/SUMMARY.md
6. Suggest: "Run `/s:review` to review the implementation"

Source: GSD /gsd:execute-phase + Superpowers test-driven-development.

- [ ] **Step 2: Commit**

```bash
git add skills/_core/s-build/
git commit -m "feat: add /s:build skill - TDD implementation"
```

---

### Task 11: /s:status, /s:resume, /s:pause, /s:note skills

**Files:**
- Create: `skills/_core/s-status/SKILL.md`
- Create: `skills/_core/s-resume/SKILL.md`
- Create: `skills/_core/s-pause/SKILL.md`
- Create: `skills/_core/s-note/SKILL.md`

- [ ] **Step 1: Write /s:status**

Read STATE.md + ROADMAP.md + git log. Show: active phase, completed tasks, blockers, recent commits.

- [ ] **Step 2: Write /s:resume**

Read STATE.md + last 3 brainstorms/plans/solutions. Reconstruct context. Show summary + suggest next action.

- [ ] **Step 3: Write /s:pause**

Save current work state to STATE.md. Note what was in progress. Create .continue-here.md with resume instructions.

- [ ] **Step 4: Write /s:note**

Add timestamped note to STATE.md decisions table. Quick capture without ceremony.

- [ ] **Step 5: Commit**

```bash
git add skills/_core/s-status/ skills/_core/s-resume/ skills/_core/s-pause/ skills/_core/s-note/
git commit -m "feat: add utility skills (status, resume, pause, note)"
```

---

## Chunk 3: Quality Skills (Phase 2)

### Task 12: /s:brainstorm skill

**Files:**
- Create: `skills/_quality/s-brainstorm/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Merged skill from Superpowers brainstorming + Compound ce-brainstorm:
1. Explore context (files, docs, commits)
2. Ask clarifying questions (one at a time, multiple choice preferred)
3. Propose 2-3 approaches with trade-offs
4. Get user approval
5. Save to docs/brainstorms/YYYY-MM-DD-{topic}.md
6. Update STATE.md
7. Suggest: "Run `/s:plan` to create implementation plan"

HARD-GATE: No code until design approved.

- [ ] **Step 2: Commit**

```bash
git add skills/_quality/s-brainstorm/
git commit -m "feat: add /s:brainstorm skill - creative exploration"
```

---

### Task 13: /s:review skill

**Files:**
- Create: `skills/_quality/s-review/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Multi-perspective review (reference lib/review-protocol.md):
1. Read changed files (git diff)
2. 5-aspect review: plan alignment, code quality, architecture, security, docs
3. SQL safety checks (gstack pattern)
4. LLM trust boundary checks (gstack pattern)
5. Output: findings table with severity
6. Dispatch specialist agents if needed (security-reviewer, database-reviewer)

Source: Superpowers code-reviewer + gstack /review + Compound ce-review.

- [ ] **Step 2: Commit**

```bash
git add skills/_quality/s-review/
git commit -m "feat: add /s:review skill - multi-perspective code review"
```

---

### Task 14: /s:verify skill

**Files:**
- Create: `skills/_quality/s-verify/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Evidence-based verification (reference lib/verification-protocol.md):
1. Run all tests, capture output
2. Check each requirement in REQUIREMENTS.md
3. Build evidence table: requirement | test | result | status
4. No claims without fresh evidence
5. If gaps found, list what's missing
6. Update STATE.md

Source: Superpowers verification-before-completion + GSD /gsd:verify-work.

- [ ] **Step 2: Commit**

```bash
git add skills/_quality/s-verify/
git commit -m "feat: add /s:verify skill - evidence-based verification"
```

---

### Task 15: /s:debug skill

**Files:**
- Create: `skills/_quality/s-debug/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Systematic debugging (reference lib/debug-protocol.md):
1. Reproduce the issue
2. Root cause analysis (NOT guessing)
3. Form hypothesis
4. Test hypothesis with minimal reproduction
5. Fix with test
6. Verify fix doesn't break other tests
7. Defense-in-depth: add guard against similar bugs

Source: Superpowers systematic-debugging.

- [ ] **Step 2: Commit**

```bash
git add skills/_quality/s-debug/
git commit -m "feat: add /s:debug skill - systematic debugging"
```

---

### Task 16: /s:ceo-review and /s:eng-review skills

**Files:**
- Create: `skills/_quality/s-ceo-review/SKILL.md`
- Create: `skills/_quality/s-eng-review/SKILL.md`

- [ ] **Step 1: Write /s:ceo-review**

Product perspective review:
- 3 modes: SCOPE EXPANSION, HOLD SCOPE, SCOPE REDUCTION
- User value analysis
- 10-star product thinking
- Prioritization recommendations

Source: gstack /plan-ceo-review.

- [ ] **Step 2: Write /s:eng-review**

Technical perspective review:
- Architecture analysis
- Data flow verification
- Edge case identification
- Test matrix generation
- Scalability assessment

Source: gstack /plan-eng-review.

- [ ] **Step 3: Commit**

```bash
git add skills/_quality/s-ceo-review/ skills/_quality/s-eng-review/
git commit -m "feat: add /s:ceo-review and /s:eng-review skills"
```

---

## Chunk 4: Agents (Phase 2b)

### Task 17: Core Agents (architect, code-reviewer, security-reviewer, database-reviewer)

**Files:**
- Create: `agents/architect.md`
- Create: `agents/code-reviewer.md`
- Create: `agents/security-reviewer.md`
- Create: `agents/database-reviewer.md`

- [ ] **Step 1: Write architect agent**

System design decisions. Reads requirements + roadmap. Proposes architecture. Evaluates trade-offs.
Source: ECC architect + Compound design agents.

- [ ] **Step 2: Write code-reviewer agent**

5-aspect review. Reads diff + plan. Checks alignment, quality, arch, security, docs.
Source: Superpowers code-reviewer + Compound review agents.

- [ ] **Step 3: Write security-reviewer agent**

OWASP top 10. Auth flows. Input validation. Injection. XSS. CSRF. Secrets in code.
Source: ECC security-reviewer.

- [ ] **Step 4: Write database-reviewer agent**

Schema design. Query performance. N+1 detection. Migration safety. Index analysis.
Source: ECC database-reviewer.

- [ ] **Step 5: Write subagent templates**

4 subagent prompt templates in `agents/subagent-templates/`:
- `implementer-prompt.md` ← Superpowers subagent-driven-development
- `spec-reviewer-prompt.md` ← Superpowers subagent-driven-development
- `code-quality-reviewer-prompt.md` ← Superpowers subagent-driven-development
- `plan-reviewer-prompt.md` ← Superpowers writing-plans

- [ ] **Step 6: Commit**

```bash
git add agents/
git commit -m "feat: add core agents (architect, code-reviewer, security, database) + 4 subagent templates"
```

---

### Task 18: Specialist Agents (tdd-guide, qa-engineer, debugger)

**Files:**
- Create: `agents/tdd-guide.md`
- Create: `agents/qa-engineer.md`
- Create: `agents/debugger.md`

- [ ] **Step 1: Write tdd-guide agent**

Guides through RED/GREEN/REFACTOR. References lib/tdd-protocol.md.
Source: wshobson tdd-orchestrator.

- [ ] **Step 2: Write qa-engineer agent**

Test matrix creation. Edge case discovery. Coverage analysis. 3 tiers (quick/standard/exhaustive).
Source: gstack /qa.

- [ ] **Step 3: Write debugger agent**

Hypothesis-driven debugging. References lib/debug-protocol.md.
Source: Superpowers systematic-debugging + GSD gsd-debugger.

- [ ] **Step 4: Commit**

```bash
git add agents/tdd-guide.md agents/qa-engineer.md agents/debugger.md
git commit -m "feat: add specialist agents (tdd-guide, qa-engineer, debugger)"
```

---

### Task 19: Domain Agents (frontend, backend, mobile, performance, deployment)

**Files:**
- Create: `agents/frontend-dev.md`
- Create: `agents/backend-dev.md`
- Create: `agents/mobile-dev.md`
- Create: `agents/performance-eng.md`
- Create: `agents/deployment-eng.md`

- [ ] **Step 1: Write all 5 domain agents**

Each agent:
- Domain expertise description
- Key patterns and anti-patterns
- Tools/frameworks knowledge
- When to dispatch

Sources: wshobson agents + Compound specialist agents.

- [ ] **Step 2: Commit**

```bash
git add agents/frontend-dev.md agents/backend-dev.md agents/mobile-dev.md agents/performance-eng.md agents/deployment-eng.md
git commit -m "feat: add domain agents (frontend, backend, mobile, performance, deployment)"
```

---

## Chunk 5: Ship & Learn Skills (Phase 3)

### Task 20: /s:ship skill

**Files:**
- Create: `skills/_ship/s-ship/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Ship workflow:
1. Sync with main branch
2. Run full test suite
3. Bump VERSION if exists
4. Update CHANGELOG if exists
5. Create commit with conventional message
6. Push to remote
7. Create PR with summary

Source: gstack /ship.

- [ ] **Step 2: Commit**

```bash
git add skills/_ship/s-ship/
git commit -m "feat: add /s:ship skill - test, push, PR in one command"
```

---

### Task 21: /s:compound skill

**Files:**
- Create: `skills/_ship/s-compound/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Knowledge compound:
1. Review what was built/fixed/learned in this session
2. Extract reusable learnings
3. Write to docs/solutions/YYYY-MM-DD-{topic}.md
4. Format: problem, solution, why it works, gotchas
5. Update STATE.md

Source: Compound /ce-compound. NEVER SKIP.

- [ ] **Step 2: Commit**

```bash
git add skills/_ship/s-compound/
git commit -m "feat: add /s:compound skill - knowledge persistence"
```

---

### Task 22: /s:retro and /s:docs skills

**Files:**
- Create: `skills/_ship/s-retro/SKILL.md`
- Create: `skills/_ship/s-docs/SKILL.md`

- [ ] **Step 1: Write /s:retro**

Retrospective:
- What went well
- What didn't
- Action items
- Per-person feedback (if team)
- Trend tracking across retros

Source: gstack /retro.

- [ ] **Step 2: Write /s:docs**

Documentation update:
- README, ARCHITECTURE, CONTRIBUTING, CLAUDE.md, CHANGELOG
- Detect which docs are stale vs current code
- Update only what changed

Source: gstack /document-release.

- [ ] **Step 3: Commit**

```bash
git add skills/_ship/s-retro/ skills/_ship/s-docs/
git commit -m "feat: add /s:retro and /s:docs skills"
```

---

## Chunk 6: Browser & QA Skills (Phase 4)

### Task 23: Browser Setup

**Files:**
- Create: `bin/setup-browser.sh`

- [ ] **Step 1: Write setup-browser.sh**

```bash
#!/bin/sh
# Lazy browser binary download for /s:browse and /s:qa
# Checks if Playwright MCP is available first; if so, uses that instead.

STACK_DIR="$HOME/.claude-stack"
BIN_DIR="$STACK_DIR/bin"
BROWSE_BIN="$BIN_DIR/gstack-browse"

if [ -f "$BROWSE_BIN" ]; then
  echo "Browser binary already installed at $BROWSE_BIN"
  exit 0
fi

mkdir -p "$BIN_DIR"

# Detect platform
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="x64" ;;
  arm64|aarch64) ARCH="arm64" ;;
esac

PLATFORM="${OS}-${ARCH}"
echo "Downloading browser binary for $PLATFORM..."
# TODO: Replace with actual release URL when published
echo "Browser binary setup complete."
```

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x bin/setup-browser.sh
git add bin/
git commit -m "feat: add browser binary lazy-download script"
```

---

### Task 24: /s:qa, /s:qa-only, /s:browse, /s:cookies skills

**Files:**
- Create: `skills/_browser/s-qa/SKILL.md`
- Create: `skills/_browser/s-qa-only/SKILL.md`
- Create: `skills/_browser/s-browse/SKILL.md`
- Create: `skills/_browser/s-cookies/SKILL.md`

- [ ] **Step 1: Write /s:qa**

Browser QA (3 tiers):
- Quick: route detection + screenshot
- Standard: + form test + responsive + health score
- Exhaustive: + edge cases + accessibility + performance
- Before/after screenshots
- Atomic fix commits
- Uses Playwright MCP if available, else bin/gstack-browse

Source: gstack /qa.

- [ ] **Step 2: Write /s:qa-only**

Report-only QA. Same analysis as /s:qa but no fixes. Output: health score + findings report.
Source: gstack /qa-only.

- [ ] **Step 3: Write /s:browse**

Headless browser control:
- Navigate to URL
- Take screenshot
- Fill forms
- Click elements
- Handle dialogs
- ~100ms/command

Source: gstack /browse.

- [ ] **Step 4: Write /s:cookies**

Cookie import from browsers:
- Detect installed browsers (Chrome, Arc, Brave, Edge)
- Import cookies for authenticated testing
- Session management

Source: gstack /setup-browser-cookies.

- [ ] **Step 5: Commit**

```bash
git add skills/_browser/
git commit -m "feat: add browser skills (qa, qa-only, browse, cookies)"
```

---

## Chunk 7: Automation Skills (Phase 5)

### Task 25: /s:auto, /s:quick, /s:do, /s:map skills

**Files:**
- Create: `skills/_auto/s-auto/SKILL.md`
- Create: `skills/_auto/s-quick/SKILL.md`
- Create: `skills/_auto/s-do/SKILL.md`
- Create: `skills/_auto/s-map/SKILL.md`

- [ ] **Step 1: Write /s:auto**

Autonomous loop:
- Runs the full skill chain automatically
- Circuit breaker: 3 states (closed/open/half-open)
- Stuck detection (same error 3x = stop)
- Rate limiting
- Dual-condition exit gate

Source: Ralph autonomous loop + GSD /gsd:autonomous.

- [ ] **Step 2: Write /s:quick**

Quick mode:
- Accepts --discuss, --full, --research flags
- Compressed workflow: discuss+plan+build in one go
- For small tasks that don't need full ceremony

Source: GSD /gsd:quick.

- [ ] **Step 3: Write /s:do**

Freeform router:
- Accepts natural language instruction
- Routes to appropriate skill(s)
- Handles multi-step requests

Source: GSD /gsd:do.

- [ ] **Step 4: Write /s:map**

Codebase mapper:
- Generates structured codebase documentation
- File dependency graph
- Module responsibility map
- Entry points identification

Source: GSD /gsd:map-codebase.

- [ ] **Step 5: Write /s:help**

Plugin help and skill listing:
- Show all 27 skills grouped by phase
- Show all 12 agents
- Show workflow chain suggestion
- Quick reference card

- [ ] **Step 6: Commit**

```bash
git add skills/_auto/
git commit -m "feat: add automation skills (auto, quick, do, map, help)"
```

---

## Chunk 8: Integration & Polish (Phase 6)

### Task 26: README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README**

Sections:
- What is claude-stack (one paragraph)
- Install (`claude plugin install claude-stack`)
- Quick start (`/s:new myproject` > `/s:discuss` > `/s:plan` > `/s:build`)
- All 29 skills table (name, description, phase)
- All 12 agents table
- Configuration
- Uninstall

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with usage guide"
```

---

### Task 27: Integration Test Plan

No code to write. Verification checklist:

- [ ] **Step 1: Test skill chain**

```
/s:new testproject → /s:discuss → /s:brainstorm → /s:plan → /s:build → /s:review → /s:verify → /s:ship → /s:compound → /s:retro
```

Each skill should:
1. Be callable by name
2. Read/write correct state files
3. Suggest next skill
4. Not break when previous skill was skipped

- [ ] **Step 2: Test hooks**

Verify each hook fires at correct event.

- [ ] **Step 3: Test agents**

Dispatch each agent, verify it has correct instructions.

- [ ] **Step 4: Test context persistence**

1. Run /s:new + /s:discuss + /s:plan
2. Close session
3. New session → hook should show STATE.md
4. Run /s:resume → should reconstruct context

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: claude-stack unified plugin v1.0.0"
```

---

## Summary

| Chunk | Tasks | What |
|-------|-------|------|
| 1 | 1-6 | Scaffold: plugin.json, lib/ (10 files), templates (12), hooks, rules (8), CLAUDE.md |
| 2 | 7-11 | Core skills: new, discuss, plan, build, status, resume, pause, note |
| 3 | 12-16 | Quality skills: brainstorm, review, verify, debug, ceo-review, eng-review |
| 4 | 17-19 | Agents: 12 agents + 4 subagent templates |
| 5 | 20-22 | Ship skills: ship, compound, retro, docs |
| 6 | 23-24 | Browser: setup script + qa, browse, cookies skills |
| 7 | 25 | Automation: auto, quick, do, map, help skills |
| 8 | 26-27 | Polish: README + integration tests |

**Total: 27 tasks, ~90 files, 8 chunks.**
Each chunk is independently committable and testable.
