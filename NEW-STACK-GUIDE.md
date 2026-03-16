# Yeni Stack Preset Oluşturma Rehberi

Yeni bir proje tipi icin stack preset eklemek istediginde bu rehberi takip et.

## 1. Ihtiyac Analizi

Kendine sor:
- **Tech stack ne?** (dil, framework, DB, cloud)
- **Frontend var mi?** (web, mobile, desktop)
- **Backend var mi?** (API, microservices, serverless)
- **Ozel domain var mi?** (AI/ML, blockchain, game, IoT)
- **TDD zorunlu mu?** (Pilot Shell gerekli mi)
- **UI tasarim var mi?** (Figma MCP lazim mi)

## 2. Kaynaklardan Secim Yap

### Framework'ler (core tools)
| Tool | Ne Zaman | Agirlik |
|------|----------|---------|
| GSD | HER preset'e (proje orchestration) | Hafif |
| Compound | HER preset'e (knowledge compounding) | Hafif |
| ECC | HER preset'e (skill kutuphanesi) | Hafif |
| Pilot Shell | Sadece buyuk/kritik projeler (TDD enforcement) | Agir |

### ECC Skills (cherry-pick)
Mevcut listeden sec: https://github.com/affaan-m/everything-claude-code/tree/main/skills

Web/Frontend: `frontend-patterns`, `liquid-glass-design`
Mobile: `swiftui-patterns`, `swift-concurrency-6-2`, `android-clean-architecture`, `compose-multiplatform-patterns`
Backend: `api-design`, `backend-patterns`, `postgres-patterns`, `database-migrations`, `django-patterns`, `springboot-patterns`, `golang-patterns`, `python-patterns`
Test: `tdd-workflow`, `e2e-testing`
Security: `security-review`
DevOps: `docker-patterns`, `deployment-patterns`
Research: `deep-research`, `search-first`

### Jeff Skills (cherry-pick)
Mevcut listeden sec: https://github.com/Jeffallan/claude-skills/tree/main/skills

Onemli olanlar: `nextjs-developer`, `react-expert`, `react-native-expert`, `typescript-pro`, `python-pro`, `golang-pro`, `flutter-expert`, `swift-expert`, `postgres-pro`, `rust-engineer`, `api-designer`, `database-optimizer`, `kubernetes-specialist`

### wshobson Plugins (marketplace)
Mevcut listeden sec: https://github.com/wshobson/agents/tree/main/plugins

HER preset'e: `comprehensive-review`, `debugging-toolkit`, `tdd-workflows`
Web: `javascript-typescript`, `frontend-mobile-development`, `ui-design`
Backend: `backend-development`, `api-scaffolding`, `api-testing-observability`, `database-design`
Mobile: `frontend-mobile-development`, `ui-design`
Security: `security-scanning`, `backend-api-security`
DevOps: `cicd-automation`, `kubernetes-operations`, `cloud-infrastructure`, `deployment-strategies`
AI/ML: `llm-application-dev`, `machine-learning-ops`
Data: `data-engineering`, `data-validation-suite`
Game: `game-development`
SEO: `seo-technical-optimization`
Blockchain: `blockchain-web3`

### VoltAgent Agents (cherry-pick)
Mevcut listeden sec: https://github.com/VoltAgent/awesome-claude-code-subagents/tree/main/categories

Core: `fullstack-developer.md`, `frontend-developer.md`, `backend-developer.md`, `api-designer.md`
Mobile: `mobile-developer.md`
Infra: `microservices-architect.md`
Electron: `electron-pro.md`

### MCP'ler
| MCP | Ne Zaman |
|-----|----------|
| context7 | HER ZAMAN (base'de) |
| github | HER ZAMAN (base'de) |
| figma | UI tasarim varsa |
| playwright | Web frontend varsa |
| supabase | Supabase kullaniyorsa |
| 21st-dev | shadcn/ui component uretimi |
| filesystem | Buyuk dosya islemleri |

### Plugins
| Plugin | Ne Zaman |
|--------|----------|
| superpowers | HER ZAMAN (base'de) |
| context7 | HER ZAMAN (base'de) |
| code-review | HER ZAMAN (base'de) |
| github | HER ZAMAN (base'de) |
| skill-creator | HER ZAMAN (base'de) |
| frontend-design | Frontend varsa |
| playwright | Web test varsa |

## 3. stack.sh'ye Ekle

### Adim 3a: Preset fonksiyonu yaz

```bash
preset_ISIM() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Aciklama${NC}"
    echo -e "${BOLD}================================================${NC}"

    # Base her zaman (superpowers, context7, code-review, github, skill-creator + deep-research, search-first, coding-standards, tdd-workflow)
    preset_base

    # Frameworks
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    # Pilot sadece buyuk projeler icin:
    # install_pilot

    # MCP'ler
    log_step "MCPS" "Proje-spesifik MCPs..."
    enable_plugins "frontend-design" "playwright"  # gerekirse
    mcp_figma      # gerekirse
    mcp_playwright  # gerekirse
    mcp_supabase    # gerekirse
    mcp_21st_dev    # gerekirse

    # Skills
    log_step "SKILLS" "Domain skills..."
    copy_skills_ecc "skill1" "skill2" "skill3"
    copy_skills_jeff "skill1" "skill2"
    copy_agents_ecc "agent1.md" "agent2.md"

    # Marketplace plugins
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "plugin1" "plugin2" "plugin3"
    copy_agents_volt "agent1.md" "agent2.md"

    # Harmony (preset ismi veya en yakin mevcut preset'i kullan)
    apply_harmony "web-nextjs"  # veya "saas", "api-backend", "mobile-rn"

    state_set "active_preset" '"ISIM"'
    echo -e "\n${GREEN}${BOLD}ISIM READY!${NC}\n"
}
```

### Adim 3b: Main case'e ekle

`stack.sh` dosyasinda `main()` fonksiyonundaki case'e ekle:
```bash
                ISIM)           preset_ISIM ;;
```

### Adim 3c: List'e ekle

`do_list()` fonksiyonuna ekle:
```bash
    echo -e "  ${CYAN}ISIM${NC}              Aciklama"
```

### Adim 3d: Harmony CLAUDE.md template (opsiyonel)

Eger mevcut preset'lerden (web-nextjs, saas, api-backend, mobile-rn, mobile-swift, mobile-flutter) hicbiri uygun degilse, `generate_claudemd()` fonksiyonuna yeni case ekle:

```bash
        ISIM)
            cat >> "$out" << 'EOF'

## Preset: ISIM
### Tech Stack
- ...
### Rules
- ...
EOF
            ;;
```

## 4. Test Et

```bash
# Syntax check
bash -n ~/claude-code-stack/stack.sh

# Install
./stack.sh install ISIM

# Status
./stack.sh status

# Check
./stack.sh check

# Claude'da test
claude --dangerously-skip-permissions
# Slash komutlari, agent'lar, skill'ler gorunuyor mu?

# Uninstall
./stack.sh uninstall

# Status temiz mi?
./stack.sh status
```

## 5. Commit

```bash
cd ~/claude-code-stack
git add stack.sh
git commit -m "feat: add ISIM preset - ACIKLAMA"
```

## Ornek: "IoT Embedded" Preset

```bash
preset_iot() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: IoT / Embedded Systems${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    log_step "SKILLS" "IoT skills..."
    copy_skills_ecc "coding-standards" "tdd-workflow" "security-review" "cpp-coding-standards"
    copy_skills_jeff "cpp-pro" "rust-engineer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "security-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "systems-programming" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "security-scanning"
    copy_agents_volt "backend-developer.md"
    apply_harmony "api-backend"
    state_set "active_preset" '"iot"'
    echo -e "\n${GREEN}${BOLD}IoT / Embedded READY!${NC}\n"
}
```

## Claude'a Prompt ile Yeni Stack Olusturma

Asagidaki prompt'u Claude'a ver, o sana preset fonksiyonunu yazar:

```
~/claude-code-stack/stack.sh dosyasini ve NEW-STACK-GUIDE.md'yi oku.
Yeni bir preset ekle: [PROJE TIPI ACIKLAMASI]
- Uygun ECC skill'leri, Jeff skill'leri, wshobson plugin'leri, VoltAgent agent'lari sec
- Uygun MCP'leri ekle
- stack.sh'ye preset fonksiyonunu, main case'i ve list'i ekle
- Test et (bash -n syntax check)
```
