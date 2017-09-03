# git utils

My utilities for git

```
$ git start -h
usage: git start [options] <branch>

Starts a new branch.

Available options are
    -d, --default-branch  start from default branch (origin master or master)
    -s, --sync            sync default branch (if using default branch) before start
```

```
$ git upload -h
usage: git upload [options]

Uploads current branch to an existing remote tracking branch.

If no remote branch exist then a new branch is created.

Available options are
    -n, --new-branch      push to new branch even if tracking branch already exists
    -f, --force           force push
```

```
$ git sync -h
usage: git sync [options]

rebases current branch against origin/master

Available options are
    -s, --sync            fetch origin/master from origin before rebase
```

```
$ git prune-merged -h

usage: git-prune-merged [options]

    check out origin/master, delete all merged branches and
    prunes origin

where:
    -h  show this help text
    -s  sync origin/master
```

## Setup

```
$ cp bin/git-* ~/bin
```
