# Setup fzf
# ---------
export FZF_BASE=$HOME/.fzf
export FZF_TMUX=0

if [[ ! "$PATH" == *$FZF_BASE/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$FZF_BASE/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$FZF_BASE/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$FZF_BASE/shell/key-bindings.zsh"

# Settings
# --------
# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER="**"

# Options to fzf command
export FZF_COMPLETION_OPTS="--border"
export FZF_CTRL_R_OPTS="--sort --exact --prompt='run> '"
export FZF_CTRL_T_COMMAND="cat -n $HOME/.zsh_history | cut -b23- |tac|fzf --prompt='paste> '"
export FZF_CTRL_T_OPTS="--select-1 --exit-0"
# export FZF_ALT_C_COMMAND

export FZF_DEFAULT_COMMAND='if hash fdfind 2>/dev/null;then fdfind --type file --follow --hidden --exclude .git;else rg --files --hidden --follow;fi'
export FZF_DEFAULT_OPTS="
--preview 'if hash batcat 2>/dev/null;then batcat --color=always --style=numbers --line-range=:500 {};else cat -n {};fi'
--preview-window hidden
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--cycle
--exact
--multi
--border
--height 80%
--layout=reverse
--tiebreak=index
--pointer='>'
--marker='+'
--history=$HOME/.fzf_history
--history-size=10
--bind '?:toggle-preview'
--bind 'D:reload(if hash fdfind 2>/dev/null;then fdfind . --type directory --follow --hidden --exclude .git;else find * -type d;fi)'
--bind 'F:reload(if hash fdfind 2>/dev/null;then fdfind --type file --follow --hidden --exclude .git;else rg --files --hidden --follow;fi)'
--bind 'G:last'
--bind 'I:deselect-all'
--bind 'J:half-page-down'
--bind 'K:half-page-up'
--bind 'L:jump'
--bind 'N:preview-down'
--bind 'P:preview-up'
--bind 'V:execute(if hash batcat 2>/dev/null;then batcat {};else cat -n {};fi|fzf)'
--bind 'Y:execute(echo -n {} | xclip -selection clipboard)'
--bind 'enter:accept'
--bind 'ctrl-a:select-all'
--bind 'ctrl-c:abort'
--bind 'ctrl-e:execute(if hash nvim 2>/dev/null;then nvim {};else less {};fi)+abort'
--bind 'ctrl-l:clear-query'
--bind 'ctrl-n:next-history'
--bind 'ctrl-p:previous-history'
--bind 'ctrl-r:toggle-sort'
--bind 'ctrl-z:ignore'
"

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  if hash fdfind 2>/dev/null; then
    fdfind --hidden --follow --exclude ".git" . "$1"
  elif hash rg 2>/dev/null; then
    rg --files --follow . | grep "$1"
  else
    find * -type f | grep "$1"
  fi
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  if hash fdfind 2>/dev/null; then
    fdfind --type d --hidden --follow --exclude ".git" . "$1"
  else
    find * -type d | grep "$1"
  fi
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)               fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset)     fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)              fzf "$@" --preview 'dig {}' ;;
    *)                fzf "$@" ;;
  esac
}
