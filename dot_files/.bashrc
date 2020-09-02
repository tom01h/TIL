export SYSTEMC=/usr/local/systemc-2.3
export RISCV=/opt/riscv

export PATH=~/bin:"$PATH":/opt/riscv/bin/
export EDITOR=vi

alias ls='ls -F --ignore={NTUSER*,ntuser*}'
alias l='ls -l'
alias emacs='/mnt/c/emacs-25.2/bin/runemacs.exe'
alias pull='env GIT_SSH_COMMAND="ssh -i /home/tom01h/.ssh/id_rsa -F /dev/null" git pull'
alias push='env GIT_SSH_COMMAND="ssh -i /home/tom01h/.ssh/id_rsa -F /dev/null" git push'
