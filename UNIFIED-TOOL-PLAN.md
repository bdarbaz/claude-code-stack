# UNIFIED TOOL PLAN - "claude-stack" Plugin

## PROBLEM
7+ ayrı tool kuruluyor, çakışıyor, farklı komut namespace'leri, farklı dosya yapıları.
GSD /gsd:plan, Compound /ce-plan, Superpowers /write-plan - 3 farklı "plan" komutu var.

## ÇÖZÜM
Tek bir Claude Code plugin: Tüm en iyi özellikleri birleştirir, tek namespace, tek workflow.
MCPs ayrı kalır (context7, figma, playwright, supabase, github).

---

## CODEBASE DEEP DIVE - HER TOOL'DAN TAM LİSTE

### GSD (get-shit-done) - 41 Workflow, 16 Agent, 3 Hook
**Workflows:**
new-project, discuss-phase, plan-phase, execute-phase, verify-phase, verify-work, research-phase, discovery-phase, map-codebase, autonomous, quick (--discuss/--full/--research), do (freeform router), new-milestone, complete-milestone, audit-milestone, plan-milestone-gaps, add-phase, insert-phase, remove-phase, transition, add-todo, check-todos, add-tests, ui-phase, ui-review, pause-work, resume-project, diagnose-issues, execute-plan, profile-user, note, settings, stats, health, help, cleanup, update, node-repair

**Agents:**
gsd-planner, gsd-executor, gsd-verifier, gsd-project-researcher, gsd-research-synthesizer, gsd-phase-researcher, gsd-roadmapper, gsd-plan-checker, gsd-codebase-mapper, gsd-debugger, gsd-integration-checker, gsd-nyquist-auditor, gsd-ui-researcher, gsd-ui-checker, gsd-ui-auditor, gsd-user-profiler

**Hooks:** context-monitor, check-update, statusline

**Dosya Sistemi:**
.planning/PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md
.planning/phases/N/CONTEXT.md, PLAN.md, RESEARCH.md, DISCOVERY.md, SUMMARY.md, VALIDATION.md, UI-SPEC.md, UAT.md
.planning/codebase/ (7 structured doc), .planning/quick/, .continue-here.md

---

### Superpowers - 14 Skill, 3 Command, 1 Agent
**Skills:**
1. brainstorming (HARD-GATE: tasarım onayı olmadan kod yazma YOK, visual-companion.md, spec-document-reviewer-prompt.md, scripts/)
2. writing-plans (bite-sized tasks, 2-5 min granularity, docs/superpowers/plans/)
3. executing-plans (checkpoint'li session arası execution)
4. test-driven-development (Iron Law: failing test olmadan prod code DELETE)
5. systematic-debugging (4 phase: Root Cause → Hypothesis → Test → Fix, defense-in-depth.md, root-cause-tracing.md, find-polluter.sh)
6. verification-before-completion (NO COMPLETION CLAIMS WITHOUT FRESH EVIDENCE)
7. dispatching-parallel-agents (1 agent per problem domain)
8. subagent-driven-development (task başına subagent + 2-stage review: spec compliance → code quality, implementer-prompt.md, spec-reviewer-prompt.md, code-quality-reviewer-prompt.md)
9. writing-skills (TDD for documentation)
10. finishing-a-development-branch (verify → options → execute → cleanup)
11. using-git-worktrees (isolated workspace)
12. requesting-code-review
13. receiving-code-review (verify before implementing, NO performative agreement)
14. using-superpowers (meta: nasıl kullan)

**Commands:** /brainstorm, /write-plan, /execute-plan
**Agent:** code-reviewer (plan alignment + code quality + architecture + docs, 5-aspect review)

---

### gstack - 10 Skill, Browser Binary
**Skills:**
1. /plan-ceo-review (3 mod: SCOPE EXPANSION, HOLD SCOPE, SCOPE REDUCTION)
2. /plan-eng-review (architecture, data flow, diagrams, edge cases, test matrix)
3. /review (SQL safety, LLM trust boundary, conditional side effects, Greptile triage, checklist.md)
4. /ship (sync main, tests, VERSION bump, CHANGELOG, commit, push, PR)
5. /qa (3 tier: Quick/Standard/Exhaustive, health score, before/after, atomic fix commits)
6. /qa-only (report-only, no fixes)
7. /browse (~100ms/command, screenshot, responsive, form test, dialog handle, annotated screenshots)
8. /retro (per-person, praise + growth, trend tracking, persistent history)
9. /document-release (README, ARCHITECTURE, CONTRIBUTING, CLAUDE.md, CHANGELOG, TODOS, VERSION)
10. /setup-browser-cookies (Chrome, Arc, Brave, Edge, Comet import)

**Key Pattern:** AskUserQuestion format: Re-ground → Simplify → Recommend → Options
**Browser:** Playwright-based, Bun compiled (~58MB), isolated per workspace
**Conductor:** 10 parallel sessions

---

### Compound Engineering - 5 Core + 20 Extra Skills, 28 Agents
**Core:** ce-brainstorm, ce-plan, ce-work, ce-review, ce-compound
**Extra:** agent-browser, brainstorming, changelog, compound-docs, create-agent-skills, deepen-plan, deploy-docs, dhh-rails-style, document-review, dspy-ruby, every-style-editor, feature-video, frontend-design, gemini-imagegen, git-worktree, heal-skill, lfg, orchestrating-swarms, proof, rclone, report-bug, reproduce-bug, resolve-pr-parallel, resolve_parallel, resolve_todo_parallel, setup, slfg, test-browser, test-xcode, triage, workflows-*

**28 Agents:** 15 review, 5 research, 3 design, 4 workflow, 1 docs
**Dosya Sistemi:** docs/brainstorms/, docs/plans/, docs/solutions/

---

### Uncodixfy - 194 Line Anti-AI-Slop
33 "Keep It Normal" kategorisi, 24 "Hard No" kuralı, 10 dark + 10 light palette
Renk seçim: 1) Projenin kendi → 2) Predefined → 3) ASLA random

---

## UNIFIED KOMUT YAPISI - /s: namespace (27 komut)

### Proje Lifecycle (17)
/s:new, /s:discuss, /s:brainstorm, /s:plan, /s:ceo-review, /s:eng-review, /s:build, /s:debug, /s:review, /s:qa, /s:qa-only, /s:browse, /s:verify, /s:ship, /s:compound, /s:retro, /s:docs

### Utility (10)
/s:auto, /s:quick, /s:do, /s:status, /s:resume, /s:pause, /s:note, /s:map, /s:cookies, /s:help

## AGENTS (12 + 4 subagent templates)
architect, code-reviewer, security-reviewer, database-reviewer, tdd-guide, qa-engineer, frontend-dev, backend-dev, mobile-dev, debugger, performance-eng, deployment-eng

## HOOKS (6)
session-start, context-monitor, pre-compact, post-edit, tdd-check, statusline

## RULES (7)
uncodixfy, tdd, verification, debugging, context-persist, ask-user, quality

## VISUAL BRAINSTORMING
Browser-based mockup/diagram (superpowers visual-companion + gstack browse birleştirilecek)

---

## 6 PHASE BUILD PLAN

### Phase 1: Foundation
Plugin scaffold + /s:new + /s:discuss + /s:plan + /s:build + context system + hooks + templates + /s:status + /s:resume + /s:pause + /s:note

### Phase 2: Quality & Review
/s:brainstorm (+ visual) + /s:review + /s:verify + /s:debug + TDD + Uncodixfy + 12 agents + 4 subagent templates + /s:ceo-review + /s:eng-review

### Phase 3: Ship & Learn
/s:ship + /s:compound + /s:retro + /s:docs

### Phase 4: Browser & QA
/s:qa + /s:qa-only + /s:browse + /s:cookies + browser binary

### Phase 5: Automation
/s:auto + /s:quick + /s:do + /s:map + install script + README + marketplace

### Phase 6: Integration Test
27 komut chain test + split-pane + context persistence + session resume + bootstrap/purge
