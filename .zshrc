# ==============================
# ZSH Configuration
# ==============================

# -----------------------------
# Basic Environment
# -----------------------------
export VISUAL=nvim
export EDITOR=nvim
export BROWSER="/usr/bin/firefox"
export BAT_THEME=tokyonight_night
export MOZ_ENABLE_WAYLAND=1

# Go environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$HOME/bin:$PATH
export PATH="$HOME/.nix-profile/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/.local/share/bob/nvim-bin"

# -----------------------------
# Load Plugins
# -----------------------------
# zsh-autopair
if [[ ! -d ~/.zsh-autopair ]]; then
  git clone https://github.com/hlissner/zsh-autopair ~/.zsh-autopair
fi
source ~/.zsh-autopair/autopair.zsh

# zsh-autosuggestions
if [[ ! -d ~/.zsh/zsh-autosuggestions ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# zsh-syntax-highlighting
if [[ ! -d ~/.zsh-syntax-highlighting ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh-syntax-highlighting
fi
source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init zsh)"

# -----------------------------
# History & Options
# -----------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt autocd
unsetopt BEEP
setopt prompt_subst

# -----------------------------
# Aliases
# -----------------------------
alias in='paru -S'
alias gcl='git clone'
alias fsb='~/tmux/fsb.sh'
alias fshow='~/tmux/fshow.sh'
alias go:="gocli"
alias cat="bat --style=plain --theme tokyonight_night"
alias un='sudo pacman -Rns'
alias nb='newsboat'
alias dbl='bluetoothctl disconnect'
alias prun='pacman -Qtdq | sudo pacman -Rns -'
alias up='sudo pacman -Syu'
alias v='nvim'
alias mv='mv -i'
alias cp='cp -i'
alias gh="cliphist list | fzf | cliphist decode | wl-copy"
alias t='tmux'
alias ts='tmuxsession'
alias tks='tmux kill-session'
alias fm='thunar &'
alias cls='clear'
alias ls='eza --color=always --group-directories-first'
alias la='eza -a --color=always --group-directories-first'
alias ll='eza -l --color=always --group-directories-first'
alias :q='exit'
alias xam='sudo /opt/lampp/lampp start'
alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
alias wo="pomodoro 'work'"
alias br="pomodoro 'break'"
alias pmq='pacman -Q | fzf | wl-copy'
alias em='emacsclient -t'
alias record='wf-recorder --file=screen.mp4'

# -----------------------------
# Prompt
# -----------------------------
export PS1='%F{cyan}%n %F{magenta} %m%F{cyan} in %F{white}%F{cyan}❯%f '

# -----------------------------
# Pomodoro Timer
# -----------------------------
declare -A pomo_options=( ["work"]="45" ["break"]="10" )

work_session() {
  echo "Starting work session for ${pomo_options["work"]} minutes..."
  timer "${pomo_options["work"]}m"
  notify-send "'work' session done"
}

break_session() {
  echo "Starting break session for ${pomo_options["break"]} minutes..."
  timer "${pomo_options["break"]}m"
  notify-send "'break' session done"
}

pomodoro() {
  if [[ -n "$1" && -n "${pomo_options[$1]}" ]]; then
    case "$1" in
      "work") work_session ;;
      "break") break_session ;;
      *) echo "Invalid session type" ;;
    esac
  fi
}

# -----------------------------
# Autostart Hyprland if TTY1
# -----------------------------
if [[ "$(tty)" == "/dev/tty1" ]]; then
  exec Hyprland
fi
