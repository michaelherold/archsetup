#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
alias gpr="git --no-pager lg HEAD --not $1"
alias rmig="rake db:migrate && rake db:migrate RAILS_ENV=test"
alias rroll="rake db:rollback && rake db:rollback RAILS_ENV=test"
alias tml="tmux list-sessions"
alias tma="tmux -2 attach -t $1"
alias tmk="tmux kill-session -t $1"

svim() { sudo vim -u /home/herold/.vimrc @$ };

if [[ "$TERM" == "xterm" ]]; then
    export TERM=xterm-256color
fi

# Turn off Ansible cowspeak
export ANSIBLE_NOCOWS=1

# Homeshick
if [ -d "$HOME/.homesick/repos/homeshick/" ]; then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fi

# rbenv
RBENVPATH=$HOME/.rbenv
if [ -d "$RBENVPATH" ]; then
  PATH="$RBENVPATH/bin:$PATH"
  eval "$(rbenv init -)"
fi

# pyenv
PYENVPATH=$HOME/.pyenv
if [ -d "$PYENVPATH" ]; then
  PATH="$PYENVPATH/bin:$PATH"
  eval "$(pyenv init -)"
fi

PATH="$HOME/bin:$PATH"
