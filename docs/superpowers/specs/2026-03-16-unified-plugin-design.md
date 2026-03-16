# Unified Claude Code Plugin - Design Spec

**Date:** 2026-03-16
**Status:** Approved
**Approach:** B - Layered Single Plugin

---

## 1. Overview

18 tool/framework'u tek bir Claude Code plugin'ine birlestiren unified plugin.
GSD + Superpowers + Compound + gstack + ECC + wshobson + Uncodixfy = `claude-stack`

**Cikti:** `claude plugin install claude-stack` ile kurulan, 27 skill, 12 agent (+4 subagent template), 6 hook, 8 rule iceren tek plugin.

**Not:** /s:confidence ve /s:memory ayri skill degil - confidence rules/confidence.md olarak, memory ise context system (lib/context-system.md) icinde handle edilir.

---

## 2. Directory Structure

```
claude-stack/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── skills/
│   ├── _core/                   # Phase 1: Foundation
│   │   ├── s-new/SKILL.md       # Proje baslat
│   │   ├── s-discuss/SKILL.md   # Gereksinim cikar
│   │   ├── s-plan/SKILL.md      # Plan yaz
│   │   ├── s-build/SKILL.md     # TDD implementation
│   │   ├── s-status/SKILL.md    # Proje durumu
│   │   ├── s-resume/SKILL.md    # Projeye devam et
│   │   ├── s-pause/SKILL.md     # Calismayi duraklat
│   │   └── s-note/SKILL.md      # Not ekle
│   ├── _quality/                # Phase 2: Quality
│   │   ├── s-brainstorm/SKILL.md    # Creative exploration
│   │   ├── s-review/SKILL.md       # Multi-perspective review
│   │   ├── s-verify/SKILL.md       # Kanit tabanli dogrulama
│   │   ├── s-debug/SKILL.md        # Systematic debugging
│   │   ├── s-ceo-review/SKILL.md   # Urun perspektifi
│   │   └── s-eng-review/SKILL.md   # Teknik perspektif
│   ├── _ship/                   # Phase 3: Ship & Learn
│   │   ├── s-ship/SKILL.md     # Test + push + PR
│   │   ├── s-compound/SKILL.md # Ogrenimleri kaydet
│   │   ├── s-retro/SKILL.md    # Retrospective
│   │   └── s-docs/SKILL.md     # Doc guncelle
│   ├── _browser/                # Phase 4: Browser & QA
│   │   ├── s-qa/SKILL.md       # Browser QA
│   │   ├── s-qa-only/SKILL.md  # Report-only QA
│   │   ├── s-browse/SKILL.md   # Headless browser
│   │   └── s-cookies/SKILL.md  # Cookie import
│   └── _auto/                   # Phase 5: Automation
│       ├── s-auto/SKILL.md     # Autonomous loop
│       ├── s-quick/SKILL.md    # Quick mode
│       ├── s-do/SKILL.md       # Freeform router
│       ├── s-map/SKILL.md      # Codebase mapper
│       └── s-help/SKILL.md     # Plugin help & skill listing
├── agents/
│   ├── architect.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   ├── database-reviewer.md
│   ├── tdd-guide.md
│   ├── qa-engineer.md
│   ├── frontend-dev.md
│   ├── backend-dev.md
│   ├── mobile-dev.md
│   ├── debugger.md
│   ├── performance-eng.md
│   ├── deployment-eng.md
│   └── subagent-templates/
│       ├── implementer-prompt.md
│       ├── spec-reviewer-prompt.md
│       ├── code-quality-reviewer-prompt.md
│       └── plan-reviewer-prompt.md
├── hooks/
│   └── hooks.json               # 6 merged hooks
├── rules/
│   ├── uncodixfy.md             # Anti-AI-slop rules
│   ├── tdd.md                   # TDD enforcement
│   ├── verification.md          # No claims without evidence
│   ├── debugging.md             # Systematic only
│   ├── context-persist.md       # Never delete .planning/ docs/
│   ├── ask-user.md              # Re-ground, simplify, recommend
│   ├── quality.md               # Code quality standards
│   └── confidence.md            # Confidence check before decisions
├── templates/
│   ├── planning/
│   │   ├── PROJECT.md
│   │   ├── REQUIREMENTS.md
│   │   ├── ROADMAP.md
│   │   ├── STATE.md
│   │   └── phase/
│   │       ├── CONTEXT.md
│   │       ├── PLAN.md
│   │       ├── RESEARCH.md
│   │       ├── SUMMARY.md
│   │       ├── DISCOVERY.md
│   │       ├── VALIDATION.md
│   │       ├── UI-SPEC.md
│   │       └── UAT.md
│   └── docs/
│       ├── brainstorms/.gitkeep
│       ├── plans/.gitkeep
│       └── solutions/.gitkeep
├── lib/
│   ├── context-system.md        # Context persistence protocol
│   ├── tdd-protocol.md          # RED > GREEN > REFACTOR
│   ├── verification-protocol.md # Evidence table format
│   ├── review-protocol.md       # Multi-perspective review
│   ├── debug-protocol.md        # Hypothesis > Test > Fix
│   ├── agent-dispatch.md        # When teammate vs subagent
│   ├── visual-companion.md      # Browser-based mockup/diagram guide
│   ├── defense-in-depth.md      # Debugging defense layers
│   ├── root-cause-tracing.md    # Root cause analysis method
│   └── find-polluter.sh         # Test pollution finder script
├── bin/
│   └── setup-browser.sh         # Lazy browser binary download
├── CLAUDE.md                    # Plugin rules (auto-loaded)
└── README.md
```

---

## 3. Plugin Metadata

```json
{
  "name": "claude-stack",
  "version": "1.0.0",
  "description": "Unified development workflow: 29 skills, 12 agents, 6 hooks. Replaces GSD + Superpowers + Compound + gstack.",
  "author": { "name": "bdarbaz" },
  "repository": "https://github.com/bdarbaz/claude-stack-plugin",
  "license": "MIT",
  "keywords": ["workflow", "tdd", "debugging", "code-review", "project-management", "qa"]
}
```

---

## 4. Skill Architecture

### 4.1 Naming Convention
- Skill dizin adi: `s-{komut}` (ornek: `s-new`, `s-plan`, `s-build`)
- Kullanici cagirir: `/s:new`, `/s:plan`, `/s:build`
- Claude Code skill name frontmatter: `name: s-new`

### 4.2 Skill Frontmatter Standard
```yaml
---
name: s-{komut}
description: "{ne yapar} - {ne zaman kullanilir}"
---
```

### 4.3 Shared Protocol References
Skill'ler `lib/*.md` dosyalarini referans ederek DRY kalir:
- `/s:build` → lib/tdd-protocol.md
- `/s:debug` → lib/debug-protocol.md
- `/s:verify` → lib/verification-protocol.md
- `/s:review` → lib/review-protocol.md

Skill icinden referans: `Read the protocol at: {CLAUDE_PLUGIN_ROOT}/lib/tdd-protocol.md`

### 4.4 Context System
Her skill STATE.md'yi gunceller. Akis:
1. `/s:new` → .planning/ + docs/ olusturur (templates/'dan kopyalar)
2. `/s:discuss` → REQUIREMENTS.md yazar
3. `/s:plan` → ROADMAP.md + phases/ olusturur
4. `/s:build` → STATE.md gunceller (aktif task, progress)
5. `/s:status` → STATE.md + git log okur, ozet verir
6. `/s:resume` → STATE.md + son context'i yukler
7. `/s:compound` → docs/solutions/'a ogrenimler yazar

---

## 5. Hooks Design

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "if [ -f .planning/STATE.md ]; then echo '=== STACK: RESUMING ==='; head -15 .planning/STATE.md; git log --oneline -5 2>/dev/null; fi"
      }]
    }],
    "PreToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "echo '[STACK] Reminder: TDD - test first, then implement'"
      }]
    }],
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "filepath=\"$CLAUDE_FILE_PATH\"; ext=\"${filepath##*.}\"; case \"$ext\" in ts|tsx|js|jsx) npx prettier --write \"$filepath\" 2>/dev/null; npx eslint --fix \"$filepath\" 2>/dev/null ;; py) ruff format \"$filepath\" 2>/dev/null; ruff check --fix \"$filepath\" 2>/dev/null ;; esac"
      }]
    }],
    "PreCompact": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "echo '=== STACK SNAPSHOT ==='; cat .planning/STATE.md 2>/dev/null; echo '---'; cat .planning/ROADMAP.md 2>/dev/null | head -30; echo '---'; for f in $(ls -t docs/solutions/*.md 2>/dev/null | head -3); do head -10 \"$f\"; done; echo '---'; git log --oneline -10 2>/dev/null; echo '=== END ===';"
      }]
    }],
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "if [ -f .planning/STATE.md ]; then phase=$(grep 'Active Phase' .planning/STATE.md 2>/dev/null | head -1); status=$(grep 'Status' .planning/STATE.md 2>/dev/null | head -1); echo \"[STACK] $status | $phase\"; fi"
      }]
    }],
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "echo '[STACK] Session ending. State preserved in .planning/ and docs/'"
      }]
    }]
  }
}
```

**6 hook (6 event):**
1. **session-start** (SessionStart) - STATE.md + git log yukle
2. **tdd-check** (PreToolUse) - Write/Edit oncesi TDD hatirlatma
3. **post-edit** (PostToolUse) - Lint/format/typecheck
4. **pre-compact** (PreCompact) - Tam context snapshot
5. **statusline** (Notification) - Aktif phase + status goster
6. **stop** (Stop) - Session bitis hatirlatma

---

## 6. Agents Design

12 agent, her biri tek `.md` dosyasi:

| Agent | Kaynak | Gorev |
|-------|--------|-------|
| architect | ECC + Compound | Sistem tasarimi kararlari |
| code-reviewer | Superpowers + Compound | 5-aspect review (plan alignment, quality, arch, security, docs) |
| security-reviewer | ECC | OWASP top 10, auth, injection, XSS |
| database-reviewer | ECC | Schema, query performance, migrations |
| tdd-guide | wshobson | RED/GREEN/REFACTOR yonlendirmesi |
| qa-engineer | gstack | Test matrix, edge cases, coverage |
| frontend-dev | wshobson + Compound | React/Next.js specialist |
| backend-dev | wshobson | API/service specialist |
| mobile-dev | wshobson | React Native/Swift specialist |
| debugger | Superpowers | Hypothesis-driven debugging |
| performance-eng | ECC | Profiling, bottleneck analysis |
| deployment-eng | wshobson | CI/CD, Docker, deploy |

Agent dispatch kurali: Lead, split-pane teammate olusturur. Teammate kendi icinde subagent kullanabilir.

---

## 7. Rules Design

8 rule dosyasi, CLAUDE.md tarafindan referans edilir:

1. **uncodixfy.md** - 33 "keep it normal" + 24 "hard no" + palette kurallari
2. **tdd.md** - Failing test olmadan prod code yazma
3. **verification.md** - Is bitti demeden evidence table goster
4. **debugging.md** - Tahmin etme, hypothesis > test > fix
5. **context-persist.md** - .planning/ ve docs/ asla silinmez
6. **ask-user.md** - Re-ground > Simplify > Recommend > Options
7. **quality.md** - No `any`, no emoji icons, Lucide/Heroicons, code standards
8. **confidence.md** - Karar oncesi confidence score

CLAUDE.md'de: `Rules are defined in {CLAUDE_PLUGIN_ROOT}/rules/. Follow all of them.`

---

## 8. Browser Binary Strategy

gstack'in Playwright-based browse binary'si (~58MB):
1. Plugin'e binary DAHIL EDILMEZ
2. `/s:browse` veya `/s:qa` ilk cagrildiginda:
   - `bin/setup-browser.sh` calisir
   - Platform detect (darwin-arm64, darwin-x64, linux-x64)
   - GitHub releases'dan binary indirir → `~/.claude-stack/bin/gstack-browse`
3. Sonraki cagrilarda binary hazir
4. Alternatif: Playwright MCP zaten kuruluysa, onu kullan (plugin.json'da check)

---

## 9. Templates

`/s:new` calistiginda templates/ dizininden kopyalar:

```
templates/planning/ → .planning/
  PROJECT.md       → Proje vizyonu, degerler, kisitlamalar
  REQUIREMENTS.md  → Bos sablon, /s:discuss dolduracak
  ROADMAP.md       → Bos sablon, /s:plan dolduracak
  STATE.md         → Initial state: "Project created"
  phase/           → Phase sablon dosyalari

templates/docs/ → docs/
  brainstorms/.gitkeep
  plans/.gitkeep
  solutions/.gitkeep
```

---

## 10. Skill Interaction Map

```
/s:new → /s:discuss → /s:brainstorm → /s:plan → /s:ceo-review
                                                      ↓
                                                /s:eng-review
                                                      ↓
                                          /s:build (TDD loop)
                                                      ↓
                                    /s:review → /s:verify → /s:qa
                                                              ↓
                                              /s:ship → /s:compound → /s:retro
```

Her skill bir sonrakine gecis onerisi yapar ama zorlamaz.
`/s:auto` bu zinciri otomatik yurutur.
`/s:do` freeform - herhangi bir skill'e router.

---

## 11. CLAUDE.md (Plugin Root)

Plugin'in CLAUDE.md'si otomatik yuklenir. Icerigi:
- Tum rules/*.md dosyalarini referans eder
- Skill kullanim sirasi (workflow hierarchy)
- Agent dispatch kurallari
- Context persistence kurallari
- Yasaklar listesi
- MCP kullanim tablosu

---

## 12. Key Constraints

1. **Tek plugin, tek install** - `claude plugin install claude-stack`
2. **Backward compatible** - Mevcut .planning/ ve docs/ dizinleri korunur
3. **MCP'ler ayri** - context7, playwright, supabase plugin disinda
4. **Browser lazy-load** - Binary sadece gerektiginde indirilir
5. **Platform-agnostic hooks** - sh uyumlu, bash-specific ozellik yok
6. **Skill bagimsizligi** - Her skill tek basina calisabilir, zincir zorunlu degil
