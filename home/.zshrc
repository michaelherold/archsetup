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
export PYENV_ROOT="$HOME/.pyenv"
PATH="$HOME/.rbenv/bin:$PYENV_ROOT/bin:$HOME/bin:$PATH"

alias gpr="git --no-pager lg HEAD --not $1"
alias rmig="rake db:migrate && rake db:migrate RAILS_ENV=test"
alias rroll="rake db:rollback && rake db:rollback RAILS_ENV=test"

if [[ "$TERM" == "xterm" ]]; then
    export TERM=xterm-256color
fi

# rbenv
eval "$(rbenv init -)"

# pyenv
eval "$(pyenv init -)"
