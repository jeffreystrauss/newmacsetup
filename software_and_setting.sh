#!/usr/bin/env sh
 set -o errexit

# current logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# Install Developer Tools CLI
# xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Start Homebrew
echo >> /Users/$currentUser/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$currentUser/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- INSTALL UTILS --- #
brew install bash
brew install git
brew install handbrake
brew install mas
brew install --cask 1password
brew install --cask signal
brew install --cask discord
brew install --cask obsidian
brew install --cask brave-browser
brew install --cask transmission
brew install --cask iterm2
# Install iTerm utils
curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
source /Users/$currentUser/.iterm2_shell_integration.zsh
brew install --cask zoom
brew install --cask audacity
brew install --cask calibre
brew install --cask obs
brew install --cask slack
brew install --cask vlc
brew install --cask visual-studio-code
brew install --cask zotero

# The following will prompt for App Store sign-in
#Install BetterSnapTool
mas install 417375580
# Install reMarkable
mas install 1276493162
# Install Kindle
mas install 302584613
# --- END INSTALL UTILS --- #

# --- BEGIN SYSTEM TWEAKS --- #
# Show all filename extensions
echo "Show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files
echo "Show hidden files"
defaults write com.apple.Finder AppleShowAllFiles -bool true

# Enable full keyboard access for all controls
echo "Enable full keyboard access for all controls (e.g., enable Tab in modals)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use cd as default search scope in Finder
echo "Use current directory as Finder default search scope"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show a bunch of things in the menu bar
echo "Show helpful icons in the menu bar"
defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/AirPort.menu" "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" "/System/Library/CoreServices/Menu Extras/Displays.menu" "/System/Library/CoreServices/Menu Extras/Volume.menu"

# Expand save and print panel
echo "Expand the save and print panels" 
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Avoid creating .DS_Store files on network volumes"
echo "Don't create .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show status and path bars in Finder
echo "Show status and path bars in Finder"
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Disable warning when changing file extensions
echo "Don't show warnings when changing file extensions"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Always show scrollbars
echo "Always show scrollbars"
defaults write -g AppleShowScrollBars -string "Always"

# Show ~/Library
echo "Show ~/Library"
chflags nohidden ~/Library

# --- END SYSTEM TWEAKS --- #

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Get OS updates"
softwareupdate -ia

killall SystemUIServer
killall "Dock"

exit
