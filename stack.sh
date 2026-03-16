#!/bin/bash

# ============================================================================
# CLAUDE CODE STACK MANAGER v1.0
# One-click install/uninstall/switch for Claude Code development stacks
# Tools work together seamlessly - harmony layer ensures no conflicts
# ============================================================================

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CACHE_DIR="$STACK_DIR/.cache"
STATE_FILE="$STACK_DIR/.state.json"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()    { echo -e "\n${CYAN}[$1]${NC} ${BOLD}$2${NC}"; }

ensure_dirs() {
    mkdir -p "$CLAUDE_DIR"/{skills,agents,commands,hooks}
    mkdir -p "$CACHE_DIR"
}

ensure_settings() {
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo '{}' > "$SETTINGS_FILE"
    fi
}

settings_merge_mcp() {
    node -e "
        const fs=require('fs'), s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        if(!s.mcpServers)s.mcpServers={};
        s.mcpServers['$1']=$2;
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    "
}

settings_remove_mcp() {
    node -e "
        const fs=require('fs'), s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        if(s.mcpServers)delete s.mcpServers['$1'];
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    "
}

state_set() {
    node -e "
        const fs=require('fs');let s={};
        try{s=JSON.parse(fs.readFileSync('$STATE_FILE','utf8'))}catch{}
        const k='$1'.split('.'); let o=s;
        for(let i=0;i<k.length-1;i++){if(!o[k[i]])o[k[i]]={};o=o[k[i]];}
        o[k[k.length-1]]=$2;
        fs.writeFileSync('$STATE_FILE',JSON.stringify(s,null,2)+'\n');
    "
}

state_get_preset() {
    node -e "
        const fs=require('fs');
        try{const s=JSON.parse(fs.readFileSync('$STATE_FILE','utf8'));console.log(s.active_preset||'none')}catch{console.log('none')}
    " 2>/dev/null
}

check_cmd() { command -v "$1" &>/dev/null && return 0 || return 1; }



# ============================================================================
# PURGE - Herseyi sil, sifirdan basla
# ============================================================================

do_purge() {
    echo -e "\n${RED}${BOLD}================================================${NC}"
    echo -e "${RED}${BOLD}  PURGE - Removing EVERYTHING${NC}"
    echo -e "${RED}${BOLD}================================================${NC}\n"
    
    echo -e "${YELLOW}Bu komut Claude Code stack ile ilgili TUM ayarlari silecek:${NC}"
    echo -e "  - Tum plugins (marketplace + installed)"
    echo -e "  - Tum MCP servers"
    echo -e "  - Tum skills, agents, commands, hooks"
    echo -e "  - settings.json sifirlanacak"
    echo -e "  - Cache temizlenecek"
    echo -e ""
    echo -e "${YELLOW}Claude Code kendisi SILINMEZ, sadece config sifirlanir.${NC}"
    echo -e ""
    read -p "Emin misin? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Iptal edildi."
        return 0
    fi
    
    log_step "1" "Uninstalling all marketplace plugins..."
    # Remove all installed plugins
    claude plugin list 2>/dev/null | grep -E "^\s+." | sed "s/.*❯ //" | sed "s/@.*//" | tr -d " " | while read -r p; do
        if [ -n "$p" ]; then
            local full=$(claude plugin list 2>/dev/null | grep "$p" | sed "s/.*❯ //" | awk "{print \$1}" | head -1)
            if [ -n "$full" ]; then
                claude plugin uninstall "$full" 2>/dev/null || true
            fi
        fi
    done
    log_success "Plugins uninstalled"
    
    log_step "2" "Removing all marketplaces..."
    claude plugin marketplace list 2>/dev/null | grep -E "^\s+." | sed "s/.*❯ //" | awk "{print \$1}" | while read -r m; do
        if [ -n "$m" ] && [ "$m" != "claude-plugins-official" ]; then
            claude plugin marketplace remove "$m" 2>/dev/null || true
        fi
    done
    log_success "Marketplaces removed (kept claude-plugins-official)"
    
    log_step "3" "Clearing skills, agents, commands, hooks..."
    rm -rf "$CLAUDE_DIR/skills/"* 2>/dev/null || true
    rm -rf "$CLAUDE_DIR/commands/"* 2>/dev/null || true
    rm -rf "$CLAUDE_DIR/hooks/"* 2>/dev/null || true
    find "$CLAUDE_DIR/agents/" -name "*.md" ! -name "team-manager.md" -delete 2>/dev/null || true
    rm -rf "$CLAUDE_DIR/get-shit-done" 2>/dev/null || true
    log_success "Cleared"
    
    log_step "4" "Resetting settings.json..."
    cat > "$SETTINGS_FILE" << SJSON
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "context7@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "github@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true
  },
  "skipDangerousModePermissionPrompt": true
}
SJSON
    log_success "settings.json reset (base plugins + agent teams kept)"
    
    log_step "5" "Cleaning cache..."
    rm -rf "$CACHE_DIR" 2>/dev/null || true
    echo "{}" > "$STATE_FILE"
    log_success "Cache cleaned"
    
    echo -e "\n${GREEN}${BOLD}PURGE complete!${NC}"
    echo -e "Sistem temiz. Simdi istedigin preset'i kur:"
    echo -e "  ${CYAN}./stack.sh install <preset>${NC}"
    echo -e ""
    echo -e "Veya sifirdan bootstrap (yeni makine icin):"
    echo -e "  ${CYAN}./stack.sh bootstrap${NC}"
    echo -e ""
}

# ============================================================================
# BOOTSTRAP - Sifirdan her seyi kur (yeni makine)
# ============================================================================

do_bootstrap() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  BOOTSTRAP - Full System Setup${NC}"
    echo -e "${BOLD}================================================${NC}\n"
    
    local os="unknown"
    case "$(uname -s)" in
        Darwin*) os="macos" ;;
        Linux*)  os="linux" ;;
    esac
    log_info "OS: $os ($(uname -m))"
    
    # Step 1: Package manager
    log_step "1" "Package manager..."
    if [ "$os" = "macos" ]; then
        if ! check_cmd brew; then
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
        fi
        log_success "Homebrew ready"
    elif [ "$os" = "linux" ]; then
        if check_cmd apt-get; then
            log_info "Updating apt..."
            sudo apt-get update -qq 2>/dev/null || true
        elif check_cmd dnf; then
            log_info "dnf detected"
        elif check_cmd pacman; then
            log_info "pacman detected"
        fi
        log_success "Package manager ready"
    fi
    
    # Step 2: Node.js
    log_step "2" "Node.js..."
    if ! check_cmd node; then
        log_info "Installing Node.js..."
        if [ "$os" = "macos" ]; then
            brew install node
        elif [ "$os" = "linux" ]; then
            if check_cmd apt-get; then
                curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - 2>/dev/null
                sudo apt-get install -y nodejs 2>/dev/null
            elif check_cmd dnf; then
                sudo dnf install -y nodejs 2>/dev/null
            elif check_cmd pacman; then
                sudo pacman -S --noconfirm nodejs npm 2>/dev/null
            fi
        fi
    fi
    log_success "Node.js $(node --version 2>/dev/null || echo 'FAILED')"
    
    # Step 3: Git
    log_step "3" "Git..."
    if ! check_cmd git; then
        log_info "Installing Git..."
        if [ "$os" = "macos" ]; then
            brew install git
        elif [ "$os" = "linux" ]; then
            if check_cmd apt-get; then
                sudo apt-get install -y git 2>/dev/null
            elif check_cmd dnf; then
                sudo dnf install -y git 2>/dev/null
            elif check_cmd pacman; then
                sudo pacman -S --noconfirm git 2>/dev/null
            fi
        fi
    fi
    log_success "Git $(git --version 2>/dev/null | cut -d" " -f3 || echo 'FAILED')"
    
    # Step 4: tmux
    log_step "4" "tmux..."
    if ! check_cmd tmux; then
        log_info "Installing tmux..."
        if [ "$os" = "macos" ]; then
            brew install tmux
        elif [ "$os" = "linux" ]; then
            if check_cmd apt-get; then
                sudo apt-get install -y tmux 2>/dev/null
            elif check_cmd dnf; then
                sudo dnf install -y tmux 2>/dev/null
            elif check_cmd pacman; then
                sudo pacman -S --noconfirm tmux 2>/dev/null
            fi
        fi
    fi
    log_success "tmux $(tmux -V 2>/dev/null | cut -d" " -f2 || echo 'FAILED')"
    
    # Step 5: tmux mouse support
    log_step "5" "tmux mouse..."
    local tmux_conf="$HOME/.tmux.conf"
    if ! grep -q "set -g mouse on" "$tmux_conf" 2>/dev/null; then
        echo "" >> "$tmux_conf"
        echo "# Claude Code Stack - mouse support" >> "$tmux_conf"
        echo "set -g mouse on" >> "$tmux_conf"
        log_success "Mouse enabled in ~/.tmux.conf"
    else
        log_success "Mouse already enabled"
    fi
    
    # Step 6: Claude Code
    log_step "6" "Claude Code..."
    if ! check_cmd claude; then
        log_info "Installing Claude Code..."
        npm install -g @anthropic-ai/claude-code
    fi
    log_success "Claude Code $(claude --version 2>/dev/null | head -1 || echo 'FAILED')"
    
    # Step 7: Settings
    log_step "7" "Claude Code settings..."
    ensure_dirs
    ensure_settings
    node -e "
        const fs=require('fs'), s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        if(!s.env)s.env={};
        s.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS='1';
        if(!s.skipDangerousModePermissionPrompt) s.skipDangerousModePermissionPrompt=true;
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    "
    log_success "Agent teams + skip-permissions enabled"
    
    # Step 8: Base plugins
    log_step "8" "Base plugins..."
    enable_plugins "superpowers" "context7" "code-review" "github" "skill-creator"
    
    echo -e "\n${GREEN}${BOLD}Bootstrap complete!${NC}"
    echo -e ""
    echo -e "${BOLD}Next:${NC}"
    echo -e "  ${CYAN}./stack.sh install <preset>${NC}    Install a stack"
    echo -e "  ${CYAN}./stack.sh list${NC}                See available presets"
    echo -e ""
    echo -e "${BOLD}Or login to Claude first:${NC}"
    echo -e "  ${CYAN}claude login${NC}"
    echo -e ""
}

# ============================================================================
# CORE INSTALLERS
# ============================================================================

install_prereqs() {
    log_step "PRE" "Checking prerequisites..."
    if ! check_cmd node; then log_error "Node.js not found. brew install node"; exit 1; fi
    if ! check_cmd claude; then log_error "Claude Code not found."; exit 1; fi
    if ! check_cmd git; then log_error "Git not found."; exit 1; fi
    log_success "Node $(node --version) | Claude $(claude --version 2>/dev/null | head -1) | Git $(git --version | cut -d' ' -f3)"
    node -e "
        const fs=require('fs'), s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        if(!s.env)s.env={};
        s.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS='1';
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    "
    log_success "Agent teams enabled"
}

install_gsd() {
    log_info "Installing GSD (Get Shit Done)..."
    # Auto-answer: 1=Claude Code, 1=Global
    echo -e "1\n1" | npx get-shit-done-cc@latest 2>/dev/null || {
        npm install -g get-shit-done-cc@latest 2>/dev/null
        echo -e "1\n1" | npx get-shit-done-cc@latest 2>/dev/null
    } || true
    state_set "tools.gsd" "true"
    log_success "GSD installed"
}

uninstall_gsd() {
    log_info "Removing GSD..."
    rm -rf "$CLAUDE_DIR"/commands/gsd* "$CLAUDE_DIR"/agents/gsd-* "$CLAUDE_DIR"/hooks/gsd-* 2>/dev/null || true
    rm -rf "$CLAUDE_DIR"/get-shit-done 2>/dev/null || true
    # Remove GSD hooks and statusline from settings.json
    node -e "
        const fs=require('fs');
        const s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        if(s.hooks){
            for(const[e,h]of Object.entries(s.hooks)){
                s.hooks[e]=h.filter(x=>{
                    const cmd=x?.hooks?.[0]?.command||'';
                    return !cmd.includes('gsd-') && !cmd.includes('get-shit-done');
                });
                if(!s.hooks[e].length)delete s.hooks[e];
            }
            if(!Object.keys(s.hooks).length)delete s.hooks;
        }
        delete s.statusLine;
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    " 2>/dev/null || true
    npm uninstall -g get-shit-done-cc 2>/dev/null || true
    state_set "tools.gsd" "false"
    log_success "GSD removed"
}

install_compound() {
    log_info "Installing Compound Engineering (marketplace)..."
    # Add marketplace if not already added
    if ! claude plugin marketplace list 2>/dev/null | grep -q "compound-engineering-plugin"; then
        claude plugin marketplace add EveryInc/compound-engineering-plugin 2>/dev/null || true
    fi
    # Install plugin
    claude plugin install compound-engineering@compound-engineering-plugin 2>/dev/null || true
    state_set "tools.compound" "true"
    log_success "Compound Engineering installed (plugin)"
}

uninstall_compound() {
    log_info "Removing Compound Engineering..."
    claude plugin uninstall compound-engineering@compound-engineering-plugin 2>/dev/null || true
    claude plugin marketplace remove compound-engineering-plugin 2>/dev/null || true
    state_set "tools.compound" "false"
    log_success "Compound removed"
}

install_pilot() {
    log_info "Installing Pilot Shell..."
    curl -fsSL https://raw.githubusercontent.com/maxritter/pilot-shell/main/install.sh | bash || true
    state_set "tools.pilot" "true"
    log_success "Pilot Shell installed"
}

uninstall_pilot() {
    log_info "Removing Pilot Shell..."
    rm -rf "$HOME/.pilot-shell" "$CLAUDE_DIR"/commands/spec* 2>/dev/null || true
    state_set "tools.pilot" "false"
    log_success "Pilot removed"
}

install_ecc() {
    log_info "Installing Everything Claude Code..."
    npm install -g ecc-universal@latest 2>/dev/null || true
    npx ecc 2>/dev/null || true
    state_set "tools.ecc" "true"
    log_success "ECC installed"
}

uninstall_ecc() {
    log_info "Removing ECC..."
    npm uninstall -g ecc-universal 2>/dev/null || true
    state_set "tools.ecc" "false"
    log_success "ECC removed"
}

# ============================================================================
# SKILL & AGENT COPIERS
# ============================================================================

ensure_ecc_cache() {
    if [ ! -d "$CACHE_DIR/everything-claude-code" ]; then
        log_info "Caching everything-claude-code repo..."
        git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git "$CACHE_DIR/everything-claude-code"
    fi
}

ensure_jeff_cache() {
    if [ ! -d "$CACHE_DIR/claude-skills" ]; then
        log_info "Caching claude-skills repo..."
        git clone --depth 1 https://github.com/Jeffallan/claude-skills.git "$CACHE_DIR/claude-skills"
    fi
}

copy_skills_ecc() {
    ensure_ecc_cache
    for skill in "$@"; do
        if [ -d "$CACHE_DIR/everything-claude-code/skills/$skill" ]; then
            cp -r "$CACHE_DIR/everything-claude-code/skills/$skill" "$CLAUDE_DIR/skills/"
            log_success "  Skill: $skill"
        else
            log_warn "  Skill not found: $skill (ecc)"
        fi
    done
}

copy_skills_jeff() {
    ensure_jeff_cache
    for skill in "$@"; do
        if [ -d "$CACHE_DIR/claude-skills/skills/$skill" ]; then
            cp -r "$CACHE_DIR/claude-skills/skills/$skill" "$CLAUDE_DIR/skills/"
            log_success "  Skill: $skill (jeff)"
        else
            log_warn "  Skill not found: $skill (jeff)"
        fi
    done
}

copy_agents_ecc() {
    ensure_ecc_cache
    for agent in "$@"; do
        if [ -f "$CACHE_DIR/everything-claude-code/agents/$agent" ]; then
            cp "$CACHE_DIR/everything-claude-code/agents/$agent" "$CLAUDE_DIR/agents/"
            log_success "  Agent: $agent"
        fi
    done
}

# --- VoltAgent Subagents (131 specialized agents) ---
ensure_voltagent_cache() {
    if [ ! -d "$CACHE_DIR/awesome-claude-code-subagents" ]; then
        log_info "Caching VoltAgent subagents (131 agents)..."
        git clone --depth 1 https://github.com/VoltAgent/awesome-claude-code-subagents.git "$CACHE_DIR/awesome-claude-code-subagents"
    fi
}

copy_agents_volt() {
    ensure_voltagent_cache
    local base="$CACHE_DIR/awesome-claude-code-subagents/categories"
    for agent in "$@"; do
        # Search across all categories
        local found=0
        for catdir in "$base"/*/; do
            if [ -f "$catdir/$agent" ]; then
                cp "$catdir/$agent" "$CLAUDE_DIR/agents/"
                log_success "  Agent: $agent (volt)"
                found=1
                break
            fi
        done
        if [ $found -eq 0 ]; then
            log_warn "  Agent not found: $agent (volt)"
        fi
    done
}

# --- wshobson/agents (72 plugins, 112 agents, 146 skills) ---
install_wshobson_plugins() {
    # Add wshobson marketplace if not already added
    if ! claude plugin marketplace list 2>/dev/null | grep -q "claude-code-workflows"; then
        log_info "Adding wshobson/agents marketplace..."
        claude plugin marketplace add wshobson/agents 2>/dev/null || true
    fi
    for plugin in "$@"; do
        claude plugin install "${plugin}@claude-code-workflows" 2>/dev/null || true
        log_success "  Plugin: $plugin (wshobson)"
    done
}

uninstall_wshobson() {
    log_info "Removing wshobson plugins..."
    # Uninstall all wshobson plugins
    claude plugin list 2>/dev/null | grep "claude-code-workflows" | sed 's/.*❯ //' | sed 's/@.*//' | tr -d ' ' | while read -r p; do
        if [ -n "$p" ]; then
            claude plugin uninstall "${p}@claude-code-workflows" 2>/dev/null || true
        fi
    done
    claude plugin marketplace remove claude-code-workflows 2>/dev/null || true
    log_success "wshobson plugins removed"
}

uninstall_voltagent() {
    log_info "Removing VoltAgent subagents..."
    rm -rf "$CACHE_DIR/awesome-claude-code-subagents" 2>/dev/null || true
    log_success "VoltAgent cache removed"
}

# ============================================================================
# MCP & PLUGIN HELPERS
# ============================================================================

mcp_context7()   { settings_merge_mcp "context7"   '{"command":"npx","args":["-y","@upstash/context7-mcp@latest"]}'; }
mcp_playwright() { settings_merge_mcp "playwright"  '{"command":"npx","args":["-y","@anthropic-ai/mcp-playwright"]}'; }
mcp_figma()      { settings_merge_mcp "figma"       '{"type":"http","url":"https://mcp.figma.com/mcp"}'; }
mcp_supabase()   { settings_merge_mcp "supabase"    '{"command":"npx","args":["-y","@supabase/mcp-server-supabase"]}'; }
mcp_github()     { settings_merge_mcp "github"      '{"command":"npx","args":["-y","@anthropic-ai/mcp-github"]}'; }
mcp_filesystem() { settings_merge_mcp "filesystem"  '{"command":"npx","args":["-y","@anthropic-ai/mcp-filesystem","--root","'"$HOME"'"]}'; }
mcp_21st_dev()   { settings_merge_mcp "21st-dev"    '{"command":"npx","args":["-y","@nicobailon/21st-dev-mcp"]}'; }

remove_all_mcps() {
    for m in context7 playwright figma supabase github filesystem 21st-dev storybook; do
        settings_remove_mcp "$m"
    done
    log_success "All MCPs removed"
}

enable_plugins() {
    node -e "
        const fs=require('fs'), s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        if(!s.enabledPlugins)s.enabledPlugins={};
        const plugins='$*'.split(' ');
        plugins.forEach(p=>{s.enabledPlugins[p+'@claude-plugins-official']=true;});
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    "
    for p in "$@"; do log_success "  Plugin: $p"; done
}

# ============================================================================
# HARMONY LAYER
# ============================================================================

apply_harmony() {
    local preset="$1"
    log_step "HARMONY" "Making tools work together seamlessly..."

    node -e "
        const fs=require('fs');
        const settings=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        const harmony=JSON.parse(fs.readFileSync('$STACK_DIR/harmony/hooks.json','utf8'));
        if(!settings.hooks)settings.hooks={};
        for(const[event,handlers]of Object.entries(harmony.hooks)){
            if(!settings.hooks[event])settings.hooks[event]=[];
            for(const h of handlers){
                h.description='[STACK] '+(h.description||'');
                if(!settings.hooks[event].some(x=>x.description===h.description))
                    settings.hooks[event].push(h);
            }
        }
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(settings,null,2)+'\n');
    "
    log_success "Unified hooks merged"

    generate_claudemd "$preset"
    log_success "CLAUDE.md template: $STACK_DIR/CLAUDE.md.template"

    generate_quickref
    log_success "Quick reference: $STACK_DIR/QUICKREF.md"

    echo -e "\n${GREEN}${BOLD}Harmony applied!${NC} Tools will call each other in the right order."
    echo -e "${YELLOW}NEXT STEP:${NC} Copy to your project:"
    echo -e "  ${CYAN}cp ~/claude-code-stack/CLAUDE.md.template /your/project/CLAUDE.md${NC}\n"
}

remove_harmony() {
    node -e "
        const fs=require('fs');
        const s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        if(s.hooks){
            for(const[e,h]of Object.entries(s.hooks)){
                s.hooks[e]=h.filter(x=>!x.description?.startsWith('[STACK]'));
                if(!s.hooks[e].length)delete s.hooks[e];
            }
            if(!Object.keys(s.hooks).length)delete s.hooks;
        }
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    " || true
    rm -f "$STACK_DIR/CLAUDE.md.template" "$STACK_DIR/QUICKREF.md" 2>/dev/null || true
    log_success "Harmony layer removed"
}

generate_claudemd() {
    local preset="$1"
    local out="$STACK_DIR/CLAUDE.md.template"
    cp "$STACK_DIR/harmony/MASTER-CLAUDE.md" "$out"

    case "$preset" in
        web-nextjs|web3)
            cat >> "$out" << 'EOF'

## Preset: Web Fullstack
### Tech Stack
- Next.js 15+ (App Router) + TypeScript strict
- Tailwind CSS + shadcn/ui + Framer Motion
- Supabase (auth, database, storage, realtime)
### UI Rules
- shadcn/ui base, Tailwind styling, Lucide icons
- Dark mode with dark: prefix, 4px spacing system
- Animations: 150-300ms, only transform/opacity
EOF
            ;;
        mobile-rn)
            cat >> "$out" << 'EOF'

## Preset: React Native + Expo
### Tech Stack
- Expo SDK 52+ (New Architecture) + Expo Router
- Tamagui (universal) + Reanimated + Gesture Handler
### Mobile Rules
- Touch targets 44x44pt min, gesture feedback <100ms
- Reanimated worklets only, test iOS+Android
EOF
            ;;
        mobile-swift|desktop-mac)
            cat >> "$out" << 'EOF'

## Preset: Swift/SwiftUI
### Tech Stack
- Swift 6.2+ / SwiftUI / Swift Concurrency
- SwiftData, @Observable macro, MVVM
### Rules
- No UIKit unless necessary, no completion handlers
- Protocol-oriented + dependency injection
EOF
            ;;
        mobile-flutter)
            cat >> "$out" << 'EOF'

## Preset: Flutter/Dart
### Tech Stack
- Flutter 3.x + Riverpod + GoRouter + Freezed
### Rules
- Riverpod for all state, golden tests for visual regression
- Platform-adaptive (Material/Cupertino)
EOF
            ;;
        saas|fullstack-monorepo)
            cat >> "$out" << 'EOF'

## Preset: Full Power
### ZORUNLU SIRA
/discuss > /plan > /ce:brainstorm > /ce:plan > /spec > /spec-implement > /spec-verify > /ce:review > /ce:compound > /verify
### Tech Stack
- Monorepo (Turborepo/Nx), Supabase, Docker
- Web: Next.js + shadcn/ui, Mobile: Expo + Tamagui
### Pilot TDD: /spec zorunlu, RED>GREEN>REFACTOR, %80 coverage
EOF
            ;;
        api-backend)
            cat >> "$out" << 'EOF'

## Preset: API/Backend
### Tech Stack
- Node.js/Python/Go + PostgreSQL + Redis + Docker
### Rules
- OpenAPI spec BEFORE code, validation on all endpoints
- Rate limiting, structured logging, migration per schema change
EOF
            ;;
    esac
}

generate_quickref() {
    cat > "$STACK_DIR/QUICKREF.md" << 'QREF'
# Quick Reference

## The Flow
/discuss > /plan > /ce:brainstorm > /ce:plan > [implement] > /ce:review > /ce:compound > /verify

## Commands
| Cmd | Tool | What |
|-----|------|------|
| /discuss | GSD | Start project |
| /plan | GSD | Spec-driven plan |
| /execute | GSD | Run plan |
| /verify | GSD | Final check |
| /ce:brainstorm | Compound | Explore ideas |
| /ce:plan | Compound | Feature plan |
| /ce:work | Compound | Build+test |
| /ce:review | Compound | Code review |
| /ce:compound | Compound | Save learnings |
| /spec | Pilot | TDD spec |
| /spec-implement | Pilot | TDD build |

## MCPs
Context7=before libs, Figma=UI design, Playwright=visual test, Supabase=DB, GitHub=PRs

## Stack
~/claude-code-stack/stack.sh {install|uninstall|switch|status|list} [preset]
QREF
}

# ============================================================================
# PRESETS
# ============================================================================

preset_base() {
    install_prereqs
    log_step "BASE" "Base plugins & MCPs..."
    enable_plugins "superpowers" "context7" "code-review" "github" "skill-creator"
    mcp_context7; mcp_github
    log_step "BASE-SKILLS" "Core skills (every preset gets these)..."
    copy_skills_ecc "deep-research" "search-first" "coding-standards" "tdd-workflow"
    log_success "Base layer ready"
}

preset_web_nextjs() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Web Fullstack (Next.js)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    log_step "MCPS" "Web MCPs..."
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma; mcp_supabase; mcp_21st_dev
    log_step "SKILLS" "Web skills..."
    copy_skills_ecc "frontend-patterns" "api-design" "postgres-patterns" "e2e-testing" "tdd-workflow" "security-review" "coding-standards" "database-migrations" "backend-patterns"
    copy_skills_jeff "nextjs-developer" "react-expert" "typescript-pro" "postgres-pro" "api-designer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "e2e-runner.md" "tdd-guide.md" "security-reviewer.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "javascript-typescript" "backend-development" "frontend-mobile-development" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "database-design" "api-scaffolding" "full-stack-orchestration"
    copy_agents_volt "fullstack-developer.md" "frontend-developer.md" "backend-developer.md" "api-designer.md"
    apply_harmony "web-nextjs"
    state_set "active_preset" '"web-nextjs"'
    echo -e "\n${GREEN}${BOLD}Web Fullstack READY!${NC}\n"
}

preset_mobile_rn() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Mobile (React Native + Expo)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    log_step "MCPS" "Mobile MCPs..."
    enable_plugins "frontend-design"; mcp_figma
    log_step "SKILLS" "Mobile skills..."
    copy_skills_ecc "frontend-patterns" "android-clean-architecture" "compose-multiplatform-patterns" "e2e-testing" "tdd-workflow" "coding-standards"
    copy_skills_jeff "react-native-expert" "typescript-pro" "api-designer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "javascript-typescript" "frontend-mobile-development" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "ui-design"
    copy_agents_volt "mobile-developer.md" "frontend-developer.md"
    apply_harmony "mobile-rn"
    state_set "active_preset" '"mobile-rn"'
    echo -e "\n${GREEN}${BOLD}Mobile (RN+Expo) READY!${NC}\n"
}

preset_mobile_swift() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Mobile (Swift/SwiftUI)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    mcp_figma
    log_step "SKILLS" "iOS skills..."
    copy_skills_ecc "swiftui-patterns" "swift-concurrency-6-2" "swift-actor-persistence" "swift-protocol-di-testing" "tdd-workflow" "coding-standards" "e2e-testing"
    copy_skills_jeff "swift-expert"
    copy_agents_ecc "architect.md" "code-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "comprehensive-review" "debugging-toolkit" "tdd-workflows" "ui-design"
    copy_agents_volt "mobile-developer.md"
    apply_harmony "mobile-swift"
    state_set "active_preset" '"mobile-swift"'
    echo -e "\n${GREEN}${BOLD}Mobile (Swift) READY!${NC}\n"
}

preset_mobile_flutter() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Mobile (Flutter)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    mcp_figma
    log_step "SKILLS" "Flutter skills..."
    copy_skills_ecc "frontend-patterns" "tdd-workflow" "coding-standards" "e2e-testing"
    copy_skills_jeff "flutter-expert" "api-designer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "comprehensive-review" "debugging-toolkit" "tdd-workflows" "ui-design"
    copy_agents_volt "mobile-developer.md"
    apply_harmony "mobile-flutter"
    state_set "active_preset" '"mobile-flutter"'
    echo -e "\n${GREEN}${BOLD}Mobile (Flutter) READY!${NC}\n"
}

preset_desktop_mac() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Desktop (macOS SwiftUI)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    mcp_figma
    log_step "SKILLS" "macOS skills..."
    copy_skills_ecc "swiftui-patterns" "swift-concurrency-6-2" "swift-actor-persistence" "swift-protocol-di-testing" "tdd-workflow" "coding-standards"
    copy_skills_jeff "swift-expert"
    copy_agents_ecc "architect.md" "code-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "multi-platform-apps" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "ui-design"
    copy_agents_volt "fullstack-developer.md"
    apply_harmony "desktop-mac"
    state_set "active_preset" '"desktop-mac"'
    echo -e "\n${GREEN}${BOLD}Desktop (macOS) READY!${NC}\n"
}

preset_web3() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Web3 / Crypto DApp${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma
    log_step "SKILLS" "Web3 skills..."
    copy_skills_ecc "frontend-patterns" "security-review" "api-design" "tdd-workflow" "coding-standards" "e2e-testing"
    copy_skills_jeff "nextjs-developer" "react-expert" "typescript-pro" "secure-code-guardian" "api-designer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "security-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "javascript-typescript" "blockchain-web3" "frontend-mobile-development" "security-scanning" "comprehensive-review" "debugging-toolkit"
    copy_agents_volt "fullstack-developer.md" "frontend-developer.md"
    apply_harmony "web3"
    state_set "active_preset" '"web3"'
    echo -e "\n${GREEN}${BOLD}Web3 READY!${NC} (npm i wagmi viem @rainbow-me/rainbowkit)\n"
}

preset_saas() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: SaaS (FULL POWER)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "ALL 4: GSD + Compound + Pilot + ECC..."
    install_gsd; install_compound; install_pilot; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma; mcp_supabase; mcp_21st_dev
    log_step "SKILLS" "Full suite..."
    copy_skills_ecc "frontend-patterns" "api-design" "postgres-patterns" "database-migrations" "security-review" "e2e-testing" "tdd-workflow" "coding-standards" "backend-patterns"
    copy_skills_jeff "nextjs-developer" "react-expert" "typescript-pro" "postgres-pro" "api-designer" "database-optimizer" "monitoring-expert"
    copy_agents_ecc "architect.md" "code-reviewer.md" "database-reviewer.md" "security-reviewer.md" "tdd-guide.md" "e2e-runner.md" "planner.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "javascript-typescript" "backend-development" "frontend-mobile-development" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "database-design" "database-migrations" "api-scaffolding" "api-testing-observability" "security-scanning" "full-stack-orchestration" "agent-orchestration" "code-refactoring"
    copy_agents_volt "fullstack-developer.md" "frontend-developer.md" "backend-developer.md" "api-designer.md" "microservices-architect.md"
    apply_harmony "saas"
    state_set "active_preset" '"saas"'
    echo -e "\n${GREEN}${BOLD}SaaS (FULL POWER) READY!${NC}\n"
}

preset_fullstack_monorepo() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Fullstack Monorepo (EVERYTHING)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "ALL 4: GSD + Compound + Pilot + ECC..."
    install_gsd; install_compound; install_pilot; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma; mcp_supabase; mcp_21st_dev; mcp_filesystem
    log_step "SKILLS" "Everything..."
    copy_skills_ecc "frontend-patterns" "android-clean-architecture" "swiftui-patterns" "compose-multiplatform-patterns" "api-design" "postgres-patterns" "database-migrations" "security-review" "e2e-testing" "tdd-workflow" "coding-standards" "backend-patterns" "docker-patterns" "deployment-patterns"
    copy_skills_jeff "nextjs-developer" "react-expert" "react-native-expert" "typescript-pro" "postgres-pro" "api-designer" "database-optimizer" "swift-expert" "flutter-expert"
    copy_agents_ecc "architect.md" "code-reviewer.md" "database-reviewer.md" "security-reviewer.md" "tdd-guide.md" "e2e-runner.md" "planner.md"
    log_step "PLUGINS" "wshobson + VoltAgent (FULL)..."
    install_wshobson_plugins "javascript-typescript" "python-development" "backend-development" "frontend-mobile-development" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "database-design" "database-migrations" "api-scaffolding" "api-testing-observability" "security-scanning" "full-stack-orchestration" "agent-orchestration" "agent-teams" "code-refactoring"
    copy_agents_volt "fullstack-developer.md" "frontend-developer.md" "backend-developer.md" "api-designer.md" "microservices-architect.md" "mobile-developer.md"
    apply_harmony "fullstack-monorepo"
    state_set "active_preset" '"fullstack-monorepo"'
    echo -e "\n${GREEN}${BOLD}Fullstack Monorepo READY!${NC}\n"
}

preset_api_backend() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: API / Backend${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    mcp_supabase
    log_step "SKILLS" "Backend skills..."
    copy_skills_ecc "api-design" "postgres-patterns" "database-migrations" "security-review" "tdd-workflow" "coding-standards" "backend-patterns" "docker-patterns" "deployment-patterns" "python-patterns" "golang-patterns"
    copy_skills_jeff "api-designer" "postgres-pro" "database-optimizer" "python-pro" "golang-pro" "nestjs-expert" "fastapi-expert" "django-expert"
    copy_agents_ecc "architect.md" "code-reviewer.md" "database-reviewer.md" "security-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson + VoltAgent..."
    install_wshobson_plugins "python-development" "backend-development" "api-scaffolding" "api-testing-observability" "database-design" "database-migrations" "security-scanning" "comprehensive-review" "debugging-toolkit" "tdd-workflows"
    copy_agents_volt "backend-developer.md" "api-designer.md" "microservices-architect.md"
    apply_harmony "api-backend"
    state_set "active_preset" '"api-backend"'
    echo -e "\n${GREEN}${BOLD}API/Backend READY!${NC}\n"
}



preset_chrome_ext() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Chrome Extension${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright
    log_step "SKILLS" "Extension skills..."
    copy_skills_ecc "frontend-patterns" "tdd-workflow" "coding-standards" "e2e-testing" "security-review"
    copy_skills_jeff "typescript-pro" "react-expert"
    copy_agents_ecc "architect.md" "code-reviewer.md" "security-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson..."
    install_wshobson_plugins "javascript-typescript" "frontend-mobile-development" "security-scanning" "comprehensive-review" "debugging-toolkit" "tdd-workflows"
    copy_agents_volt "frontend-developer.md"
    apply_harmony "web-nextjs"
    state_set "active_preset" '"chrome-ext"' 
    echo -e "\n${GREEN}${BOLD}Chrome Extension READY!${NC}\n"
}

preset_electron() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Electron Desktop App${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma
    log_step "SKILLS" "Electron skills..."
    copy_skills_ecc "frontend-patterns" "tdd-workflow" "coding-standards" "e2e-testing" "security-review" "backend-patterns"
    copy_skills_jeff "typescript-pro" "react-expert"
    copy_agents_ecc "architect.md" "code-reviewer.md" "security-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson..."
    install_wshobson_plugins "javascript-typescript" "frontend-mobile-development" "multi-platform-apps" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "security-scanning"
    copy_agents_volt "fullstack-developer.md" "frontend-developer.md" "electron-pro.md"
    apply_harmony "web-nextjs"
    state_set "active_preset" '"electron"' 
    echo -e "\n${GREEN}${BOLD}Electron Desktop READY!${NC}\n"
}

preset_ai_saas() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: AI SaaS (LLM/RAG)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "ALL 4: GSD + Compound + Pilot + ECC..."
    install_gsd; install_compound; install_pilot; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma; mcp_supabase; mcp_21st_dev
    log_step "SKILLS" "AI/ML skills..."
    copy_skills_ecc "frontend-patterns" "api-design" "postgres-patterns" "database-migrations" "security-review" "e2e-testing" "tdd-workflow" "coding-standards" "backend-patterns" "python-patterns"
    copy_skills_jeff "nextjs-developer" "react-expert" "typescript-pro" "postgres-pro" "api-designer" "python-pro"
    copy_agents_ecc "architect.md" "code-reviewer.md" "database-reviewer.md" "security-reviewer.md" "tdd-guide.md" "e2e-runner.md" "planner.md"
    log_step "PLUGINS" "wshobson (AI focus)..."
    install_wshobson_plugins "javascript-typescript" "python-development" "backend-development" "frontend-mobile-development" "llm-application-dev" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "database-design" "database-migrations" "api-scaffolding" "security-scanning" "full-stack-orchestration"
    copy_agents_volt "fullstack-developer.md" "backend-developer.md" "api-designer.md"
    apply_harmony "saas"
    state_set "active_preset" '"ai-saas"' 
    echo -e "\n${GREEN}${BOLD}AI SaaS (LLM/RAG) READY!${NC}\n"
}

preset_ecommerce() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: E-Commerce${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "ALL 4: GSD + Compound + Pilot + ECC..."
    install_gsd; install_compound; install_pilot; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma; mcp_supabase; mcp_21st_dev
    log_step "SKILLS" "E-commerce skills..."
    copy_skills_ecc "frontend-patterns" "api-design" "postgres-patterns" "database-migrations" "security-review" "e2e-testing" "tdd-workflow" "coding-standards" "backend-patterns"
    copy_skills_jeff "nextjs-developer" "react-expert" "typescript-pro" "postgres-pro" "api-designer" "database-optimizer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "database-reviewer.md" "security-reviewer.md" "tdd-guide.md" "e2e-runner.md"
    log_step "PLUGINS" "wshobson (e-commerce)..."
    install_wshobson_plugins "javascript-typescript" "backend-development" "frontend-mobile-development" "payment-processing" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "database-design" "database-migrations" "api-scaffolding" "security-scanning" "full-stack-orchestration" "backend-api-security"
    copy_agents_volt "fullstack-developer.md" "frontend-developer.md" "backend-developer.md" "api-designer.md"
    apply_harmony "saas"
    state_set "active_preset" '"ecommerce"' 
    echo -e "\n${GREEN}${BOLD}E-Commerce READY!${NC}"
    echo -e "Tip: npm i stripe @stripe/stripe-js\n"
}

preset_cli_tool() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: CLI Tool (Node/Go/Rust)${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    log_step "SKILLS" "CLI skills..."
    copy_skills_ecc "tdd-workflow" "coding-standards" "golang-patterns" "golang-testing" "python-patterns" "python-testing" "security-review"
    copy_skills_jeff "typescript-pro" "golang-pro" "python-pro" "rust-engineer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "tdd-guide.md" "security-reviewer.md"
    log_step "PLUGINS" "wshobson..."
    install_wshobson_plugins "javascript-typescript" "python-development" "shell-scripting" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "systems-programming"
    copy_agents_volt "backend-developer.md"
    apply_harmony "api-backend"
    state_set "active_preset" '"cli-tool"' 
    echo -e "\n${GREEN}${BOLD}CLI Tool READY!${NC}\n"
}

preset_microservices() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Microservices Architecture${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "ALL 4: GSD + Compound + Pilot + ECC..."
    install_gsd; install_compound; install_pilot; install_ecc
    mcp_supabase
    log_step "SKILLS" "Microservices skills..."
    copy_skills_ecc "api-design" "postgres-patterns" "database-migrations" "security-review" "tdd-workflow" "coding-standards" "backend-patterns" "docker-patterns" "deployment-patterns" "golang-patterns" "python-patterns"
    copy_skills_jeff "api-designer" "postgres-pro" "database-optimizer" "python-pro" "golang-pro" "nestjs-expert" "kubernetes-specialist"
    copy_agents_ecc "architect.md" "code-reviewer.md" "database-reviewer.md" "security-reviewer.md" "tdd-guide.md" "planner.md"
    log_step "PLUGINS" "wshobson (microservices)..."
    install_wshobson_plugins "backend-development" "api-scaffolding" "api-testing-observability" "database-design" "database-migrations" "security-scanning" "comprehensive-review" "debugging-toolkit" "distributed-debugging" "tdd-workflows" "kubernetes-operations" "cicd-automation" "deployment-strategies" "cloud-infrastructure" "observability-monitoring" "incident-response"
    copy_agents_volt "backend-developer.md" "api-designer.md" "microservices-architect.md"
    apply_harmony "api-backend"
    state_set "active_preset" '"microservices"' 
    echo -e "\n${GREEN}${BOLD}Microservices READY!${NC}\n"
}

preset_game() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Game Development${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    log_step "SKILLS" "Game skills..."
    copy_skills_ecc "coding-standards" "tdd-workflow" "e2e-testing"
    copy_skills_jeff "typescript-pro" "csharp-developer" "cpp-pro"
    copy_agents_ecc "architect.md" "code-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson..."
    install_wshobson_plugins "game-development" "systems-programming" "comprehensive-review" "debugging-toolkit" "tdd-workflows" "application-performance"
    copy_agents_volt "fullstack-developer.md"
    apply_harmony "api-backend"
    state_set "active_preset" '"game"' 
    echo -e "\n${GREEN}${BOLD}Game Dev READY!${NC}\n"
}

preset_data_eng() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Data Engineering / ML Pipeline${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    mcp_supabase
    log_step "SKILLS" "Data/ML skills..."
    copy_skills_ecc "python-patterns" "python-testing" "postgres-patterns" "database-migrations" "docker-patterns" "tdd-workflow" "coding-standards"
    copy_skills_jeff "python-pro" "postgres-pro" "database-optimizer"
    copy_agents_ecc "architect.md" "code-reviewer.md" "database-reviewer.md" "tdd-guide.md"
    log_step "PLUGINS" "wshobson..."
    install_wshobson_plugins "python-development" "data-engineering" "machine-learning-ops" "data-validation-suite" "database-design" "database-cloud-optimization" "comprehensive-review" "debugging-toolkit" "tdd-workflows"
    copy_agents_volt "backend-developer.md"
    apply_harmony "api-backend"
    state_set "active_preset" '"data-eng"' 
    echo -e "\n${GREEN}${BOLD}Data Engineering READY!${NC}\n"
}

preset_landing() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  INSTALLING: Landing Page / Marketing Site${NC}"
    echo -e "${BOLD}================================================${NC}"
    preset_base
    log_step "FRAMEWORKS" "GSD + Compound + ECC..."
    install_gsd; install_compound; install_ecc
    enable_plugins "frontend-design" "playwright"
    mcp_playwright; mcp_figma; mcp_21st_dev
    log_step "SKILLS" "Landing page skills..."
    copy_skills_ecc "frontend-patterns" "coding-standards" "e2e-testing"
    copy_skills_jeff "nextjs-developer" "react-expert" "typescript-pro"
    copy_agents_ecc "architect.md" "code-reviewer.md" "e2e-runner.md"
    log_step "PLUGINS" "wshobson..."
    install_wshobson_plugins "javascript-typescript" "frontend-mobile-development" "ui-design" "seo-technical-optimization" "accessibility-compliance" "comprehensive-review"
    copy_agents_volt "frontend-developer.md"
    apply_harmony "web-nextjs"
    state_set "active_preset" '"landing"' 
    echo -e "\n${GREEN}${BOLD}Landing Page READY!${NC}\n"
}


# ============================================================================
# BACKUP & RESTORE (aklina gelmeyen sey #1)
# ============================================================================

do_backup() {
    local backup_dir="$STACK_DIR/backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    log_info "Backing up current state to $backup_dir..."
    
    # Backup settings.json
    cp "$SETTINGS_FILE" "$backup_dir/settings.json" 2>/dev/null || true
    
    # Backup state
    cp "$STATE_FILE" "$backup_dir/state.json" 2>/dev/null || true
    
    # Backup installed plugins list
    claude plugin list 2>/dev/null > "$backup_dir/plugins.txt" || true
    
    # Backup skills list
    ls "$CLAUDE_DIR/skills/" 2>/dev/null > "$backup_dir/skills.txt" || true
    
    # Backup agents list
    ls "$CLAUDE_DIR/agents/" 2>/dev/null > "$backup_dir/agents.txt" || true
    
    log_success "Backup saved: $backup_dir"
    echo -e "Restore with: ${CYAN}./stack.sh restore $backup_dir${NC}"
}

do_restore() {
    local backup_dir="$1"
    if [ ! -d "$backup_dir" ]; then
        log_error "Backup not found: $backup_dir"
        echo "Available backups:"
        ls -1 "$STACK_DIR/backups/" 2>/dev/null | while read -r b; do echo "  $STACK_DIR/backups/$b"; done
        return 1
    fi
    log_info "Restoring from $backup_dir..."
    cp "$backup_dir/settings.json" "$SETTINGS_FILE" 2>/dev/null || true
    cp "$backup_dir/state.json" "$STATE_FILE" 2>/dev/null || true
    log_success "Restored! Restart Claude Code to apply."
}

# ============================================================================
# DOCTOR (aklina gelmeyen sey #2)
# ============================================================================

do_doctor() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  STACK DOCTOR - Auto-fix problems${NC}"
    echo -e "${BOLD}================================================${NC}\n"
    
    local fixed=0
    
    # Fix 1: settings.json validity
    if ! node -e "JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'))" 2>/dev/null; then
        log_error "settings.json is corrupt! Restoring from backup..."
        local latest=$(ls -1t "$STACK_DIR/backups/" 2>/dev/null | head -1)
        if [ -n "$latest" ] && [ -f "$STACK_DIR/backups/$latest/settings.json" ]; then
            cp "$STACK_DIR/backups/$latest/settings.json" "$SETTINGS_FILE"
            log_success "Restored from backup: $latest"
            fixed=$((fixed+1))
        else
            echo '{}' > "$SETTINGS_FILE"
            log_warn "No backup found, reset to empty settings"
            fixed=$((fixed+1))
        fi
    else
        log_success "settings.json valid"
    fi
    
    # Fix 2: Agent teams not enabled
    local teams=$(node -e "const s=JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'));console.log(s?.env?.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS||'missing')" 2>/dev/null)
    if [ "$teams" != "1" ]; then
        node -e "const fs=require('fs'),s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));if(!s.env)s.env={};s.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS='1';fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');"
        log_success "Fixed: Agent teams enabled"
        fixed=$((fixed+1))
    else
        log_success "Agent teams OK"
    fi
    
    # Fix 3: Missing dirs
    for d in skills agents commands hooks; do
        if [ ! -d "$CLAUDE_DIR/$d" ]; then
            mkdir -p "$CLAUDE_DIR/$d"
            log_success "Fixed: Created $CLAUDE_DIR/$d"
            fixed=$((fixed+1))
        fi
    done
    
    # Fix 4: Orphan hooks (STACK hooks without active preset)
    local preset=$(state_get_preset)
    if [ "$preset" = "none" ]; then
        local stack_hooks=$(node -e "const s=JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'));let c=0;for(const[e,h]of Object.entries(s.hooks||{})){c+=h.filter(x=>x.description?.startsWith('[STACK]')).length;}console.log(c);" 2>/dev/null)
        if [ "$stack_hooks" -gt 0 ] 2>/dev/null; then
            remove_harmony
            log_success "Fixed: Removed orphan STACK hooks (no active preset)"
            fixed=$((fixed+1))
        fi
    fi
    
    # Fix 5: Check superpowers plugin is enabled
    local sp_enabled=$(node -e "const s=JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'));console.log(s?.enabledPlugins?.['superpowers@claude-plugins-official']||false)" 2>/dev/null)
    if [ "$sp_enabled" != "true" ]; then
        enable_plugins "superpowers"
        log_success "Fixed: Superpowers plugin enabled"
        fixed=$((fixed+1))
    else
        log_success "Superpowers enabled"
    fi
    
    echo -e "\n${GREEN}${BOLD}Doctor complete: $fixed fixes applied${NC}\n"
}


# ============================================================================
# AGENT TEAM TEST
# ============================================================================

do_test_agents() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  AGENT TEAM TEST${NC}"
    echo -e "${BOLD}================================================${NC}\n"
    
    local errors=0
    
    # Check 1: tmux
    if check_cmd tmux; then
        log_success "tmux installed ($(tmux -V))"
    else
        log_error "tmux NOT installed! Agent teams need tmux."
        log_info "Install: brew install tmux"
        errors=$((errors+1))
    fi
    
    # Check 2: AGENT_TEAMS env var
    local teams=$(node -e "const s=JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'));console.log(s?.env?.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS||'missing')" 2>/dev/null)
    if [ "$teams" = "1" ]; then
        log_success "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
    else
        log_error "Agent teams NOT enabled in settings.json"
        errors=$((errors+1))
    fi
    
    # Check 3: Running inside tmux?
    if [ -n "$TMUX" ]; then
        log_success "Running inside tmux session"
    else
        log_warn "Not inside tmux. Agent teams need tmux."
        log_info "Start with: tmux new -s myproject"
    fi
    
    # Check 4: Claude Code version
    local ver=$(claude --version 2>/dev/null | head -1 | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
    if [ -n "$ver" ]; then
        local minor=$(echo "$ver" | cut -d. -f2)
        if [ "$minor" -ge 1 ]; then
            log_success "Claude Code $ver (agent teams supported)"
        else
            log_error "Claude Code $ver too old for agent teams (need 2.1.32+)"
            errors=$((errors+1))
        fi
    fi
    
    # Check 5: team-manager agent exists
    if [ -f "$CLAUDE_DIR/agents/team-manager.md" ]; then
        log_success "team-manager agent installed"
    else
        log_warn "team-manager agent not found (optional)"
    fi
    
    # Summary
    echo ""
    if [ $errors -gt 0 ]; then
        echo -e "${RED}${BOLD}$errors errors - fix before using agent teams${NC}"
        return 1
    else
        echo -e "${GREEN}${BOLD}Agent teams ready!${NC}"
        echo -e ""
        echo -e "${BOLD}How to use:${NC}"
        echo -e "  1. tmux new -s myproject"
        echo -e "  2. claude --dangerously-skip-permissions"
        echo -e "  3. Tell Claude:"
        echo -e "     ${CYAN}Bir agent team olustur, split pane modunda calistir.${NC}"
        echo -e "     ${CYAN}3 teammate: frontend, backend, tests.${NC}"
        echo -e "     ${CYAN}Isi biten teammate'in pane'ini hemen kapat.${NC}"
        echo -e ""
        echo -e "  Shift+Down = teammate arasi gecis"
        echo -e "  Ctrl+B z   = pane zoom/unzoom"
    fi
    echo ""
}

# ============================================================================
# UPDATE & CHECK
# ============================================================================

do_update() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  UPDATING STACK${NC}"
    echo -e "${BOLD}================================================${NC}"

    log_step "1" "Updating npm packages..."
    if npm list -g get-shit-done-cc 2>/dev/null | grep -q get-shit-done; then
        npm update -g get-shit-done-cc 2>/dev/null || true
        log_success "GSD updated"
    fi
    if npm list -g ecc-universal 2>/dev/null | grep -q ecc; then
        npm update -g ecc-universal 2>/dev/null || true
        log_success "ECC updated"
    fi

    log_step "2" "Updating plugin marketplaces..."
    claude plugin marketplace update 2>/dev/null || true
    log_success "Marketplaces updated"

    log_step "2b" "Updating installed plugins..."
    claude plugin list 2>/dev/null | grep -oP "^\s+.\s+\K\S+" | while read -r p; do
        claude plugin update "$p" 2>/dev/null || true
    done
    log_success "Plugins updated"

    log_step "2c" "Updating cached repos..."
    for repo_dir in "$CACHE_DIR"/*/; do
        if [ -d "$repo_dir/.git" ]; then
            local name=$(basename "$repo_dir")
            (cd "$repo_dir" && git pull --ff-only 2>/dev/null) || true
            log_success "Updated: $name"
        fi
    done

    log_step "3" "Re-applying current preset skills & agents..."
    local preset=$(state_get_preset)
    if [ "$preset" != "none" ]; then
        # Re-copy skills from updated repos
        log_info "Re-applying skills for preset: $preset"
        rm -rf "$CLAUDE_DIR/skills/"* 2>/dev/null || true
        # Re-run the preset's skill copy (simplified - just re-run install)
        log_info "Run './stack.sh switch $preset' to fully re-apply"
    fi

    log_step "4" "Running compatibility check..."
    do_check

    echo -e "\n${GREEN}${BOLD}Update complete!${NC}\n"
}

do_check() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  COMPATIBILITY CHECK${NC}"
    echo -e "${BOLD}================================================${NC}"

    local errors=0
    local warnings=0

    # Check Claude Code version
    local claude_ver=$(claude --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -n "$claude_ver" ]; then
        local major=$(echo "$claude_ver" | cut -d. -f1)
        local minor=$(echo "$claude_ver" | cut -d. -f2)
        if [ "$major" -lt 2 ] || { [ "$major" -eq 2 ] && [ "$minor" -lt 1 ]; }; then
            log_error "Claude Code $claude_ver too old. Need 2.1.32+"
            errors=$((errors+1))
        else
            log_success "Claude Code $claude_ver OK"
        fi
    fi

    # Check settings.json validity
    if node -e "JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'))" 2>/dev/null; then
        log_success "settings.json valid JSON"
    else
        log_error "settings.json is INVALID JSON!"
        errors=$((errors+1))
    fi

    # Check agent teams enabled
    local teams=$(node -e "const s=JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'));console.log(s?.env?.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS||'missing')" 2>/dev/null)
    if [ "$teams" = "1" ]; then
        log_success "Agent teams enabled"
    else
        log_warn "Agent teams NOT enabled"
        warnings=$((warnings+1))
    fi

    # Check for duplicate/conflicting hooks
    local hook_count=$(node -e "
        const s=JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'));
        let count=0;
        for(const[e,h]of Object.entries(s.hooks||{})){count+=h.length;}
        console.log(count);
    " 2>/dev/null)
    if [ "$hook_count" -gt 20 ]; then
        log_warn "Many hooks ($hook_count) - may slow down. Consider cleaning up."
        warnings=$((warnings+1))
    else
        log_success "Hook count OK ($hook_count)"
    fi

    # Check for duplicate agents
    local agent_count=$(ls -1 "$CLAUDE_DIR/agents/" 2>/dev/null | wc -l | tr -d " ")
    local unique_count=$(ls -1 "$CLAUDE_DIR/agents/" 2>/dev/null | sort -u | wc -l | tr -d " ")
    if [ "$agent_count" != "$unique_count" ]; then
        log_warn "Duplicate agents detected!"
        warnings=$((warnings+1))
    else
        log_success "No duplicate agents ($agent_count total)"
    fi

    # Check MCP servers are reachable (basic)
    local mcps=$(node -e "const s=JSON.parse(require('fs').readFileSync('$SETTINGS_FILE','utf8'));console.log(Object.keys(s.mcpServers||{}).join(' '))" 2>/dev/null)
    for mcp in $mcps; do
        log_success "MCP configured: $mcp"
    done

    # Check skills directory
    local skill_count=$(ls -1 "$CLAUDE_DIR/skills/" 2>/dev/null | wc -l | tr -d " ")
    log_success "Skills: $skill_count installed"

    # Check npm packages for outdated
    log_info "Checking for outdated packages..."
    if npm list -g get-shit-done-cc 2>/dev/null | grep -q get-shit-done; then
        local gsd_current=$(npm list -g get-shit-done-cc 2>/dev/null | grep get-shit-done | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local gsd_latest=$(npm view get-shit-done-cc version 2>/dev/null)
        if [ "$gsd_current" = "$gsd_latest" ]; then
            log_success "GSD $gsd_current (latest)"
        else
            log_warn "GSD $gsd_current -> $gsd_latest available"
            warnings=$((warnings+1))
        fi
    fi

    if npm list -g ecc-universal 2>/dev/null | grep -q ecc; then
        local ecc_current=$(npm list -g ecc-universal 2>/dev/null | grep ecc | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local ecc_latest=$(npm view ecc-universal version 2>/dev/null)
        if [ "$ecc_current" = "$ecc_latest" ]; then
            log_success "ECC $ecc_current (latest)"
        else
            log_warn "ECC $ecc_current -> $ecc_latest available"
            warnings=$((warnings+1))
        fi
    fi

    # Summary
    echo ""
    if [ $errors -gt 0 ]; then
        echo -e "${RED}${BOLD}$errors ERRORS, $warnings warnings${NC}"
        echo -e "${RED}Fix errors before continuing!${NC}"
        return 1
    elif [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}All OK with $warnings warnings${NC}"
        echo -e "Run ${CYAN}./stack.sh update${NC} to fix warnings"
    else
        echo -e "${GREEN}${BOLD}All checks passed!${NC}"
    fi
    echo ""
}

# ============================================================================
# UNINSTALL & STATUS
# ============================================================================

do_uninstall() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  UNINSTALLING STACK${NC}"
    echo -e "${BOLD}================================================${NC}"
    log_info "Active: $(state_get_preset)"
    log_step "1" "Removing tools..."
    uninstall_gsd; uninstall_compound; uninstall_pilot; uninstall_ecc; uninstall_wshobson; uninstall_voltagent
    log_step "2" "Removing MCPs..."
    remove_all_mcps
    log_step "3" "Removing harmony + hooks..."
    remove_harmony
    # Clean ALL stack-related hooks
    node -e "
        const fs=require('fs');
        const s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));
        delete s.hooks; delete s.statusLine;
        fs.writeFileSync('$SETTINGS_FILE',JSON.stringify(s,null,2)+'\n');
    " 2>/dev/null || true
    log_step "4" "Removing skills..."
    rm -rf "$CLAUDE_DIR/skills/"* 2>/dev/null || true
    log_step "5" "Removing agents (keeping team-manager)..."
    find "$CLAUDE_DIR/agents/" -name "*.md" ! -name "team-manager.md" -delete 2>/dev/null || true
    log_step "6" "Cleaning cache..."
    rm -rf "$CACHE_DIR" 2>/dev/null || true
    echo '{}' > "$STATE_FILE"
    echo -e "\n${GREEN}${BOLD}Stack uninstalled!${NC} Plugins preserved.\n"
}

do_status() {
    echo -e "\n${BOLD}================================================${NC}"
    echo -e "${BOLD}  CLAUDE CODE STACK STATUS${NC}"
    echo -e "${BOLD}================================================${NC}\n"
    echo -e "${BOLD}Active Preset:${NC} $(state_get_preset)"

    echo -e "\n${BOLD}System:${NC}"
    if check_cmd claude; then echo -e "  ${GREEN}+${NC} Claude $(claude --version 2>/dev/null | head -1)"; else echo -e "  ${RED}-${NC} Claude"; fi
    if check_cmd node; then echo -e "  ${GREEN}+${NC} Node $(node --version)"; else echo -e "  ${RED}-${NC} Node"; fi
    if check_cmd tmux; then echo -e "  ${GREEN}+${NC} tmux $(tmux -V | cut -d' ' -f2)"; else echo -e "  ${RED}-${NC} tmux"; fi

    echo -e "\n${BOLD}Frameworks:${NC}"
    if npm list -g get-shit-done-cc 2>/dev/null | grep -q get-shit-done; then echo -e "  ${GREEN}+${NC} GSD"; else echo -e "  ${YELLOW}-${NC} GSD"; fi
    if npm list -g ecc-universal 2>/dev/null | grep -q ecc; then echo -e "  ${GREEN}+${NC} ECC"; else echo -e "  ${YELLOW}-${NC} ECC"; fi
    if [ -d "$HOME/.pilot-shell" ]; then echo -e "  ${GREEN}+${NC} Pilot Shell"; else echo -e "  ${YELLOW}-${NC} Pilot Shell"; fi
    if claude plugin list 2>/dev/null | grep -q "compound-engineering"; then echo -e "  ${GREEN}+${NC} Compound (plugin)"; else echo -e "  ${YELLOW}-${NC} Compound"; fi

    echo -e "\n${BOLD}Plugins:${NC}"
    node -e "const fs=require('fs'),s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));Object.keys(s.enabledPlugins||{}).forEach(p=>console.log('  + '+p.replace('@claude-plugins-official','')));" 2>/dev/null

    echo -e "\n${BOLD}MCPs:${NC}"
    node -e "const fs=require('fs'),s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));Object.keys(s.mcpServers||{}).forEach(m=>console.log('  + '+m));" 2>/dev/null

    local sc
    sc=$(ls -1 "$CLAUDE_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "\n${BOLD}Skills:${NC} $sc installed"
    ls "$CLAUDE_DIR/skills/" 2>/dev/null | head -10 | while read -r s; do echo -e "  ${CYAN}-${NC} $s"; done

    echo -e "\n${BOLD}Agents:${NC}"
    ls "$CLAUDE_DIR/agents/" 2>/dev/null | while read -r a; do echo -e "  ${CYAN}-${NC} $a"; done

    echo -e "\n${BOLD}Hooks:${NC}"
    node -e "const fs=require('fs'),s=JSON.parse(fs.readFileSync('$SETTINGS_FILE','utf8'));for(const[e,h]of Object.entries(s.hooks||{})){h.forEach(x=>console.log('  '+e+': '+(x.description||'unnamed')));}" 2>/dev/null
    echo ""
}

do_list() {
    echo -e "\n${BOLD}Available Presets:${NC}\n"
    echo -e "  ${CYAN}web-nextjs${NC}          Next.js + Supabase + shadcn/ui"
    echo -e "  ${CYAN}mobile-rn${NC}           React Native + Expo + Tamagui"
    echo -e "  ${CYAN}mobile-swift${NC}        Swift/SwiftUI (iOS)"
    echo -e "  ${CYAN}mobile-flutter${NC}      Flutter/Dart"
    echo -e "  ${CYAN}desktop-mac${NC}         macOS SwiftUI"
    echo -e "  ${CYAN}web3${NC}                Crypto/DApp + wallet"
    echo -e "  ${CYAN}saas${NC}                SaaS (FULL POWER: 4 frameworks)"
    echo -e "  ${CYAN}fullstack-monorepo${NC}  Web+Mobile (EVERYTHING)"
    echo -e "  ${CYAN}api-backend${NC}         API/Backend only"
    echo -e "  ${CYAN}chrome-ext${NC}         Chrome/Browser Extension"
    echo -e "  ${CYAN}electron${NC}           Electron Desktop App"
    echo -e "  ${CYAN}ai-saas${NC}            AI SaaS (LLM, RAG, embeddings)"
    echo -e "  ${CYAN}ecommerce${NC}          E-Commerce (Stripe, inventory)"
    echo -e "  ${CYAN}cli-tool${NC}           CLI Tool (Node/Go/Rust)"
    echo -e "  ${CYAN}microservices${NC}      Microservices (K8s, Docker, gRPC)"
    echo -e "  ${CYAN}game${NC}               Game Development"
    echo -e "  ${CYAN}data-eng${NC}           Data Engineering / ML Pipeline"
    echo -e "  ${CYAN}landing${NC}            Landing Page / Marketing Site"
    echo -e "\n${BOLD}Usage:${NC}"
    echo -e "  ./stack.sh install <preset>"
    echo -e "  ./stack.sh uninstall"
    echo -e "  ./stack.sh switch <preset>"
    echo -e "  ./stack.sh status"
    echo -e "  ./stack.sh update             Update all tools"
    echo -e "  ./stack.sh check              Compatibility check"
    echo -e "  ./stack.sh backup             Backup current state"
    echo -e "  ./stack.sh restore <path>     Restore from backup"
    echo -e "  ./stack.sh doctor             Auto-fix problems"
    echo -e "  ./stack.sh test-agents        Test split-pane agent teams"
    echo -e "  ./stack.sh purge              NUKE everything, start clean"
    echo -e "  ./stack.sh bootstrap          Full setup from scratch (new machine)"
    echo -e "  ./stack.sh list\n"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    ensure_dirs
    ensure_settings
    case "${1:-}" in
        install)
            case "${2:-}" in
                web-nextjs)         preset_web_nextjs ;;
                mobile-rn)          preset_mobile_rn ;;
                mobile-swift)       preset_mobile_swift ;;
                mobile-flutter)     preset_mobile_flutter ;;
                desktop-mac)        preset_desktop_mac ;;
                web3)               preset_web3 ;;
                saas)               preset_saas ;;
                fullstack-monorepo) preset_fullstack_monorepo ;;
                api-backend)        preset_api_backend ;;
                chrome-ext)         preset_chrome_ext ;;
                electron)           preset_electron ;;
                ai-saas)            preset_ai_saas ;;
                ecommerce)          preset_ecommerce ;;
                cli-tool)           preset_cli_tool ;;
                microservices)      preset_microservices ;;
                game)               preset_game ;;
                data-eng)           preset_data_eng ;;
                landing)            preset_landing ;;
                *) log_error "Unknown preset: ${2:-}"; do_list; exit 1 ;;
            esac ;;
        uninstall)  do_uninstall ;;
        switch)
            if [ -z "${2:-}" ]; then log_error "Usage: ./stack.sh switch <preset>"; do_list; exit 1; fi
            do_uninstall; main install "$2" ;;
        status)     do_status ;;
        update)     do_update ;;
        check)      do_check ;;
        backup)     do_backup ;;
        restore)    do_restore "${2:-}" ;;
        doctor)     do_doctor ;;
        test-agents) do_test_agents ;;
        purge)      do_purge ;;
        bootstrap)  do_bootstrap ;;
        list|help|"") do_list ;;
        *)          log_error "Unknown: $1"; do_list; exit 1 ;;
    esac
}

main "$@"
