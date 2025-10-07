# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/cindyz/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/cindyz/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/cindyz/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/cindyz/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ZSH configurations
bindkey -e
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
# Terminal display configuration
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export PROMPT="%n:%1d$ "
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Aliases
alias vim='nvim'
alias gs='git status'
alias ll='ls -l'
bindkey -s "^f" "tmux-sessionizer\n"

# Path modifications
export PATH="/Users/cindyz/scripts:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Setup NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Source plugins
autoload -U compinit; compinit
source ~/.local/share/fzf-tab/fzf-tab.plugin.zsh

# ZSH autosuggestions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case insensitive completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}   # use colors in completion listings
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh   # Activate autosuggestions
