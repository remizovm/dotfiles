# This script installs my typical software for a fresh windows machine
# using the Chocolatey package manager. Read more about it at 
# https://chocolatey.org/

choco upgrade -y --no-progress googlechrome vim 7zip.install vlc git.install `
                               slack totalcommander docker-desktop dropbox `
                               telegram openvpn ccleaner geforce-experience `
                               obs-studio steam
