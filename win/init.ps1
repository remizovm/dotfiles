# This script installs my typical software for a fresh windows machine
# using the Chocolatey package manager. Read more about it at 
# https://chocolatey.org/

choco upgrade -y --no-progress firefox neovim vlc git.install `
                               totalcommander docker-desktop dropbox `
                               telegram ccleaner geforce-experience `
                               obs-studio steam cheatengine treesizefree
