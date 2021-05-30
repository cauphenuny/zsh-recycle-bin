# zsh-recycle-bin

A recycle bin runned in command line

## install

- oh-my-zsh

1. clone the repo
```
git clone https://github.com/ycpedef/zsh-recycle-bin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-recycle-bin
```

2. activate the plugin in ~/.zshrc:

```
plugins=( [plugins...] zsh-recycle-bin)
```

- others

```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
```
