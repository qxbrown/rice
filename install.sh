#!/bin/bash
set -e

echo -e "\n=== Arch Rice Auto Installer ===\n"

# --- Check if paru exists ---
if command -v paru &>/dev/null; then
    echo "Paru detected, moving on..."
else
    echo "Paru not found. Installing paru..."

    # Install base-devel and git if needed
    sudo pacman -S --needed --noconfirm base-devel git

    # Clone paru-bin to temporary directory
    TMPDIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$TMPDIR/paru-bin"
    cd "$TMPDIR/paru-bin"
    makepkg -si --noconfirm
    cd - >/dev/null
    rm -rf "$TMPDIR"

    echo "Paru installation complete."
fi

# --- Optimize pacman.conf ---
sudo sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 15\nILoveCandy/' /etc/pacman.conf || true

# --- Install main packages via pacman ---
echo "Installing system packages via pacman..."
sudo pacman -S --noconfirm --needed \
    npm zsh pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-media-session \
    ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk ttf-font-awesome polkit-gnome mpv imv ffmpeg \
    hyprland dunst wofi swaybg grim slurp kitty pamixer brightnessctl waybar xdg-desktop-portal-hyprland \
    cliphist clang bluez bluez-utils pulseaudio-bluetooth gvfs-mtp btop qbittorrent thunar tumbler unzip \
    file-roller android-tools xdg-user-dirs ranger python-pillow firewalld neovim exa ripgrep perl-image-exiftool \
    duf fzf discord visual-studio-code-bin firefox spotify tmux pavucontrol git nodejs python go htop terraform \
    docker docker-compose docker-buildx docker-machine docker-ce \
    kubectl kubeadm kubelet minikube ansible aws-cli brave-bin

# --- Install AUR packages via paru ---
echo "Installing AUR packages via paru..."
paru -S --noconfirm --needed \
    mpd-mpris-bin ncmpcpp mpd nwg-look zoxide hyprlock wlogout tldr newsboat \
    xclip urlview bat yt-dlp alacritty anyrun-git banana-cursor-bin clipse-bin

# --- Copy .config directories ---
echo "Copying configuration files..."
mkdir -p ~/.config ~/tmux

# List of .config directories to copy
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
    cp -r "$dir" ~/.config/
done

# Copy tmux files
cp -r tmux/.tmux-cht-command ~/tmux/
cp -r tmux/.tmux-cht-languages ~/tmux/
cp -r tmux/.tmux.conf ~/
cp -r tmux/fsb.sh ~/tmux/
cp -r tmux/fshow.sh ~/tmux/

# Copy home dotfiles
cp -r .zshrc ~/

# --- Set permissions for scripts ---
chmod +x ~/.config/hypr/scripts/{linkhandler,lookup.sh,tmuxsession,tmuxcht.sh}
chmod +x ~/tmux/{fsb.sh,fshow.sh}

# --- Change default shell to Zsh ---
echo "Changing shell to Zsh..."
chsh -s /usr/bin/zsh

# --- Final message ---
echo "Installation complete."
echo "You can start Hyprland by typing: Hyprland"

read -n1 -rep 'Would you like to start Hyprland now? (y/n): ' HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    exec Hyprland
else
    echo "Exiting."
    exit 0
fi
