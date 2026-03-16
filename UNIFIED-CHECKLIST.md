# Unified Tool Checklist

## Phase 1: Foundation
- [ ] Plugin scaffold oluştur (`plugin.json`, dizin yapısı)
- [ ] Ana `SKILL.md` yaz (using-skill, nasıl çalışır)
- [ ] `/s:new` skill - proje başlatma (.planning/ + docs/ + CLAUDE.md + git init)
- [ ] `/s:discuss` skill - gereksinim çıkarma (soru-cevap → REQUIREMENTS.md)
- [ ] `/s:plan` skill - detaylı plan (brainstorm → architecture → task breakdown → ROADMAP.md)
- [ ] `/s:build` skill - TDD-enforced implementation (RED→GREEN→REFACTOR)
- [ ] Context sistemi: .planning/ dosyaları (PROJECT, REQUIREMENTS, ROADMAP, STATE)
- [ ] Context sistemi: docs/ dosyaları (brainstorms, plans, solutions)
- [ ] Hook: session-start (STATE.md + git log yükle)
- [ ] Hook: context-monitor (context rot uyarısı)
- [ ] Hook: pre-compact (tam snapshot)
- [ ] Hook: post-edit (auto lint/format/typecheck)
- [ ] Templates: project.md, requirements.md, roadmap.md, state.md
- [ ] TEST: /s:new → /s:discuss → /s:plan → /s:build zinciri çalışıyor mu?

## Phase 2: Quality
- [ ] `/s:brainstorm` skill - creative exploration (alternatives, trade-offs)
- [ ] `/s:review` skill - multi-perspective code review (security, performance, architecture, simplicity)
- [ ] `/s:verify` skill - kanıt tablosu ile doğrulama (test sonuçları, gereksinim mapping)
- [ ] `/s:debug` skill - systematic debugging (hipotez → test → kanıt → fix)
- [ ] Uncodixfy rules entegrasyonu (rules/uncodixfy.md)
- [ ] TDD enforcement rules (rules/tdd.md)
- [ ] Hook: tdd-check (test olmadan implementation uyarısı)
- [ ] Agent: architect (sistem tasarımı kararları)
- [ ] Agent: code-reviewer (kapsamlı review)
- [ ] Agent: security-reviewer (güvenlik audit)
- [ ] Agent: database-reviewer (DB schema/query review)
- [ ] Agent: tdd-guide (TDD yönlendirmesi)
- [ ] Agent: qa-engineer (test yazımı)
- [ ] Agent: frontend-dev (UI specialist)
- [ ] Agent: backend-dev (API specialist)
- [ ] TEST: /s:brainstorm → /s:build → /s:review → /s:verify zinciri

## Phase 3: Ship & Learn
- [ ] `/s:ship` skill - sync main + test + push + PR (tek komut)
- [ ] `/s:compound` skill - öğrenimleri kaydet (docs/solutions/)
- [ ] `/s:retro` skill - retrospective (ne iyi gitti, ne kötü, action items)
- [ ] `/s:docs` skill - doc güncelleme (README, ARCHITECTURE, CONTRIBUTING)
- [ ] `/s:ceo-review` skill - ürün perspektifi (10-star product, kullanıcı değeri)
- [ ] `/s:eng-review` skill - teknik perspektif (architecture, edge cases, scalability)
- [ ] Knowledge persistence: docs/solutions/ compound birikimi
- [ ] TEST: full cycle /s:new → ... → /s:ship → /s:compound → /s:retro

## Phase 4: Browser & QA
- [ ] `/s:qa` skill - browser QA (route detection, screenshot, health score)
- [ ] `/s:browse` skill - headless browser kontrolü
- [ ] Browser binary setup (gstack browse/ from source)
- [ ] Cookie import (Chrome, Arc, Brave, Edge, Safari)
- [ ] Screenshot verification (before/after)
- [ ] TEST: /s:qa çalışıyor mu? Screenshot alıyor mu?

## Phase 5: Integration & Test
- [ ] Tüm 17 komut birlikte çalışıyor mu?
- [ ] Tool chain testi: /s:new → /s:discuss → /s:brainstorm → /s:plan → /s:ceo-review → /s:eng-review → /s:build → /s:review → /s:verify → /s:qa → /s:ship → /s:compound → /s:retro → /s:docs
- [ ] Split-pane agent team testi: 3+ teammate paralel çalışma
- [ ] Context persistence testi: session kapat → aç → state kaybolmadı mı?
- [ ] Uninstall/reinstall testi
- [ ] Yeni makinede bootstrap testi
- [ ] install.sh - tek satır kurulum scripti
- [ ] README.md
- [ ] GitHub marketplace'e publish
- [ ] stack.sh entegrasyonu (preset'ler bu plugin'i kursun)

## Plugin Dağıtım
- [ ] GitHub repo: `bdarbaz/claude-stack-plugin`
- [ ] Plugin marketplace'e kayıt
- [ ] `claude plugin marketplace add bdarbaz/claude-stack-plugin`
- [ ] `claude plugin install claude-stack`
- [ ] Tek satır kurulum: Claude Code'a yapıştır → otomatik kursun

## Kaynak Mapping (hangi orijinal tool'dan ne alındı)
| Komut | Kaynak | Orijinal |
|-------|--------|----------|
| /s:new | GSD | /gsd:new-project |
| /s:discuss | GSD | /gsd:discuss-phase |
| /s:brainstorm | Superpowers + Compound | brainstorming skill + /ce-brainstorm |
| /s:plan | GSD + Compound + Superpowers | /gsd:plan-phase + /ce-plan + writing-plans |
| /s:ceo-review | gstack | /plan-ceo-review |
| /s:eng-review | gstack | /plan-eng-review |
| /s:build | GSD + Superpowers | /gsd:execute-phase + test-driven-development |
| /s:debug | Superpowers | systematic-debugging |
| /s:review | Compound + gstack | /ce-review + /review |
| /s:qa | gstack | /qa |
| /s:browse | gstack | /browse |
| /s:verify | Superpowers + GSD | verification-before-completion + /gsd:verify-work |
| /s:ship | gstack | /ship |
| /s:compound | Compound | /ce-compound |
| /s:retro | gstack | /retro |
| /s:docs | gstack | /document-release |
| /s:status | GSD | /gsd:progress |
| Rules | Uncodixfy + ECC | uncodixfy rules + coding-standards |
| Agents | ECC + wshobson + VoltAgent | cherry-picked best |
| Hooks | GSD + Superpowers + Pilot | context-monitor + tdd-check + lint |
