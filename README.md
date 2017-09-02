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
$ git sync -h
git-sync [options]

    rebases current branch against origin/master

where:
    -h  show this help text
    -s  fetch origin/master before rebase
```

```
$ git upload -h
git-upload [options]

    Uploads current branch to an existing remote tracking branch. If no remote
    branch exist then a new branch is created.

where:
    -h  show this help text
    -n  try to push to new branch
    -f  force push
```

## Setup

```
$ cp bin/git-* ~/bin
```
