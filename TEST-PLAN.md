# TEST PLAN - Kaldığımız Yer

## Durum: Plugin BUILD tamamlandı, TEST aşamasına geçilecek

### Repolar
- **Stack manager**: https://github.com/bdarbaz/claude-code-stack
- **Unified plugin**: https://github.com/bdarbaz/claude-stack-plugin

### Ne yapıldı
- [x] 81 dosya, 11K satır unified plugin oluşturuldu
- [x] 27 skill (5 layer), 12 agent, 4 subagent template, 6 hook, 8 rule
- [x] Multi-agent ile 3 round'da build edildi (10 paralel agent)
- [x] 3 commit: foundation → quality+agents+ship+browser → automation+readme

### Sıradaki: TEST (gelince buradan devam)

## Test 1: Plugin Kurulumu
- [ ] `claude plugin marketplace add bdarbaz/claude-stack-plugin`
- [ ] `claude plugin install claude-stack`
- [ ] Claude Code'da `/s:help` çalışıyor mu?
- [ ] 27 skill görünüyor mu? (`/s:` ile başlayan komutlar)
- [ ] 12 agent dispatch edilebiliyor mu?

## Test 2: Skill Chain (en kritik)
- [ ] `/s:new` → .planning/ + docs/ + CLAUDE.md oluşuyor mu?
- [ ] `/s:discuss` → REQUIREMENTS.md yazılıyor mu?
- [ ] `/s:brainstorm` → docs/brainstorms/ kaydediliyor mu?
- [ ] `/s:plan` → ROADMAP.md + docs/plans/ oluşuyor mu?
- [ ] `/s:build` → TDD enforced (RED→GREEN→REFACTOR)?
- [ ] `/s:review` → multi-perspective review yapıyor mu?
- [ ] `/s:verify` → evidence table sunuyor mu?
- [ ] `/s:ship` → sync+test+push+PR?
- [ ] `/s:compound` → docs/solutions/ kaydediliyor mu?

## Test 3: Hooks
- [ ] SessionStart: STATE.md yükleniyor mu?
- [ ] PostToolUse: auto lint/format çalışıyor mu?
- [ ] PreCompact: snapshot alınıyor mu?
- [ ] TDD check: test dosyası yoksa uyarı veriyor mu?

## Test 4: Rules
- [ ] Uncodixfy: AI-slop UI engelliyor mu?
- [ ] TDD: failing test olmadan kod yazdırmıyor mu?
- [ ] Verification: kanıt olmadan "bitti" dedirtmiyor mu?

## Test 5: Context Persistence
- [ ] Session kapat → aç: STATE.md korunuyor mu?
- [ ] .planning/ ve docs/ dosyaları session arası kalıcı mı?
- [ ] PreCompact snapshot yeterli context veriyor mu?

## Test 6: Agent Teams
- [ ] Split-pane teammate oluşturuluyor mu?
- [ ] Teammate'ler paralel dosya yazabiliyor mu?
- [ ] Biten teammate pane'i kapanıyor mu?

## Test 7: Uyumluluk
- [ ] Superpowers plugin ile çakışma var mı?
- [ ] GSD ile çakışma var mı? (ayrı kuruluysa)
- [ ] MCP'ler (Context7, Figma, Playwright) çalışıyor mu?

## Test 8: Install/Uninstall
- [ ] Temiz makinede kurulum çalışıyor mu?
- [ ] Uninstall temiz bırakıyor mu?
- [ ] Tekrar install sorunsuz mu?

## Sorun bulunursa
1. Sorunu logla
2. Fix et
3. Commit + push
4. Tekrar test

## Sonraki adımlar (test sonrası)
- [ ] Plugin marketplace'e publish
- [ ] stack.sh'yi bu plugin'i kuracak şekilde güncelle
- [ ] Gerçek bir proje ile end-to-end test
