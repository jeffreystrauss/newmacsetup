#!/usr/bin/env bash
# New Mac Setup — software & system tweaks
#
# Idempotent: safe to re-run. Each step checks whether it's already done.
#
# Run interactively (so you can answer the Xcode and App Store prompts):
#     bash software_and_setting.sh
#
# Manual prerequisites: see the MANUAL STEPS section at the bottom.

set -euo pipefail

log() { printf "\n\033[1;34m==>\033[0m %s\n" "$*"; }

# --- 1. Xcode Command Line Tools ----------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (accept the GUI prompt, then wait)"
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
fi

# --- 2. Homebrew --------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_PREFIX="$(/opt/homebrew/bin/brew --prefix 2>/dev/null || /usr/local/bin/brew --prefix)"
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

# Add shellenv to .zprofile once (re-runs won't duplicate it)
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  printf '\neval "$(%s/bin/brew shellenv)"\n' "$BREW_PREFIX" >> "$HOME/.zprofile"
fi

# --- 3. Formulae + casks via brew bundle (parallel & idempotent) --------------
log "Installing formulae and casks via brew bundle"
brew bundle --file=- <<'BREWFILE'
# Taps
tap "domt4/autoupdate"

# CLI tools
brew "bash"
brew "gh"
brew "git"
brew "handbrake"
brew "mas"
brew "nmap"
brew "node"
brew "pinentry-mac"
brew "ripgrep"
brew "supabase/tap/supabase"
brew "tesseract"
brew "tor"

# GUI apps
cask "1password"
cask "audacity"
cask "brave-browser"
cask "calibre"
cask "chatgpt"
cask "claude"
cask "claude-code"
cask "discord"
cask "docker"
cask "expressvpn"
cask "iterm2"
cask "libreoffice"
cask "obs"
cask "obsidian"
cask "signal"
cask "slack"
cask "tor-browser"
cask "transmission"
cask "visual-studio-code"
cask "vlc"
cask "zoom"
cask "zotero"
BREWFILE

# --- 4. Mac App Store apps ----------------------------------------------------
# `mas` requires that you've signed in to the App Store via the GUI first.
if mas account >/dev/null 2>&1; then
  log "Installing Mac App Store apps"
  brew bundle --file=- <<'MASFILE' || true
mas "BetterSnapTool", id: 417375580
mas "Kindle",         id: 302584613
mas "reMarkable",     id: 1276493162
# Add others here once you've recorded their IDs from the old Mac via `mas list`.
# Known to be installed on the source machine but ID not captured:
#   - Scrivener 3 (com.literatureandlatte.scrivener3)
MASFILE
else
  log "Skipping App Store apps — open the App Store, sign in, then re-run this script."
fi

# --- 5. Homebrew autoupdate (every 24h) ---------------------------------------
# No --sudo: avoids a blocking password prompt. Casks needing root will be
# skipped by autoupdate; run `brew upgrade --cask` manually for those.
if ! brew autoupdate status 2>/dev/null | grep -q "is running"; then
  brew autoupdate start 86400 --upgrade --cleanup --immediate
fi

# --- 6. VS Code extensions ----------------------------------------------------
if command -v code >/dev/null 2>&1; then
  log "Installing VS Code extensions"
  for ext in \
    github.copilot-chat \
    ms-azuretools.vscode-containers \
    ms-python.debugpy \
    ms-python.python \
    ms-python.vscode-pylance \
    ms-python.vscode-python-envs \
    ms-vscode-remote.remote-containers
  do
    code --install-extension "$ext" --force >/dev/null
  done
fi

# --- 7. Global npm packages ---------------------------------------------------
if command -v npm >/dev/null 2>&1; then
  log "Installing global npm packages"
  npm install -g pnpm vercel docx
fi

# --- 8. iTerm2 shell integration ----------------------------------------------
if [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
  log "Installing iTerm2 shell integration"
  curl -fsSL https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
fi

# --- 9. oh-my-zsh -------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- 10. System defaults ------------------------------------------------------
log "Applying system defaults"

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show hidden files in Finder
defaults write com.apple.Finder AppleShowAllFiles -bool true
# Full keyboard access (Tab through modals, etc.)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Search the current folder by default in Finder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Expand save and print panels by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode  -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint     -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2    -bool true
# Don't write .DS_Store on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Show status + path bars in Finder
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar   -bool true
# Don't warn when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Always show scrollbars
defaults write -g AppleShowScrollBars -string "Always"
# Unhide ~/Library
chflags nohidden "$HOME/Library"

killall SystemUIServer >/dev/null 2>&1 || true
killall Finder         >/dev/null 2>&1 || true
killall Dock           >/dev/null 2>&1 || true

# --- 11. macOS software updates -----------------------------------------------
log "Applying macOS software updates (may prompt for sudo and require restart)"
sudo softwareupdate -ia --verbose || true

log "Done. See the MANUAL STEPS section at the bottom of this script."

# ==============================================================================
# MANUAL STEPS — not safely automatable
# ==============================================================================
# Before running:
#   1. Sign in to iCloud and the Mac App Store (otherwise section 4 is skipped).
#   2. On the OLD Mac, run `mas list` and copy any extra MAS IDs into section 4.
#
# After running:
#   3. Copy these dotfiles from the old Mac (Migration Assistant or scp):
#        ~/.zshrc  ~/.zprofile  ~/.gitconfig  ~/.ssh/
#      Then `chmod 600 ~/.ssh/config ~/.ssh/id_*` if you copied SSH keys.
#   4. Sign in to: 1Password, Brave, Slack, Discord, ChatGPT, Claude,
#      ExpressVPN, Zoom, Docker, GitHub (`gh auth login`).
#   5. Restore data that doesn't live in iCloud: Obsidian vaults, Zotero
#      library, Scrivener projects.
#   6. Push your new SSH key to GitHub:
#        gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
# ==============================================================================
