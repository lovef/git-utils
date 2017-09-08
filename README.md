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
usage: git prune-merged [options]

check out origin/master, delete all merged branches and prunes origin.

Available options are
    -s, --sync            fetch origin/master from origin before checkout
```

## Setup

Place the git scripts from `bin` in your `PATH`, eg by creating a `bin` catalog in your home directory:

```sh
mkdir ~/bin
```
adding it to `PATH`
```sh
export PATH=~/bin:$PATH
```
and copying the scripts to it
```sh
cp bin/git-* ~/bin
```

### git help

To use `git help` you need to compile the docs with `./gradlew asciidoctor` and copy them from
`build/docs/html5/` to the appropriate folder. On Git for Windows it is in
`/mingw64/share/doc/git-doc/`.

## Test

You'll need to install [bats](https://github.com/sstephenson/bats#installing-bats-from-source), the Bash automated testing system. It's also available as `brew install bats`

```sh
git submodule update --init

bats test
```
