# git utils

My utilities for git

```
$ git start -h

usage: git-start [options] newBranch

    Starts a new branch.

where:
    -h  show this help text
    -d  use default branch (origin master or master)
    -s  sync default branch (if using default branch)
```

```
$ git upload -h

usage: git-upload [options]

    Uploads current branch to an existing remote tracking branch. If no remote
    branch exist then a new branch is created.

where:
    -h  show this help text
    -n  try to push to new branch
    -f  force push
```

```
$ git sync -h

usage: git-sync [options]

    rebases current branch against origin/master

where:
    -h  show this help text
    -s  fetch origin/master before rebase
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
