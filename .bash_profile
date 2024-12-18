# ~/.bash_profile
# ---------------
#
# The majority of my shell configuration is in this file. It assumes a MacOS
# computer (I don't have any others at the moment). Some of it will require
# specific executables to be installed via Homebrew. These are what I can
# remember right now:
#
# brew install neovim coreutils gnu-sed fd ripgrep tmux fzf


# Reset $PATH to avoid chaos with tmux on macOS. Note that this has to be at
# the top of this file. Otherwise it interferes with things like $PS1.
# See https://superuser.com/questions/544989 for explanation
if [ -f /etc/profile ]; then PATH=""; source /etc/profile; fi


# Determine home vs work laptop from model specifier
MAC_MODEL=$(sysctl -n hw.model)
if [[ "$MAC_MODEL" == "MacBookPro16,1" ]]; then LAPTOP="Empoleon";
elif [[ "$MAC_MODEL" == "MacBookPro18,3" ]]; then LAPTOP="ati";
else LAPTOP="unknown"   # I don't think I use anything else
fi


# Homebrew setup for work laptop (needs to be at the top because of PATH)
if [[ "$LAPTOP" == "ati" ]]; then
    # Homebrew setup for M1 Mac
    export HOMEBREW_PREFIX="/opt/homebrew";
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
    export HOMEBREW_REPOSITORY="/opt/homebrew";
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi


# Terminal prompt and colour scheme setup
# Note that this requires the TERMCS environment variable to be set to either
# "dark" or "light" to determine the terminal colour scheme. On both laptops, I
# have set this in the iTerm2 profile settings.
git_branch() { 
    git symbolic-ref HEAD --short 2>/dev/null | /usr/bin/sed -E 's/.+/ (&)/'
}
RESET='\[$(tput sgr0)\]'
# Note that the ANSI escape sequences themselves begin with \033 and end
# with m. The surrounding \[ and \] are specific to prompt variables, and
# are not needed when simply using bash's printf function (for example).
if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]; then
    if [[ "$TERMCS" == "dark" ]]; then
        # Dark mode, truecolor terminal
        PURPLE='\[\033[38;2;168;131;247m\]'
        BLUE='\[\033[38;2;114;160;252m\]'
        ORANGE='\[\033[38;2;217;147;63m\]'
        PINK='\[\033[38;2;242;114;204m\]'
        RED='\[\033[38;2;227;104;98m\]'
    else
        # Light mode, truecolor terminal
        PURPLE='\[\033[38;2;204;137;217m\]'
        BLUE='\[\033[38;2;93;173;226m\]'
        PINK='\[\033[38;2;232;121;197m\]'
        RED='\[\033[38;2;235;108;127m\]'
        ORANGE='\[\033[38;2;237;164;69m\]'
    fi
else
    # Dark or light modes, 256-colour terminal
    PURPLE='\[\033[38;5;135m\]'
    BLUE='\[\033[38;5;27m\]'
    ORANGE='\[\033[38;5;208m\]'
    PINK='\[\033[38;5;13m\]'
    RED='\[\033[38;5;203m\]'
fi
ME="pysm"
export PS1="${PURPLE}${ME}${BLUE}@${LAPTOP}:${PINK}\w${RED}\$(git_branch) ${ORANGE}\$ ${RESET}"
if [[ "$TERMCS" == "dark" ]]; then
    eval "$(gdircolors ~/.dircolors_dark)"
    export BAT_THEME="OneHalfDark"
else
    eval "$(gdircolors ~/.dircolors_light)"
    export BAT_THEME="OneHalfLight"
fi


# General
# export IGNOREEOF=1
export EDITOR=nvim
source ~/.git-completion.bash
source ~/.cabal-completion.bash
PATH="${HOME}/.local/bin:${PATH}"

# Shell utils
alias c="cd"
alias l="ls"
alias g="git"
alias n="nvim"
alias nn="nvim --"  # Useful for SvelteKit...
alias t="tmux"
alias sl="ls"
alias gti="git"
alias dc="cd"
alias http="open http://localhost:8194 && python -m http.server 8194"
alias pcra="pre-commit run -a"
if ! [ -x "$(command -v pinentry-mac)" ]; then
    alias pinentry="pinentry-mac"
fi
# ng(): grep into nvim
ng () {
    if [ -z "$1" ]; then
        error "Usage: ng <pattern>"
    else
        nvim $(rg -l "$1")
    fi
}
# nt(): tempfile with nvim
nt() {
    if [ -z "$1" ]; then
        nvim "$(gmktemp)"
    else
        nvim "$(gmktemp --suffix=."$1")"
    fi
}
# nf(): fzf into nvim
nf () {
    if ! git_top_level=$(git rev-parse --show-toplevel 2>/dev/null); then
        vfname=$(fzf)
    else
        relpath=$(git ls-files $git_top_level --full-name | fzf)
        if [ ! -z $relpath ]; then
            vfname="$git_top_level"/$relpath
        fi
    fi
    unset git_top_level
    if [ ! -z $vfname ]; then nvim $vfname; unset vfname; fi
}
alias grep='ggrep --color=auto'
alias sed='gsed'
alias ls='gls --color=auto'
colours () {
    curl -s https://gist.githubusercontent.com/penelopeysm/75605a60aebfeeb2ce14649e5361b534/raw/5e39ad3fd2ac2b8b39b2ae6c486e21de32eaf290/colours.sh | bash
}
_search_file() {
    # Search for a file
    # Usage: _search_file <file_pattern> <depth>
    local _SEARCH_DIRS=("./" "../" "../../" "../../../" "../../../../" "../../../../../")
    for dir in ${_SEARCH_DIRS[@]}; do
        # fd options described here:
        # -I   don't use .gitignore etc. (venv's are usually gitignored)
        # -H   include hidden directories (e.g. .venv)
        # -p   print full path (makes it clearer what's being sourced)
        # -dn  search up to n directories deep (don't find venvs in subdirs)
        local _FILE=$(fd -IHp -d${2} --max-results=1 "${1}$" ${dir} 2>/dev/null)
        if [ -n "${_FILE}" ]; then
            break
        fi
    done
    # Store the result here
    _SEARCH_FILE_RESULT="${_FILE}"
}
# Connect to Switch network
switch () {
    if [ -z "$1" ]; then
        echo "Usage: switch <password>"
        return 1
    fi
    networksetup -setairportnetwork en0 "switch_F24EA00100L" "$1" && open http://192.168.0.1/index.html
}

# Python
alias pip="python -m pip"
v () {
    _SEARCH_FILE_RESULT=""
    _search_file "bin/activate" 3
    if [ -z "${_SEARCH_FILE_RESULT}" ]; then
        echo "No venv found"
        return 1
    else
        printf "\033[1m\033[38;2;242;114;204mActivating:\033[0m ${_SEARCH_FILE_RESULT}\n"
        source ${_SEARCH_FILE_RESULT}
    fi
}
alias dv="deactivate"

# Haskell
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# Ruby
# TODO: Figure out what on earth is going on here ... but not a high priority
if [[ "$LAPTOP" == "Empoleon" ]]; then
    PATH=$HOME/.gem/ruby/3.0.0/bin:/usr/local/lib/ruby/gems/3.0.0/bin:/usr/local/opt/ruby/bin:$PATH
else
    PATH=/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.2.0/bin:${PATH}
fi

# OCaml
alias de='dune exec --display=quiet -- '
alias dbw='dune build --watch'
test -r "${HOME}/.opam/opam-init/init.sh" && . "${HOME}/.opam/opam-init/init.sh" > /dev/null 2> /dev/null || true

# Rust
PATH="$HOME/.cargo/bin:$PATH"
source "${HOME}/.cargo/env"

# Julia
PATH="$HOME/.juliaup/bin:$PATH"
jf() {
    if [ -z "$1" ]; then
        DIR="."
    else
        DIR="$1"
    fi
    julia -e "using JuliaFormatter; format(\"$DIR\")"
    echo Formatted.
}
jp() {
    # Thanks chatgpt
    if [[ "$1" =~ ^\+[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        julia "$1" --project=. "${@:2}"
    else
        julia --project=. "$@"
    fi
}

# Docker
PATH="$HOME/.docker/bin:$PATH"

# R
alias r='R --no-save'
alias R='R --no-save'

# Node.JS
export PNPM_HOME="${HOME}/Library/pnpm"
PATH="${PNPM_HOME}:${PATH}"

# Inkscape
# Export to same directory
alias ipng='inkscape --export-type=png -D -d 600'
alias ipdf='inkscape --export-type=pdf -D'
# Or to Desktop
ipngd () {
    for fname in "$@"; do
        if [ -f "$fname" ]; then
            inkscape --export-type=png -D -d 600 "$fname" --export-filename="$HOME/Desktop/$(basename -- ${fname%.svg}).png"
        fi
    done
}
ipdfd () {
    for fname in "$@"; do
        if [ -f "$fname" ]; then
            inkscape --export-type=pdf -D "$fname" --export-filename="$HOME/Desktop/$(basename -- ${fname%.svg}).pdf"
        fi
    done
}

# VSCode
PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"


if [[ "$LAPTOP" == "Empoleon" ]]; then
    # Handbrake proofs
    hb () {
        OLD_PWD=$(pwd)
        cd ~/Downloads
        for fname in *.MOV; do
            HandBrakeCLI -i "${fname}" -o "${fname%.MOV}.mp4" --preset-import-file "/Volumes/PorygonZ/poke_proofs/filter.json" -Z "proofs"
        done
        cd $OLD_PWD
    }
    # Default path to NMR data
    export nmrd=/Volumes/PorygonZ/dphil/expn/nmr
fi

# fzf setup (needs to come at the bottom)
export FZF_DEFAULT_COMMAND='(git status >/dev/null 2>&1 && fd --type file . $(git rev-parse --show-toplevel)) || fd -a --type file . $HOME'
export FZF_CTRL_T_COMMAND="fd --type file . ~"
export FZF_ALT_C_COMMAND="fd --type directory . ~"
eval "$(fzf --bash)"

# direnv setup (needs to come at the bottom)
eval "$(direnv hook bash)"

# export PATH
export PATH

# vim: foldmethod=marker
