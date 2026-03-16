# Unified Claude Code Stack

Bu proje, birden fazla Claude Code framework'unun birlikte, uyumlu calismasi icin konfigure edilmistir.
Superpowers, GSD, Compound Engineering, ECC ve wshobson agents hep birlikte calisir.

## SUPERPOWERS - HER ZAMAN AKTIF (ASLA ATLAMA)

Superpowers skill'leri Claude'un temel davranis katmanidir. Bunlar OTOMATIK cagrilmali:

| Durum | Superpowers Skill | Ne Yapar |
|-------|-------------------|----------|
| Herhangi bir creative is | `brainstorming` | ONCE kesfet, sonra yap |
| Multi-step task | `writing-plans` | Plan yaz, checkpoint koy |
| Plan execute etme | `executing-plans` | Session'lara bol, review checkpoint |
| Bug/hata/test failure | `systematic-debugging` | ONCE analiz, sonra fix (tahmin etme) |
| Is bitti diyeceksen | `verification-before-completion` | ONCE dogrula, kanit goster |
| 2+ bagimsiz task | `dispatching-parallel-agents` | Paralel subagent gonder |
| Plan varsa implement | `subagent-driven-development` | Subagent'larla implement et |
| Feature/fix yazacaksan | `test-driven-development` | ONCE test, sonra kod |
| Branch bitirdiysen | `finishing-a-development-branch` | Temizle, merge hazirla |
| Code review isteyeceksen | `requesting-code-review` | Review formatinda hazirla |

KURAL: Superpowers skill'leri DIGER tool'lardan ONCE calisir. Ornegin:
- Feature gelistirme: superpowers:brainstorming → /ce-brainstorm → /ce-plan → superpowers:writing-plans → superpowers:test-driven-development → implement
- Bug fix: superpowers:systematic-debugging → analiz → fix → superpowers:verification-before-completion
- Paralel is: superpowers:dispatching-parallel-agents → subagent'lar → superpowers:verification-before-completion

Superpowers slash komutlari:
- `/brainstorm` - Hizli brainstorm baslat
- `/write-plan` - Detayli plan yaz
- `/execute-plan` - Plani calistir

## Workflow Hierarchy (Zorunlu Akis)

Her is bu siralamayla ilerler. Asama atlama.

### 1. YENI PROJE BASLANGICI
```
superpowers:brainstorming → Projeyi kesfet
GSD /gsd:new-project      → Proje dosyalarini olustur
GSD /gsd:discuss-phase    → Gereksinimleri tart
GSD /gsd:plan-phase       → Spec-driven plan olustur
```

### 2. FEATURE GELISTIRME (her feature icin)
```
superpowers:brainstorming      → Fikri kesfet (ZORUNLU - atlama)
Compound /ce-brainstorm        → Alternatifleri degerlendir, docs/brainstorms/'a kaydet
superpowers:writing-plans      → Plan yaz
Compound /ce-plan              → Detayli implementation plani (checkbox'lu)
```

### 3. IMPLEMENTATION (her task icin)
```
superpowers:test-driven-development → TDD mindset aktif (ZORUNLU)
Context7 MCP                        → Kullanilacak library'nin docs'unu cek
Pilot /spec (varsa)                 → Spec yaz
Pilot /spec-implement (varsa)       → RED → GREEN → REFACTOR
VEYA:
  Test dosyasini ONCE yaz (RED)
  Implementation yaz (GREEN)
  Refactor et
```

### 4. REVIEW & COMPOUND
```
superpowers:verification-before-completion → Is bitti demeden dogrula
Compound /ce-review                        → Multi-agent code review
Compound /ce-compound                      → Ogrenimleri kaydet
```

### 5. VERIFICATION
```
GSD /gsd:verify-work → Proje seviyesinde dogrulama
```

### 6. BUG/HATA DURUMUNDA
```
superpowers:systematic-debugging → ONCE analiz et, tahmin etme
ECC deep-research skill          → Derinlemesine arastir
Context7 MCP                     → Ilgili library docs'unu cek
Fix → Test → superpowers:verification-before-completion
```

## Skill Kullanimi

### Superpowers Skills (HER ZAMAN)
- `brainstorming` → Creative is oncesi ZORUNLU
- `writing-plans` → Plan yazarken
- `systematic-debugging` → Hata/bug durumunda
- `test-driven-development` → Implementation oncesi
- `verification-before-completion` → Is bitiminde
- `dispatching-parallel-agents` → Paralel isler icin

### ECC Skills (Domain-specific)
- `deep-research` → Derinlemesine arastirma
- `search-first` → Arastirma-first yaklasim
- `frontend-patterns` → React/Next.js/UI
- `api-design` → API tasarimi
- `postgres-patterns` → DB patterns
- `backend-patterns` → Backend
- `security-review` → Guvenlik
- `docker-patterns`, `deployment-patterns` → DevOps

### wshobson Skills (Progressive disclosure)
- `tdd-red`, `tdd-green`, `tdd-cycle` → TDD adim adim
- `nextjs-app-router-patterns` → Next.js App Router
- `react-state-management` → React state
- `postgresql` → PostgreSQL derinlemesine
- `full-stack-feature` → Fullstack feature akisi

## Agent Dispatch Kurallari

### Superpowers Agent
- `superpowers:code-reviewer` → En kapsamli code review

### ECC Agents
- `architect` → Sistem tasarimi kararlari
- `code-reviewer` → Code review
- `database-reviewer` → DB review
- `security-reviewer` → Security audit
- `e2e-runner` → E2E test
- `tdd-guide` → TDD yonlendirmesi

### Compound Agents (28)
- `compound-engineering:review:*` → 15 review agent (architecture, security, performance, data-integrity...)
- `compound-engineering:research:*` → 5 research agent (framework docs, git history, best practices...)
- `compound-engineering:design:*` → 3 design agent (figma-design-sync, design-iterator...)

### wshobson Agents
- `backend-architect` → Backend mimari
- `database-architect`, `sql-pro` → DB
- `tdd-orchestrator` → TDD orkestrasyon
- `frontend-developer`, `mobile-developer` → UI
- `security-auditor` → Guvenlik

### GSD Agents (15)
- `gsd-planner`, `gsd-executor`, `gsd-verifier` → Plan/execute/verify dongusu
- `gsd-debugger` → Debug
- `gsd-phase-researcher` → Arastirma

## MCP Kullanimi

| MCP | NE ZAMAN | ZORUNLU MU |
|-----|----------|------------|
| Context7 | Herhangi bir library/framework kullanmadan ONCE | EVET |
| Figma | UI implement ederken | Tasarim varsa EVET |
| Playwright | UI degisikliginden sonra | Frontend varsa EVET |
| Supabase | DB operations | Backend varsa EVET |
| GitHub | PR/issue yonetimi | EVET |

## Kalite Kurallari

1. **Superpowers-first**: HER is superpowers skill ile baslar
2. **Brainstorm-first**: Creative is = once superpowers:brainstorming
3. **Context7-first**: Library kullanmadan ONCE Context7'den docs cek
4. **Test-first**: Her implementation TDD ile baslar
5. **Verify-before-done**: superpowers:verification-before-completion ZORUNLU
6. **Debug-systematic**: Hata = superpowers:systematic-debugging (tahmin etme)
7. **Review zorunlu**: PR oncesi /ce-review
8. **Knowledge compound**: Feature sonrasi /ce-compound

## Yasaklar

- Superpowers brainstorming OLMADAN creative ise BASLAMA
- Superpowers verification OLMADAN is bitti DEME
- Test olmadan implementation YAZMA
- Context7 olmadan library KULLANMA
- GSD olmadan projeye BASLAMA
- Review olmadan PR ACMA
- Bug'i tahmin ederek fix etmeye CALISMA (systematic-debugging kullan)
- `any` type KULLANMA (TypeScript)
- Emoji icon KULLANMA (Lucide/Heroicons kullan)
