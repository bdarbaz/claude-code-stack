# Claude Code ile Web + Mobile Stack Analizi
## 9 Repo Derinlemesine İnceleme — Berkan İçin

---

## TIER 1: MUTLAKA KULLAN

### 1. everything-claude-code (78.6K ⭐)
**Ne:** Claude Code için en kapsamlı skill/agent/command kütüphanesi

**İçindekiler:**
- **94 Skill** — React patterns, SwiftUI, Django, Spring Boot, Go, Kotlin Ktor, Android clean architecture, database migrations, E2E testing, TDD, security review, article writing, investor materials, presentation generation, design systems...
- **18 Agent** — planner, architect, code-reviewer, tdd-guide, security-reviewer, refactor-cleaner, e2e-runner, doc-updater, build-error-resolver, database-reviewer, chief-of-staff, loop-operator, harness-optimizer + dil-spesifik reviewer'lar (Go, Kotlin, Python)
- **48 Slash Command** — `/plan`, `/tdd`, `/code-review`, `/build-fix`, `/e2e`, `/refactor-clean`, `/learn`, `/checkpoint`, `/verify`, `/skill-create`, `/multi-plan`, `/sessions`...
- **13+ Hook** — pre-tool-use (dev server setup, git reminders), post-tool-use (formatting, type checking), pre-compact (state saving), stop/session-end (persistence, evaluation, cost tracking), session-start (context loading)
- **24 MCP Server Config** — GitHub, Vercel, Railway, Supabase, Clickhouse, Firecrawl, Exa search, Playwright, fal-ai, Confluence...
- **45+ Rule Dosyası** — Go, Kotlin, Perl, PHP, Python, Swift, TypeScript coding standards + universal rules
- **CLAUDE.md şablonu** hazır
- **Strictness profilleri:** minimal, standard, strict

**Web + Mobile için öne çıkanlar:**
- React patterns skill
- Android clean architecture skill
- Swift concurrency & SwiftUI skills
- Django, Spring Boot, Kotlin Ktor backend skills
- E2E testing workflow
- Design systems skill

**Nasıl kullan:** Stack'inin "skill kütüphanesi" katmanı. İhtiyacın olan skill'leri cherry-pick yaparak `.claude/` klasörüne kopyala.

---

### 2. get-shit-done / GSD (30.7K ⭐)
**Ne:** Spec-driven, context-engineering framework — "context rot" problemini çözer

**İçindekiler:**
- **16 Specialized Agent** — Planner, Executor, Debugger, Verifier, Phase Researcher (4 paralel), Plan Checker, Roadmapper, Codebase Mapper, Integration Checker, UI agents
- **37 CLI Command** — `new-project → discuss → plan → execute → verify` döngüsü + phase management, UI design, milestone tracking
- **Context Dosya Sistemi:**
  - `.planning/PROJECT.md` — Proje vizyonu & kısıtlamalar
  - `.planning/REQUIREMENTS.md` — ID'li gereksinimler
  - `.planning/ROADMAP.md` — Fazlar, bağımlılıklar, başarı kriterleri
  - `.planning/STATE.md` — Pozisyon, kararlar, performans metrikleri
  - `.planning/config.json` — Workflow konfigürasyonu
  - Faz-spesifik: CONTEXT.md, RESEARCH.md, PLAN.md, SUMMARY.md, VALIDATION.md, UI-SPEC.md, UAT.md
- **4 Model Profili:** Quality (Opus-heavy), Balanced (default), Budget (Sonnet/Haiku), Inherit
- **3 Hook:** Context monitor (35% ve 25% uyarı), statusline tracker, update checker
- **Wave-based paralel execution** — Her executor'a temiz 200K context
- **XML task yapısı** — Concrete values, verification steps, acceptance criteria
- **Nyquist validation** — Test coverage'ı requirements'a map'ler
- **UI contracts** — Design locking before execution
- **Brownfield support** — Mevcut codebase'leri analiz eder

**Desteklenen runtime'lar:** Claude Code, OpenCode, Gemini CLI, Codex, Copilot, Antigravity

**Nasıl kullan:** Stack'inin "proje yönetim ve orchestration" katmanı. Her yeni proje `gsd new-project` ile başlar, discuss → plan → execute → verify döngüsüyle ilerler.

---

### 3. pilot-shell (1.5K ⭐)
**Ne:** TDD-zorunlu, kalite-odaklı Claude Code geliştirme ortamı

**İçindekiler:**
- **6 Ana Command:** `/spec` (dispatcher), `/spec-plan` (Opus ile planning), `/spec-implement` (TDD-driven), `/spec-verify` (code review + E2E), `/spec-bugfix-plan`, `/sync`
- **TDD Enforcement (Zorunlu):**
  - RED → GREEN → REFACTOR döngüsü
  - Hook her file edit'i izler — test olmadan implementation = uyarı
  - %80 minimum coverage zorunlu
  - Property-based testing (hypothesis/fast-check)
  - Mock audit: HTTP, subprocess, file I/O, database, external APIs
- **Smart Model Routing:**
  - Planning → Opus (derin reasoning)
  - Plan Review → Sonnet (validasyon)
  - Implementation → Sonnet (hızlı, cost-effective)
  - Code Review → Sonnet (compliance)
- **17 Hook (7 lifecycle event):**
  - SessionStart: Memory loader, post-compaction restore, session tracker
  - UserPromptSubmit: Spec mode guard, session initializer
  - PreToolUse: Tool redirect, token saver (RTK proxy %60-90 tasarruf)
  - PostToolUse: File checker (ruff, pyright, prettier, eslint, tsc, gofmt, golangci-lint), TDD checker, context monitor, memory observer
  - PreCompact: Plan + task list + context → persistent memory
  - Stop: Spec stop guard, plan validators
  - SessionEnd: Worker daemon cleanup
- **18 Built-in Rule:** task-and-workflow, testing, verification, development-practices, context-management, pilot-memory, cli-tools, research-tools, mcp-servers, playwright-cli, skill-sharing, code-review-reception + dil-spesifik standards (Python, TS, Go, frontend, backend)
- **6 MCP Server:** context7, codebase-memory-mcp, mem-search, web-search, grep-mcp, web-fetch
- **Dashboard:** localhost:41777 — 8 view (Dashboard, Specifications, Changes, Memories, Sessions, Share, Usage, Settings)
- **Worktree isolation** — Main branch her zaman temiz
- **Skill Sharing** — Cross-project ve cross-team (50+ AI tool ile)
- **Auto-compaction** ile state preservation
- **Token optimization** — %60-90 tasarruf (RTK proxy)

**Nasıl kullan:** Stack'inin "kalite kontrol ve TDD" katmanı. Her feature `/spec` ile başlar, plan → implement → verify döngüsüyle tamamlanır. Hook'lar otomatik olarak lint/format/type-check yapar.

---

### 4. compound-engineering-plugin (10.4K ⭐)
**Ne:** %80 planlama, %20 execution felsefeli mühendislik disiplini framework'ü

**İçindekiler:**
- **5-Aşama Workflow:**
  1. `/ce:brainstorm` — NE inşa edeceğini keşfet
  2. `/ce:plan` — Brainstorm'ları auto-load, pattern research, detaylı plan
  3. `/ce:work` — Plan execution, system-wide test checks, incremental commits
  4. `/ce:review` — Multi-agent code review, ultra-thinking, todo creation
  5. `/ce:compound` — Çözümleri dokümante et → kurumsal bilgi birikimi
- **28 Agent:** 15 review, 5 research, 3 design, 4 workflow, 1 docs
- **46 Skill:** 5 core workflow, 7 development tools, 7 content/workflow, 3 resolution, 2 orchestration, 10+ utilities
- **22 Command:** 5 workflow (ce: prefix), 5 deprecated alias, 12 utility
- **1 MCP Server:** Context7 (100+ framework dokümantasyonu)
- **Knowledge Compounding Sistemi:**
  - `docs/brainstorms/` — Kararlar ve gerekçeler (planlama'ya beslenir)
  - `docs/plans/` — Detaylı implementasyonlar (checkbox'lu)
  - `docs/solutions/` — Geçmiş çözümler, kategorize (review sırasında yüzeye çıkar)
- **Plan detail levels:** MINIMAL (quick) → MORE (standard) → A LOT (comprehensive)
- **Review priority:** P1 CRITICAL, P2 IMPORTANT, P3 NICE-TO-HAVE
- **Worktree pattern** — İzole development branch'ler
- **Cross-tool sync** — OpenCode, Codex, Copilot, Windsurf, Gemini uyumlu

**Nasıl kullan:** Stack'inin "mühendislik disiplini ve bilgi birikimi" katmanı. Her feature `/ce:brainstorm` ile başlar, compound ile biter — öğrenmeler birikerek büyür.

---

## TIER 2: REFERANS OLARAK TUT

### 5. awesome-claude-code (28.5K ⭐)
**Ne:** Claude Code ekosisteminin en kapsamlı dizini

**İçindeki kategoriler ve sayılar:**
- **17+ Agent Skills** — AgentSys, Book Factory, cc-devops-skills, Claude Codex Settings, Claude Scientific Skills, Codex Skill, Compound Engineering, Context Engineering Kit, Everything Claude Code, Fullstack Dev Skills (65 skill + Jira), read-only-postgres, Superpowers, Trail of Bits, TÂCHES, Web Assets Generator...
- **30+ Workflow & Knowledge Guide** — AB Method, Agentic Workflow Patterns, Claude Code PM, Claude Code Tips (35+ tip), Claude CodePro, Context Priming, Design Review Workflow, Laravel TALL Stack Kit, RIPER Workflow, Simone...
- **50+ Tool** — cc-sessions, cchistory, cclogviewer, Claude Hub, Container Use, ContextKit, SuperClaude, VoiceMode MCP...
- **IDE Integrations** — VS Code, Emacs (2 paket), Neovim, Claudix
- **Usage Monitors** — CC Usage, ccflare, better-ccflare, Claudex, viberank
- **Orchestrators** — Auto-Claude, Claude Code Flow, Claude Squad, Claude Swarm, Claude Task Master, Happy Coder, sudocode, TSK
- **Config Managers** — claude-rules-doctor, ClaudeCTX
- **5 Status Line** — CCometixLine (Rust), ccstatusline, claude-powerline, claudia-statusline
- **5 Hook** — Britfix, CC Notify, cchooks, Claude Code Hook Comms, Parry (injection scanner)
- **40+ Slash Command** — Git, code analysis, testing, context loading, CI/deployment, task management
- **CLAUDE.md Files** — Python, JS/TS, Rust, Go, Java, PHP, Ruby, C/C++, Swift + domain-specific (DevOps, React, Vue, Django, Laravel, K8s)
- **Ralph Wiggum Technique** — 6+ repo (awesome-ralph, ralph-orchestrator, ralph-wiggum-bdd, The Ralph Playbook...)

**Nasıl kullan:** Yeni tool/skill/plugin keşfetmek istediğinde buraya bak. Ekosistem kataloğu olarak tut.

---

### 6. ralph-claude-code (Aktif, v0.11.5)
**Ne:** Otonom geliştirme döngüsü framework'ü

**İçindekiler:**
- **Autonomous loop** — Claude Code'u döngüde çalıştırır
- **Dual-condition exit gate** — HEM completion indicator HEM EXIT_SIGNAL gerekli
- **Circuit breaker** — 3 state (CLOSED, HALF_OPEN, OPEN), auto-recovery
- **Rate limiting** — 100 call/saat (configurable)
- **Session continuity** — `--resume` flag ile context preservation
- **566 test** (%100 pass rate) — 420 unit + 136 integration
- **Interactive wizard** — `ralph-enable` ile 5-fazlı kurulum
- **PRD import** — PDF, Word, markdown, JSON → Ralph formatı
- **Live monitoring** — `ralph-monitor` tmux dashboard
- **Stuck loop detection** — 3+ loop no-progress, 5+ repeated error

**Nasıl kullan:** Gece boyu çalışan autonomous development loop'lar için. GSD + pilot-shell kurulduktan sonra ekle.

---

### 7. happy (Aktif)
**Ne:** Claude Code'u mobil/web'den uzaktan kontrol

**İçindekiler:**
- **Multi-platform:** iOS (native), Android (React Native/Expo), Web, Desktop
- **E2E encryption** — Server hiçbir zaman şifresiz kod görmez
- **QR code pairing** — CLI ↔ mobil cihaz eşleştirme
- **One-keypress device switching** — Klavyeye basınca kontrol geri döner
- **Push notifications** — Permission request ve error alert'leri
- **Multi-AI support** — Claude, Gemini, Codex, ACP-compatible agents
- **Monorepo:** happy-app, happy-cli, happy-server, happy-agent, happy-wire

**Nasıl kullan:** Uzun task'larda masadan kalkmak istediğinde. Daha sonra ekle.

---

## TIER 3: ŞU AN GEREK YOK

### 8. Aperant (1.1K commit, 73 katkıcı)
**Ne:** Electron tabanlı multi-agent IDE — kendi başına büyük ekosistem

**İçindekiler:**
- **5 Agent tipi:** Spec Creator, Planner, Coder, QA Reviewer, QA Fixer
- **12 paralel terminal** — her biri ayrı agent
- **Kanban board** — görsel task management
- **9+ AI provider** — Anthropic, OpenAI, Google, Grok, DeepSeek, Ollama...
- **Vercel AI SDK v6** — streamText(), generateText()
- **Git worktree isolation** — task başına izole branch
- **AI-powered semantic merge** — otomatik conflict resolution
- **Graphiti memory system** — knowledge graph (optional Python sidecar)
- **GitHub/GitLab/Linear integration**
- **Insights Chat, Roadmap Generator, Ideation Engine, Changelog Generation**
- **Multi-account swapping** — rate limit'te otomatik geçiş
- **24+ Zustand store**, React UI, i18n (EN/FR)

**Neden şu an değil:** Claude Code CLI workflow'undan tamamen ayrı bir ekosistem. Kendi AI layer'ı var (Vercel AI SDK). Stack'ini karmaşıklaştırır. Ama ileride multi-agent desktop tool istersen referans olarak çok değerli.

---

### 9. trailofbits/skills (3.6K ⭐)
**Ne:** Güvenlik odaklı Claude Code skill marketplace

**İçindekiler (35 skill):**
- **Smart Contract Security (2):** building-secure-contracts, entry-point-analyzer
- **Code Auditing (12):** agentic-actions-auditor, audit-context-building, burpsuite-project-parser, differential-review, fp-check, insecure-defaults, semgrep-rule-creator, sharp-edges, static-analysis, supply-chain-risk-auditor, variant-analysis...
- **Verification (4):** constant-time-analysis, property-based-testing, spec-to-code-compliance, zeroize-audit
- **Malware/Reverse Eng (2):** yara-authoring, dwarf-expert
- **Mobile Security (1):** firebase-apk-scanner
- **General Dev (10):** ask-questions-if-underspecified, devcontainer-setup, gh-cli, git-cleanup, let-fate-decide, modern-python, second-opinion, skill-improver, workflow-skill-design, seatbelt-sandboxer

**Neden şu an değil:** %71'i security auditing odaklı. Web/mobile development ile doğrudan alakası düşük. Ama ileride security audit aşamasında `property-based-testing`, `differential-review`, `firebase-apk-scanner` işine yarayabilir. Skill yapısı (SKILL.md pattern) kendi skill'lerini yazarken referans olarak da kullanılabilir.

---

## ÖNERİLEN BİRLEŞİK STACK MİMARİSİ

```
┌─────────────────────────────────────────────────────┐
│                  SENİN PROJENİ                       │
│                                                      │
│  ┌─────────────────────────────────────────────┐    │
│  │  KATMAN 1: Proje Orchestration (GSD)         │    │
│  │  new-project → discuss → plan → execute →    │    │
│  │  verify — context rot yok, spec-driven       │    │
│  └─────────────────────────────────────────────┘    │
│                       ↓                              │
│  ┌─────────────────────────────────────────────┐    │
│  │  KATMAN 2: Mühendislik Disiplini (Compound)  │    │
│  │  brainstorm → plan → work → review →         │    │
│  │  compound — öğrenmeler birikir                │    │
│  └─────────────────────────────────────────────┘    │
│                       ↓                              │
│  ┌─────────────────────────────────────────────┐    │
│  │  KATMAN 3: Kalite & TDD (Pilot Shell)        │    │
│  │  /spec → plan(Opus) → implement(Sonnet) →    │    │
│  │  verify — 17 hook, auto lint/format/test     │    │
│  └─────────────────────────────────────────────┘    │
│                       ↓                              │
│  ┌─────────────────────────────────────────────┐    │
│  │  KATMAN 4: Skill Kütüphanesi (Everything CC) │    │
│  │  94 skill, 18 agent, 48 command, 24 MCP      │    │
│  │  → cherry-pick ihtiyacın olanları             │    │
│  └─────────────────────────────────────────────┘    │
│                                                      │
│  ┌─ SONRA EKLE ─────────────────────────────────┐   │
│  │  Ralph → Autonomous overnight loops           │   │
│  │  Happy → Mobile'dan uzaktan kontrol           │   │
│  │  awesome-claude-code → Yeni tool keşfi        │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## WEB + MOBILE İÇİN SPECIFIC SKILL'LER (everything-claude-code'dan)

**Frontend/Web:**
- React patterns, Design systems, Presentation generation
- TypeScript standards, Frontend standards

**Mobile:**
- Android clean architecture, Kotlin Multiplatform
- Swift concurrency, SwiftUI
- iOS-specific patterns

**Backend:**
- Django, Spring Boot, Go, Kotlin Ktor
- Database migrations, JPA patterns
- API design, Caching, Performance

**Testing:**
- TDD guide, E2E testing, Security review
- Verification loops, Coding standards

**DevOps/Deploy:**
- Docker, CI-CD, MCP configs (Vercel, Railway, Supabase)

---

## KATMAN 5: SÜPER KALİTE UI SİSTEMİ

Bu katman, mevcut 4 katmanın üzerine oturarak her üretilen UI'ın premium kalitede olmasını sağlar.

---

### A. UI/UX Pro Max Skill (42.1K ⭐) — TEMEL UI BEYNİ

**Ne:** Claude'un UI üretirken başvurduğu tasarım zekası motoru.

**İçindekiler:**
- **67 UI Stili** — Glassmorphism, Claymorphism, Minimalism, Brutalism, Neumorphism, Bento Grid, Dark Mode ve daha fazlası
- **161 Renk Paleti** — Her biri bir sektöre özel (banking, healthcare, e-commerce, SaaS, fintech...)
- **57 Font Eşleştirmesi** — Google Fonts'tan küratörlü kombinasyonlar
- **25 Chart Tipi** — Veri görselleştirme önerileri
- **99 UX Kuralı** — Best practice, anti-pattern, accessibility
- **161 Sektör-Spesifik Reasoning Kuralı** — Ürün tipine göre otomatik karar mantığı

**BM25 Ranking Motoru:**
- 5 paralel domain araması: Product type → Style → Color → Landing pattern → Typography
- Probabilistik ilgi skorlaması ile en uygun tasarım önerileri
- Anti-pattern filtresi (örn: bankacılık için mor AI gradient'leri engeller)

**Kalite Doğrulama Checklist'i (Pre-Delivery):**
1. **Görsel:** Emoji yerine SVG, tutarlı icon set (Heroicons/Lucide), hover shift yok, tema renkleri doğrudan kullanılmış
2. **Etkileşim:** Tüm tıklanabilirler `cursor-pointer`, hover feedback 150-300ms ease, focus state'ler görünür
3. **Light/Dark Mode:** Minimum 4.5:1 kontrast, glass elementler her modda görünür, border'lar her modda test edilmiş
4. **Layout & Responsive:** 320px, 768px, 1024px, 1440px'de test, horizontal scroll yok, fixed navbar content gizlemez
5. **Accessibility:** WCAG AA (4.5:1 kontrast), focus ring 3:1/2px min, alt text, ARIA label, klavye navigasyon

**Desteklenen 13 Tech Stack:**
- **Web:** HTML+Tailwind, React, Next.js, Astro, Vue, Nuxt.js, Nuxt UI, Svelte, shadcn/ui
- **Mobile:** SwiftUI, Jetpack Compose, React Native, Flutter

**Kurulum:** `npm install -g uipro-cli && uipro init --ai claude`

---

### B. MCP SERVER'LAR — TASARIM ARAÇLARI

**1. Figma MCP Server (Resmi Ortaklık — Şubat 2026)**
- Figma ↔ Claude Code iki yönlü köprü
- Design token'ları, component varyasyonları, spacing scale doğrudan Claude'a görünür
- Canlı UI'ı Figma'ya geri çevirebilir (code → design)
- Kurulum: `claude mcp add --transport http figma https://mcp.figma.com/mcp`

**2. Playwright MCP (Microsoft)**
- Claude'un ürettiği UI'ı tarayıcıda açıp screenshot alarak kendi çıktısını doğrulaması
- Visual testing, form doldurma, E2E test yazımı
- Mobil emülasyon desteği (device profiles)
- Kurulum: `claude mcp add playwright npx @playwright/mcp@latest`

**3. 21st.dev Magic MCP**
- `/ui` komutu ile anında component üretimi — v0 benzeri ama IDE-içi
- TypeScript desteği, real-time preview
- SVGL entegrasyonu (profesyonel marka logoları)
- shadcn/ui component'leri otomatik

**4. Storybook MCP Server**
- Component story'lerini, dokümantasyonu ve screenshot'ları Claude'a sunar
- Yeni component'ler için otomatik story üretimi
- Proje convention'larına uyum sağlar
- Kurulum: `claude mcp add storybook-mcp --transport http http://localhost:6006/mcp`

**5. Design Token Bridge MCP**
- Tailwind ↔ Figma ↔ Material 3 ↔ SwiftUI ↔ CSS Variables arası token çevirisi
- Web ve mobile arasında tutarlı tema
- Repo: github.com/kenneives/design-token-bridge-mcp

**6. Screenshot MCP**
- Her kod değişikliğinden sonra görsel doğrulama
- Claude kendi çıktısını görerek düzeltme yapabilir
- Layout, renk, spacing kontrolü

---

### C. COMPONENT STACK — WEB

**Üçlü Altın Standart: shadcn/ui + Tailwind CSS + Framer Motion**

- **shadcn/ui:** Copy-paste, accessible component primitive'leri. Claude Code ile doğal entegrasyon.
- **Tailwind CSS:** Utility-first, tree-shakeable, dark mode built-in (`dark:` prefix)
- **Framer Motion:** Gelişmiş animasyonlar — gesture, layout, exit animations

**Ek Kaynaklar:**
- **Aceternity UI** — 100+ animasyonlu component (shadcn + Framer Motion tabanlı)
- **Motion Primitives** — Framer Motion + shadcn entegrasyonu
- **Indie UI** — 20+ animasyonlu component

**Animasyon Kuralları:**
- View başına max 1-2 animasyon
- ease-out giriş, ease-in çıkış
- Sadece transform/opacity animate et (width/height/top/left YASAK)
- Her animasyon cause-effect ilişkisi ifade etmeli
- 150-300ms timing

---

### D. COMPONENT STACK — MOBILE (React Native + Expo)

**Temel Framework: React Native + Expo SDK 52+ (New Architecture)**

**Neden Expo:**
- File-based routing (Expo Router) — Next.js gibi, ama native
- iOS, Android ve Web tek codebase
- Universal deep linking otomatik
- OTA updates (EAS Update)

**Component Library: Tamagui (Önerilen)**
- %100 style parity web ↔ mobile
- Optimizing compiler — partial analysis, CSS extraction, tree flattening, dead code elimination
- Claude Code Tamagui Skill mevcut
- Google Fonts built-in

**Alternatifler:**
- **NativeWind** — Tailwind syntax'ı React Native'de (bg-blue-500, p-4)
- **Gluestack** — Universal, accessible component'ler (Next.js + Expo)

**Animasyonlar: React Native Reanimated + Gesture Handler**
- Worklet tabanlı — 60fps garanti
- Gesture.Pan(), Gesture.Tap() + GestureDetector
- Shared values ile responsive gesture feedback
- 19 referans rehber + Claude Code skill'i
- withDecay ile momentum animasyonları

**Mobile-Spesifik Skill'ler (Claude Code):**
- React Native Expo Claude Code Skill
- Tamagui Best Practices Skill
- React Native Reanimated Skills (19 guide)
- Mobile Design Skill (touch psychology, Fitts' Law)
- Expo Toolkit (init → app store submission)
- Mobile Developer Agent (RN 0.82+ specialist)
- Android Development Skill
- iOS Development Skill (Swift/SwiftUI)

---

### E. SHARED DESIGN SYSTEM — WEB + MOBILE

**Monorepo Yapısı:**
```
packages/
  core/          → Shared design tokens (renkler, spacing, typography)
  web/           → React component'leri (shadcn + Tailwind + Framer Motion)
  mobile/        → React Native component'leri (Tamagui + Reanimated)
  shared/        → Ortak hooks, state management, types, business logic
apps/
  web/           → Next.js app
  mobile/        → Expo app
```

**Design Token Akışı:**
```
Figma (MCP) → Design Token Bridge → core/ package
                                      ↓
                              ┌───────┴───────┐
                              ↓               ↓
                          web/ (Tailwind)  mobile/ (Tamagui)
```

**Araçlar:**
- **Nx** — Monorepo yönetimi, technology-independent kütüphaneler
- **Tamagui** — Universal component'ler (web + mobile %100 parity)
- **Bit** — Cross-platform design system paylaşımı

---

### F. KALİTE KONTROL — UI DOĞRULAMA

**Anthropic Resmi Frontend Design Skill (277K+ kurulum)**
- "AI slop" engelleyici — generic mor gradient, Inter font, aşırı rounded corner önler
- Tipografi stratejisi: Code (JetBrains Mono, Fira Code), Editorial (Playfair, Crimson), Startup (Clash Display, Satoshi)
- Renk felsefesi: Amaçlı renk kullanımı, rastgele gradient yok
- Motion & animation: Kasıtlı, dekoratif değil

**3 Strateji (Anthropic önerisi):**
1. Spesifik tasarım boyutlarını yönlendir (tipografi, renk, motion ayrı ayrı)
2. Tasarım ilhamları referans ver (IDE temaları, kültürel estetikler)
3. Kaçınılacak yaygın default'ları açıkça belirt

**CLAUDE.md'ye Eklenecekler (UI bölümü):**
```markdown
## Design System
- Spacing: 4px base unit (4, 8, 12, 16, 24, 32, 48, 64)
- Colors: [Figma MCP'den çekilir]
- Typography: [sektöre göre font pairing]
- Border radius: consistent (4px veya 8px, karışık değil)
- Shadows: 3 seviye (sm, md, lg)
- Transitions: 150-300ms ease-out
- YASAK: Inter font, mor AI gradient, emoji icon, generic rounded

## UI Quality Gates
- Her component 4 breakpoint'te test edilmeli
- Dark mode ayrıca test edilmeli
- Accessibility WCAG AA zorunlu
- Animasyonlar cause-effect ilişkisi içermeli
```

---

### G. UI WORKFLOW ÖZETİ

```
1. Figma'da tasarla (veya referans ver, veya sıfırdan iste)
       ↓
2. Figma MCP → Claude design token'ları ve component'leri görür
       ↓
3. UI/UX Pro Max → Sektöre özel stil, renk, tipografi otomatik seçilir
       ↓
4. Claude Code üretir:
   - Web → shadcn/ui + Tailwind + Framer Motion
   - Mobile → Tamagui + Reanimated + Expo Router
       ↓
5. Playwright MCP → Screenshot alır, Claude kendi çıktısını doğrular
       ↓
6. Storybook MCP → Component story'leri ve dokümantasyon otomatik
       ↓
7. Anthropic Frontend Skill → AI slop kontrolü, son kalite geçişi
```

---

## GÜNCEL TAM STACK MİMARİSİ (5 KATMAN)

```
┌──────────────────────────────────────────────────────────┐
│                    SENİN PROJENİ                          │
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │  KATMAN 1: Proje Orchestration (GSD)              │    │
│  │  discuss → plan → execute → verify                │    │
│  └──────────────────────────────────────────────────┘    │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐    │
│  │  KATMAN 2: Mühendislik Disiplini (Compound Eng.)  │    │
│  │  brainstorm → plan → work → review → compound     │    │
│  └──────────────────────────────────────────────────┘    │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐    │
│  │  KATMAN 3: Kalite & TDD (Pilot Shell)             │    │
│  │  /spec → plan(Opus) → implement(Sonnet) → verify  │    │
│  └──────────────────────────────────────────────────┘    │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐    │
│  │  KATMAN 4: Skill Kütüphanesi (Everything CC)      │    │
│  │  94 skill, 18 agent, 48 command, 24 MCP           │    │
│  └──────────────────────────────────────────────────┘    │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐    │
│  │  KATMAN 5: Süper UI Sistemi                        │    │
│  │                                                    │    │
│  │  Beyin: UI/UX Pro Max (67 stil, 161 palet, BM25)  │    │
│  │                                                    │    │
│  │  MCP'ler: Figma + Playwright + 21st.dev +          │    │
│  │           Storybook + Design Token Bridge +        │    │
│  │           Screenshot                               │    │
│  │                                                    │    │
│  │  Web Stack: shadcn/ui + Tailwind + Framer Motion   │    │
│  │  Mobile Stack: Tamagui + Reanimated + Expo Router  │    │
│  │                                                    │    │
│  │  Shared: Monorepo (Nx) + Design Token Bridge       │    │
│  │  Kalite: Anthropic Frontend Skill + Visual Testing  │    │
│  └──────────────────────────────────────────────────┘    │
│                                                           │
│  ┌─ SONRA EKLE ──────────────────────────────────────┐   │
│  │  Ralph → Autonomous overnight loops                │   │
│  │  Happy → Mobile'dan uzaktan kontrol                │   │
│  │  awesome-claude-code → Yeni tool keşfi             │   │
│  └───────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

---

*Oluşturulma tarihi: 16 Mart 2026*
*Berkan için hazırlanmıştır*
