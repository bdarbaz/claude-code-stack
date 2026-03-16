# UNIFIED TOOL PLAN - "berkan-stack" (working name)

## PROBLEM
7+ ayrı tool kuruluyor, çakışıyor, farklı komut namespace'leri, farklı dosya yapıları.
GSD /gsd:plan, Compound /ce-plan, Superpowers /write-plan - 3 farklı "plan" komutu var.

## ÇÖZÜM
Tek bir Claude Code plugin: Tüm en iyi özellikleri birleştirir, tek namespace, tek workflow.

## HER TOOL'DAN NE ALIYORUZ

### GSD'den:
- [x] .planning/ dosya sistemi (PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md)
- [x] Context rot çözümü (context-monitor hook)
- [x] Wave-based parallel execution
- [x] Phase-based development
- [x] discuss → plan → execute → verify döngüsü

### Compound'dan:
- [x] docs/brainstorms/, docs/plans/, docs/solutions/ (knowledge persistence)
- [x] /brainstorm (alternatives exploration)
- [x] /compound (knowledge saving - öğrenmeler birikir)
- [x] Multi-agent code review (15 review perspective)

### Superpowers'dan:
- [x] brainstorming skill (creative exploration ZORUNLU)
- [x] TDD skill (RED→GREEN→REFACTOR enforced)
- [x] systematic-debugging (analiz-first, tahmin etme)
- [x] verification-before-completion (kanıt tablosu)
- [x] writing-plans / executing-plans (checkpoint'li)

### gstack'den:
- [x] /ceo-review (10-star product thinking)
- [x] /eng-review (architecture, edge cases, test matrix)
- [x] /qa (browser QA - screenshot, health score)
- [x] /browse (headless browser - Claude'a göz)
- [x] /ship (sync+test+push+PR tek komut)
- [x] /retro (retrospective)
- [x] /document-release (doc update)

### Uncodixfy'dan:
- [x] Anti-AI-slop UI rules (tam liste)
- [x] "Normal" UI enforcement (Linear/Raycast/Stripe style)

### ECC'den:
- [x] Domain skills (frontend-patterns, api-design, postgres-patterns, etc.)
- [x] Specialized agents (architect, code-reviewer, security-reviewer, etc.)

### wshobson'dan:
- [x] TDD workflow skills (tdd-red, tdd-green, tdd-cycle)
- [x] Progressive disclosure skills
- [x] Specialized agents (backend-architect, database-architect, etc.)

## UNIFIED KOMUT YAPISI

Tek namespace: /s: (stack)

### Proje Başlangıç
/s:new          → Yeni proje (GSD new-project + Compound setup)
/s:discuss      → Gereksinimleri tartış (GSD discuss)

### Planlama
/s:brainstorm   → Creative keşif (Superpowers brainstorming + Compound brainstorm)
/s:plan         → Detaylı plan (Superpowers writing-plans + GSD plan + Compound plan)
/s:ceo-review   → Ürün perspektifi (gstack ceo-review)
/s:eng-review   → Teknik perspektif (gstack eng-review)

### Implementation
/s:build        → Plan'ı execute et (GSD execute + Superpowers TDD)
/s:debug        → Sistematik debug (Superpowers systematic-debugging)

### Kalite
/s:review       → Code review (Compound multi-agent + gstack review)
/s:qa           → Browser QA (gstack qa)
/s:browse       → Headless browser (gstack browse)
/s:verify       → Doğrulama (Superpowers verification + GSD verify)

### Ship & Learn
/s:ship         → Tek komut deploy (gstack ship)
/s:compound     → Öğrenimleri kaydet (Compound compound)
/s:retro        → Retrospective (gstack retro)
/s:docs         → Doc güncelle (gstack document-release)

### Utility
/s:status       → Proje durumu (.planning/STATE.md)
/s:progress     → İlerleme raporu
/s:help         → Komut listesi

## DOSYA YAPISI

```
.claude-plugin/
├── plugin.json              # Plugin manifest
├── SKILL.md                 # Ana skill dosyası (Uncodixfy rules dahil)
├── skills/
│   ├── new.md
│   ├── discuss.md
│   ├── brainstorm.md
│   ├── plan.md
│   ├── ceo-review.md
│   ├── eng-review.md
│   ├── build.md
│   ├── debug.md
│   ├── review.md
│   ├── qa.md
│   ├── browse.md
│   ├── verify.md
│   ├── ship.md
│   ├── compound.md
│   ├── retro.md
│   ├── docs.md
│   ├── status.md
│   └── help.md
├── agents/
│   ├── architect.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   ├── database-reviewer.md
│   ├── tdd-guide.md
│   ├── qa-engineer.md
│   ├── frontend-dev.md
│   ├── backend-dev.md
│   └── ...
├── rules/
│   ├── uncodixfy.md         # Anti-AI-slop UI rules
│   ├── tdd.md               # TDD enforcement rules
│   ├── context-persist.md   # Context persistence rules
│   └── quality.md           # Quality gates
├── hooks/
│   ├── session-start.js     # Load state on resume
│   ├── context-monitor.js   # Context rot prevention
│   ├── pre-compact.js       # Save state before compaction
│   ├── post-edit.js         # Auto lint/format/typecheck
│   └── tdd-check.js         # TDD enforcement
├── templates/
│   ├── project.md
│   ├── requirements.md
│   ├── roadmap.md
│   ├── state.md
│   └── claude-md/           # Per-preset CLAUDE.md templates
└── browse/                  # gstack browser binary
    └── (compiled on setup)
```

## PHASE'LER

### Phase 1: Foundation
- Plugin scaffold (plugin.json, SKILL.md)
- Core skills: /s:new, /s:discuss, /s:plan, /s:build
- Context system (.planning/ + docs/)
- Hooks (session-start, pre-compact, context-monitor)
- Templates

### Phase 2: Quality
- /s:brainstorm, /s:review, /s:verify, /s:debug
- TDD enforcement
- Uncodixfy rules
- Agents (architect, code-reviewer, security, db, tdd, qa)

### Phase 3: Ship & Learn
- /s:ship, /s:compound, /s:retro, /s:docs
- /s:ceo-review, /s:eng-review
- Knowledge persistence (docs/solutions/)

### Phase 4: Browser & QA
- /s:qa, /s:browse
- Browser binary (gstack'den)
- Screenshot verification

### Phase 5: Integration & Test
- Tüm komutlar birlikte test
- Tool chain testi
- Split-pane agent team testi
- Install/uninstall testi
