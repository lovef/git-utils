#!/usr/bin/env bats

project=`pwd`
alias git-start="$project/bin/git-start"

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

# Test setup based on https://github.com/paulirish/git-open/blob/master/test/git-open.bats
sandboxGit="test-repo"
sandboxRemote="test-remote"

setup() {
  create_git_sandbox
  assert_equal "$project/$sandboxGit" `pwd`
  export BROWSER=echo
}

@test "help text" {
  run git-start -h
  assert_output --partial "usage: git start"
}

@test "start branch" {
  git-start a
  echo "branch a" > a.txt
  git add a.txt
  git commit -m "commit a" -q
  git-start b
  assert_equal `git rev-parse b` `git rev-parse a`
  assert_not_equal `git rev-parse b` `git rev-parse master`
}

@test "start from default branch" {
  git-start a
  echo "branch a" > a.txt
  git add a.txt
  git commit -m "commit a" -q
  git-start --default-branch b
  assert_equal `git rev-parse b` `git rev-parse master`
}

@test "start from default remote branch" {
  create_remote_sandbox origin
  git push --set-upstream origin master
  echo "branch master" > master.txt
  git add master.txt
  git commit -m "commit master" -q
  git-start --default-branch b
  assert_equal `git rev-parse b` `git rev-parse origin/master`
  assert_not_equal `git rev-parse b` `git rev-parse master`
}

teardown() {
  cd "$project"
  rm -rf "$sandboxGit"
  rm -rf "$sandboxRemote"
}

# helper to create a test git sandbox that won't dirty the real repo
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
  #assert_equal "$1" "origin"
  assert [ ! -z "$1" ]
  rm -rf "$sandboxRemote"
  mkdir "$sandboxRemote"
  git init --bare "$sandboxRemote" -q
  assert [ -e "$sandboxRemote/HEAD" ]
  git remote add $1 $sandboxRemote
  assert_equal `git config --get remote.$1.url` $sandboxRemote
}


# Assert that values are not equal.
# Fail and display details if the expected and actual values do
# equal. Details include both values.
#
# Globals:
#   none
# Arguments:
#   $1 - actual value
#   $2 - unexpected value
# Returns:
#   0 - values do not equal
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_not_equal() {
  if [[ $1 == "$2" ]]; then
    batslib_print_kv_single_or_multi 8 \
        'expected not' "$2" \
        'actual      ' "$1" \
      | batslib_decorate 'values do not equal' \
      | fail
  fi
}
