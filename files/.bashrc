### ~/.bashrc

## If bash is not invoked interactively, exit
[[ $- != *i* ]] && return

## Bash won't get SIGWINCH if another process is in the foreground.
## Enable checkwinsize so that bash will check the terminal size when
## it regains control.
## http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

## Enable history appending instead of overwriting.
shopt -s histappend

## Enable switching to directory without explicit "cd"
shopt -s autocd

# Disable ctrl-s and ctrl-q.
stty -ixon

## Set PS1s according to TERM
## [anurag@manjaro ~][master]$ _
## RED brackets, YELLOW user, GREEN '@', BLUE host, PURPLE working directory, CYAN git branch, white '$'

## PS1 for terminals supporting 256 colors
PS1_256='\[$(tput bold)\]\[$(tput setaf 196)\][\[$(tput setaf 208)\]\u\[$(tput setaf 100)\]@\[$(tput setaf 25)\]\h \[$(tput setaf 206)\]\w\[$(tput setaf 196)\]]\[$(tput setaf 87)\]$(__git_ps1 "[%s]")\[$(tput setaf 15)\]\$\[$(tput sgr0)\] '

## PS1 for other terminals
PS1_not_256='\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h \[$(tput setaf 5)\]\w\[$(tput setaf 1)\]]\[$(tput setaf 6)\]$(__git_ps1 "[%s]")\[$(tput setaf 7)\]\$\[$(tput sgr0)\] '

## PS1 for no color
PS1_no_color='[\u@\h \w]$(__git_ps1 "[%s]")\$ '

# sanitize TERM
safe_term=${TERM//[^[:alnum:]]/?}

## Set colorful PS1 only on colorful terminals.
## dircolors -p uses its own built-in database.
# Check if "dircolors database" is present, if not, make one
[[ ! -f "$XDG_CONFIG_HOME"/dircolors ]] && type -P dircolors > /dev/null && \
  dircolors -p > "$XDG_CONFIG_HOME/dircolors"

# Check if TERM supports color
match_lhs="$(<"$XDG_CONFIG_HOME/dircolors")"
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

## Whether the terminal can display 256 colors
## Determines through tput the number of colors the terminal supports
## If tput is not found, it resorts to using the TERM variable for the query
([[ $(tput colors) -eq 256 ]] > /dev/null 2>&1 || [[ $TERM =~ .*256.* ]]) && \
use_256_color=true || use_256_color=false

if ${use_color} ; then
	## Enable colors for ls, etc.
    eval $(dircolors -b "$XDG_CONFIG_HOME/dircolors")

	${use_256_color} && PS1=$PS1_256 || PS1=$PS1_not_256
else
	PS1=$PS1_no_color
fi

## Only show the previous three directories in PS1(bash >= 4.0)
PROMPT_DIRTRIM=3

unset use_color use_256_color safe_term match_lhs PS1_not_256 PS1_256 PS1_no_color

## Aliases
alias ls='ls -N --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias cp="cp -iv"                         # confirm before overwriting something
alias mv="mv -v"
alias rm="rm -vI"
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='$EDITOR -w PKGBUILD'
alias more=less
alias diff='diff --color'		  		  # colorful diff
alias mkdir='mkdir -pv'
alias nvidia-settings='nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings'

## Nice functions

## archive extractor
ex() {
  if [[ -f $1 ]] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

## Weather
wttr() {
  curl "wttr.in/$@"
}

## Public IP address
myip() {
	curl "ipinfo.io/$@"
}

## Figlet copy to clipboard
figclip() {
  xclip -selection clipboard <(figlet "$@") && \
    notify-send "Figlet copied" "\"$@\""
}
