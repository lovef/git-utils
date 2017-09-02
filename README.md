# git utils

My utilities for git

```
$ git prune-merged -h
git-prune-merged [options]

    check out origin/master, delete all merged branches and
    prunes origin

where:
    -h  show this help text
    -s  sync origin/master
```

```
git-sync [options]

    rebases current branch against origin/master

where:
    -h  show this help text
    -s  fetch origin/master before rebase
```

## Setup

```
$ cp bin/git-* ~/bin
```
