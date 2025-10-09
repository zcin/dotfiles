# Source local zshrc if it exists
[[ -r "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"

# Conda
CONDA_PATH=($HOME/miniconda3/bin/conda $HOME/miniforge3/bin/conda /usr/local/conda/bin/conda)
conda() {
    echo "Lazy loading conda upon first invocation..."
    unfunction conda
    for conda_path in "${CONDA_PATH[@]}"; do
        if [[ -f $conda_path ]]; then
            echo "Using Conda installation found in $conda_path"
            eval "$($conda_path shell.zsh hook)"
            conda "$@"
            return
        fi
    done
    echo "No conda installation found in ${CONDA_PATH[*]}"
}
ce() {
    conda activate $(conda info --envs | fzf | awk '{print $1}')
}

# Prompt configuration (sindresorhus/pure)
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

# ZSH configurations
bindkey -e  # emacs style command line
setopt appendhistory
setopt share_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
export CLICOLOR=1

# Aliases
alias vim='nvim'
alias gs='git status'
alias ga='git add .'
alias gb='git branch'
alias ll='ls -lha --color=auto'
alias k='kubectl'
alias t='tmux a'

# Keyboard shortcuts
export PATH="$HOME/scripts:$PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Setup NVM (lazy loaded)
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash completion
  nvm "$@"
}

# ZSH completions
fpath+=~/.zfunc;
autoload -Uz compinit
compinit -u
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case insensitive completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}   # use colors in completion listings
zstyle ':completion:*' menu select

# Source local zshrc if it exists
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
