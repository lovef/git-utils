#!/usr/bin/env bats

project=`pwd`
function git-start() {
   "$project/bin/git-start" $@
}

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

setup() {
  create_git_sandbox
  assert_equal "$project/$sandboxGit" `pwd`
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
  assert [ -z `git config branch.b.merge` ]
}

teardown() {
  cd "$project"
  clean_sandbox_repos
}
