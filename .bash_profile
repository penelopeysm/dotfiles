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
alias gpc="gh pr checkout"
alias gcb="git checkout -b"
alias gn="git checkout -b"  # as in `git new`
alias grhh="git reset --hard HEAD"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gaa="git add -A"
alias grc="GIT_EDITOR=true git rebase --continue"
alias gra="git rebase --abort"
alias gmc="GIT_EDITOR=true git merge --continue"
alias gma="git merge --abort"
alias gcpc="GIT_EDITOR=true git cherry-pick --continue"
alias gcpa="git cherry-pick --abort"
# The ultimate git combo ...
alias gg="git add -A && git commit"
alias ggg="git add -A && git commit && git push"
gri () {
    if [ -z "$1" ]; then
        git rebase -i main
    else
        git rebase -i "HEAD~$1"
    fi
}
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
# open merge conflicts
alias nmc="ng '<<<<<<'"
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
    if [ -z "$1" ]; then
        # argument not provided; check if in a git repo
        if ! git_top_level=$(git rev-parse --show-toplevel 2>/dev/null); then
            # if not, just use fd on current directory
            vfname=$(fd --type f --absolute-path --hidden --follow --exclude .git . | fzf)
        else
            # if in a git repo, use git ls-files to list files in the repo
            relpath=$(git ls-files $git_top_level --full-name | fzf)
            if [ ! -z $relpath ]; then
                vfname="$git_top_level"/$relpath
            fi
        fi
        unset git_top_level
    else
        # argument provided, list files in that directory
        vfname=$(fd --type f --absolute-path --hidden --follow --exclude .git "$1" | fzf)
    fi
    if [ ! -z $vfname ]; then nvim $vfname; unset vfname; fi
}
alias grep='ggrep --color=auto'
alias sed='gsed'
alias ls='gls --color=auto'
colours () {
    curl -s https://gist.githubusercontent.com/penelopeysm/75605a60aebfeeb2ce14649e5361b534/raw/5e39ad3fd2ac2b8b39b2ae6c486e21de32eaf290/colours.sh | bash
}
ppt() {
    # Create a PowerPoint theme font XML file for a given font name
    [ -z "$1" ] && { echo "Usage: ppt \"<font name>\" (don't forget to quote fonts with spaces)"; return 1; }
    echo "Creating PowerPoint theme font XML for font: $1. Your admin password may be required."
    fontname_no_space=$(echo "$1" | sed 's/ /_/g')
    OLDPWD=$(pwd)
    PPTDIR='/Applications/Microsoft PowerPoint.app/Contents/Resources/Office Themes/Theme Fonts'
    cd "${PPTDIR}"
    sudo cp 'Calibri.xml' "${fontname_no_space}.xml"
    sudo sed -i '' "s/Calibri/$1/g" "${fontname_no_space}.xml"
    echo "Created ${PPTDIR}/${fontname_no_space}.xml. You can now select this font in PowerPoint under Slide Master."
    cd "$OLDPWD"
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
[ -f "$HOME/.cargo/env" ] && source "${HOME}/.cargo/env"

# Julia
PATH="$HOME/.juliaup/bin:$PATH"
jp() {
    # Thanks chatgpt
    if [[ "$1" =~ ^\+.+$ ]]; then
        julia "$1" --project=. "${@:2}"
    else
        julia --project=. "$@"
    fi
}
njr() {
    # get rid of .julia/environments temporarily
    storage=$HOME/.julia/_old_environments
    # if that folder is present, that means we stored it there
    # so we need to restore it
    if [ -d "$storage" ]; then
        rm -rf "$HOME/.julia/environments"
        mv "$storage" "$HOME/.julia/environments"
    else
        # otherwise store it
        mv "$HOME/.julia/environments" "$storage"
    fi
}
# JuliaFormatter binary ... https://github.com/domluna/JuliaFormatter.jl/issues/633#issuecomment-1518805248
export _JULIA_FORMATTER_SO=$HOME/.julia/formatter.so
jf() {
    project=${1:-$PWD}
    OLD=$PWD
    if [ -e "$_JULIA_FORMATTER_SO" ]; then
        :
    else
        echo "Could not find $_JULIA_FORMATTER_SO, so will build it..."
        _build_jformat
    fi
    cd $project
    julia --startup-file=no --threads=auto -J $_JULIA_FORMATTER_SO -O0 --compile=min -e 'using JuliaFormatter; format(".")'
    if [ $? -ne 0 ]; then
        printf "\n\nFailed to run JuliaFormatter; you may need to regenerate the sysimage. To do this, run the following command:\n\n    rm -f \"$_JULIA_FORMATTER_SO\"; _build_jformat\n"
        return 1
    fi
    cd $OLD
}
_build_jformat() {
    # Build a formatting image using an example project
    OLD=$PWD
    WORKDIR=$(mktemp -d)
    cd $WORKDIR
    git clone --depth 1 --quiet https://github.com/TuringLang/Turing.jl  # Not used; just an example project
    cd Turing.jl
    { 
        julia --startup-file=no --compile=yes -O3 --threads=auto -e 'using Pkg; Pkg.activate(; temp=true); Pkg.add("PackageCompiler"); Pkg.add(name="JuliaFormatter", version="1"); open("precompile_file.jl", "w") do io; write(io, "using JuliaFormatter; format(\".\")"); end; using PackageCompiler; create_sysimage(["JuliaFormatter"]; sysimage_path="'$_JULIA_FORMATTER_SO'", precompile_execution_file="precompile_file.jl")'
    } || {
        echo "Building format file failed. Exiting."
    }
    cd $OLD
}

# Docker
# I think the first of these is Homebrew and the other is the app downloaded from Docker website
# but not 100% sure
PATH="$HOME/.docker/bin:$PATH"
PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

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
fi

# fzf setup (needs to come at the bottom)
export FZF_DEFAULT_COMMAND='(git status >/dev/null 2>&1 && fd --type file . $(git rev-parse --show-toplevel)) || fd -a --type file .'
export FZF_CTRL_T_COMMAND="fd --type file . ~"
export FZF_ALT_C_COMMAND="fd --type directory . ~"
eval "$(fzf --bash)"

# LLVM toolchain
export PATH="/opt/homebrew/opt/llvm@20/bin:$PATH"

# export PATH
export PATH

# vim: foldmethod=marker
