
# Test setup based on https://github.com/paulirish/git-open/blob/master/test/git-open.bats
sandboxGit="test-repo"
sandboxRemote="test-remote"

# helper to create a test git sandbox that won't dirty the real repo, and cd into it
function create_git_sandbox() {
  rm -rf "$sandboxGit"
  mkdir "$sandboxGit"
  cd "$sandboxGit"
  # safety check. Don't muck with the git repo if we're not inside the sandbox.
  assert_equal $(basename $PWD) "$sandboxGit"

  git init -q
  assert [ -e "../$sandboxGit/.git" ]
  git config user.email "test@runner.com" && git config user.name "Test Runner"

  git checkout -B "master"

  echo "ok" > readme.txt
  git add readme.txt
  git commit -m "add file" -q
}

function create_remote_sandbox() {
  assert [ ! -z "$1" ]
  rm -rf "$sandboxRemote"
  mkdir "$sandboxRemote"
  git init --bare "$sandboxRemote" -q
  assert [ -e "$sandboxRemote/HEAD" ]
  git remote add $1 $sandboxRemote
  assert_equal `git config --get remote.$1.url` $sandboxRemote
}

function commit_file() {
    assert [ ! -z "$1" ]
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
