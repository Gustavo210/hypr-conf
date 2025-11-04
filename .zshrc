# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -t 0 ]]; then
  stty -ixon
fi
# alias banco="sh $HOME/scripts/banco/index.sh"

# alias MS="cd $HOME/projects/aplicacoes/next/mobilereact"
# alias ML="cd $HOME/projects/aplicacoes/next/meulook"
# alias MD="cd $HOME/projects/aplicacoes/next/med-front"
# alias F="cd $HOME/projects/aplicacoes/next/frontend"
# alias A="cd $HOME/projects/aplicacoes/aplicativos"
# alias B="cd $HOME/projects/aplicacoes/backend"
# alias lp-php="{docker exec -it backend-lookpay-api-1 bash} || {notify-send 'Erro ao tentar acessar o container'}"
# alias web-php="{docker exec -it backend-adm-api-1 bash} || {notify-send 'Erro ao tentar acessar o container'}"
# alias zellij="$HOME/zellij/zellij"
# alias zt="$HOME/zellij/zellij --layout ~/.config/zellij/layout-default.kdl"
# alias T="$HOME/projects/elegram/init.sh"
# alias MD-link="$HOME/scripts/abre-link.sh"
# alias OPS="cd $HOME/projects/aplicacoes/backend/apps/adm-api/opensearch && docker-compose up"
# alias V="$HOME/scripts/virtual_env.sh"
# alias L="lazydocker"
# alias DPS="docker ps | awk 'NR>1 {print \$2}'"
# alias f="sh $HOME/scripts/fuzy.sh"
# alias HT="nohup $HOME/Documentos/release/NeoHtop > output.log 2>&1 &"

# alias AWS_ACCESS_KEY_ID="dummy"
# alias AWS_SECRET_ACCESS_KEY="dummy"

# alias ENV="cp $HOME/.ssh/.env.php $HOME/projects/aplicacoes/backend/apps/adm-api/.env.php && echo '.env.php copiado com sucesso'"

source "$HOME/scripts/exec-alias.sh"
source "$HOME/.zsh_alias"

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# if [[ ! "$PWD" =~ ^/virtual_env ]]; then
# fi
# eval "$(zellij setup --generate-auto-start zsh)"
# eval 'xbindkeys'
# source <(fzf --zsh)

export REACT_EDITOR=code
export EDITOR=vim

# export https_proxy=http://127.0.0.1:7890
# export http_proxy=http://127.0.0.1:7890
# export all_proxy=socks5://127.0.0.1:7890source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

# pnpm
export PNPM_HOME="/home/gustavo210/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
alias pnpm="corepack pnpm"
alias yarn="corepack yarn"
eval "$(~/.local/bin/mise activate zsh)"
# eval "$(~/.local/bin/mise activate zsh)"
# source ~/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# zoxide config
eval "$(zoxide init zsh)"
# Completion for pnpm
# source ~/completion-for-pnpm.zsh


# Disable pnpm exec scripts om backend
# export RUNNING_IN_DOCKER=true
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
