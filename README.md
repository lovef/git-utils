[![Build Status](https://travis-ci.org/lovef/git-utils.svg?branch=master)](https://travis-ci.org/lovef/git-utils)

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
usage: git upload [options] [<target-branch>]

Uploads current branch to an existing remote tracking branch. If no remote branch exist then a new branch is created.

Intended to push branches that should be merged into a target branch via a pull request.

Default target branch is origin/master. If the target is not origin/master then the target branch name will be included in the generated tracking branch name.

Target branch only needs to be included during the first upload.

Available options are
    -n, --new-branch      push to new branch even if tracking branch already exists
    -f, --force           force push
```

```
$ git sync -h
usage: git sync [options] [<target-branch>]

Rebases current branch against target branch, default origin/master.

Target branch can be passed as parameter or specified in target branch through git upload [<target-branch>].

Available options are
    -s, --sync            fetch target branch before rebase
```

```
$ git prune-merged -h
usage: git prune-merged [options] [<target-branch>]

check out target branch (default origin/master), delete all  merged branches and prunes origin.
    --	Target             branch can be passed as parameter or specified in target branch  through git upload [<target-branch>].

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

To use `git help` on Windows git you need to compile the docs with `./gradlew asciidoctor` and copy them from
`build/docs/html5/` to the appropriate folder. On Git for Windows it is in
`/mingw64/share/doc/git-doc/`.

`git help` with man pages is not setup at this time.

## Test

You'll need to install [bats](https://github.com/sstephenson/bats#installing-bats-from-source), the Bash automated testing system. It's also available as `brew install bats`

```sh
git submodule update --init

bats test
```

Or with npm

```sh
npm test
```

Test, travis and npm setup is heavily inspired by [git-open](https://github.com/paulirish/git-open).
