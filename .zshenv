# Make sure PATH doesn't have duplicates, zsh will keep it clean
typeset -U path

# Env vars
export VISUAL=vim
export NVM_DIR="$HOME/.nvm"
export CLICOLOR=1  # Read by MacOS only
export FZF_DEFAULT_OPTS='--no-mouse'

# PATH modifications. Note that these will get pushed back on MacOS by path_helper.
export PATH="$HOME/.local/bin:$PATH"  # uv
