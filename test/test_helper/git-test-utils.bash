
# Test setup based on https://github.com/paulirish/git-open/blob/master/test/git-open.bats
project=`pwd`
sandbox="$project/test/sandbox"
sandboxGit="test-repo"
sandboxRemote="test-remote"

function create_sandbox_and_cd() {
  sandbox='test/sandbox'
  mkdir -p $sandbox
  cd $sandbox
  sandbox=`pwd`
}

function remove_sandbox_and_cd() {
  cd "$project"
  rm -rf $sandbox
}

# helper to create a test git sandbox that won't dirty the real repo, and cd into it
function create_sandbox_git_and_cd() {
  if [ -z "$1" ] ; then
    fail "git name is required"
    exit 1
  fi
  path="$sandbox/$1"
  mkdir -p $path
  cd $path
  git init -q
  commit_file "first-commit"
}

function create_sandbox_remote() {
  if [ -z "$1" ] ; then
    fail "remote name is required"
    exit 1
  fi
  path="$sandbox/$1"
  git init --bare $path -q
  if [[ `git rev-parse --show-toplevel` == $sandbox/* ]] ; then
    git remote add "$1" "$path"
  fi
}

function create_sandbox_clone_and_cd() {
  remote="$sandbox/$1"
  if [ -z "$1" ] || [ ! -e "$remote/HEAD" ] ; then
    fail "remote name is required"
    exit 1
  fi
  if [ -z "$2" ] ; then
    fail "clone name is required"
    exit 1
  fi
  path="$sandbox/$2"
  git clone "$remote" "$path"
  cd "$path"
}

function commit_file() {
  if [ -z "$1" ] ; then
    fail "file name is required"
    exit 1
  fi
  if [[ `git rev-parse --show-toplevel` != $sandbox* ]] ; then
    fail "cannot commit in git outside sandbox"
    exit 1
  fi
  touch "$1"
  git add "$1"
  git commit -m"$1"
}

function start_path_with() {
    if [[ ! "$1" == z* ]]; then
        export PATH="$1:$PATH"
    fi
}

function clean_sandbox_repos() {
  rm -rf "$sandboxGit"
  rm -rf "$sandboxRemote"
}
