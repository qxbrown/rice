#!/usr/bin/env bash
set -e

# =============================
# ArchBTW Rice Auto Installer
# =============================

GREEN='\e[1;32m'
BLUE='\e[1;34m'
RESET='\e[0m'

echo -e "\n${GREEN}=== ArchBTW Rice Auto Installer ===${RESET}\n"

# -----------------------------
# Check if paru exists
# -----------------------------
if command -v paru &>/dev/null; then
    echo -e "${GREEN}Paru detected, moving on...${RESET}"
else
    echo -e "${BLUE}Paru not found. Installing paru...${RESET}"

    sudo pacman -S --needed --noconfirm base-devel git

    TMPDIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$TMPDIR/paru-bin"
    cd "$TMPDIR/paru-bin"
    makepkg -si --noconfirm
    cd - >/dev/null
    rm -rf "$TMPDIR"

    echo -e "${GREEN}Paru installation complete.${RESET}"
fi

# -----------------------------
# Optimize pacman.conf
# -----------------------------
sudo sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 15\nILoveCandy/' /etc/pacman.conf || true

# -----------------------------
# Packages
# -----------------------------
PACMAN_PACKAGES=(
    npm zsh pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-media-session
    ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk ttf-font-awesome polkit-gnome mpv imv ffmpeg
    hyprland dunst wofi swaybg grim slurp kitty pamixer brightnessctl waybar xdg-desktop-portal-hyprland
    cliphist clang bluez bluez-utils pulseaudio-bluetooth gvfs-mtp btop qbittorrent thunar tumbler unzip
    file-roller android-tools xdg-user-dirs ranger python-pillow firewalld neovim exa ripgrep perl-image-exiftool
    duf fzf discord firefox tmux pavucontrol git nodejs python go htop terraform docker docker-compose docker-buildx
    docker-machine kubectl kubeadm kubelet minikube ansible aws-cli-v2
)

AUR_PACKAGES=(
    visual-studio-code-bin spotify brave-bin mpd-mpris-bin ncmpcpp mpd nwg-look zoxide hyprlock wlogout tldr
    newsboat xclip urlview bat yt-dlp alacritty anyrun-git banana-cursor-bin clipse-bin
)

# -----------------------------
# Install packages
# -----------------------------
echo -e "${GREEN}Installing system packages via pacman...${RESET}"
sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"

echo -e "${BLUE}Installing AUR packages via paru...${RESET}"
paru -S --noconfirm --needed "${AUR_PACKAGES[@]}"

# -----------------------------
# Copy configuration files
# -----------------------------
echo -e "${GREEN}Copying configuration files...${RESET}"

mkdir -p ~/.config ~/tmux

CONFIG_DIRS=(
    ".config/themes"
    ".config/qbittorrent"
    ".config/zathura"
    ".config/btop"
    ".config/anyrun"
    ".config/dunst"
    ".config/xfce4"
    ".config/hypr"
    ".config/alacritty"
    ".config/mpv"
    ".config/neofetch"
    ".config/ranger"
    ".config/waybar"
    ".config/wofi"
    ".config/Thunar"
    ".config/nvim"
    ".config/sioyek"
    ".config/ncmpcpp"
    ".config/mpd"
    ".config/yazi"
    ".config/bat"
    ".config/newsboat"
)

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        cp -r "$dir" ~/.config/
    fi
done

# TMUX configs
cp -r tmux/.tmux-cht-command ~/tmux/ 2>/dev/null || true
cp -r tmux/.tmux-cht-languages ~/tmux/ 2>/dev/null || true
cp -r tmux/.tmux.conf ~/
cp -r tmux/fsb.sh ~/tmux/ 2>/dev/null || true
cp -r tmux/fshow.sh ~/tmux/ 2>/dev/null || true

# Home dotfiles
cp -r .zshrc ~/

# -----------------------------
# Set script permissions
# -----------------------------
chmod +x ~/.config/hypr/scripts/{linkhandler,lookup.sh,tmuxsession,tmuxcht.sh} 2>/dev/null || true
chmod +x ~/tmux/{fsb.sh,fshow.sh} 2>/dev/null || true

# -----------------------------
# Change default shell to Zsh
# -----------------------------
echo -e "${GREEN}Changing shell to Zsh...${RESET}"
chsh -s /usr/bin/zsh || true

# -----------------------------
# Finish message
# -----------------------------
echo -e "${GREEN}Installation complete!${RESET}"
echo "You can start Hyprland by typing: Hyprland"

read -n1 -rep 'Would you like to start Hyprland now? (y/n): ' HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    exec Hyprland
else
    echo "Exiting."
    exit 0
fi
