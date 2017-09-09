#!/usr/bin/env bats

project=`pwd`

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

setup() {
  start_path_with "$project/bin"
  assert_equal `which git-prune-merged` "$project/bin/git-prune-merged"
  create_git_sandbox
  assert_equal `pwd` "$project/$sandboxGit"
}

@test "prune-merged help text" {
  run git-prune-merged -h
  assert_output --partial "usage: git prune-merged"
}

@test "prune-merged checks out origin/master and prunes merged branches" {
  create_remote_sandbox origin
  git push --set-upstream origin master
  git checkout -b branch-to-be-pruned -q
  run git-prune-merged
  assert_output --partial "Deleted branch branch-to-be-pruned"
  assert_not_equal `git rev-parse --abbrev-ref HEAD` "master"
  assert_equal `git rev-parse HEAD` `git rev-parse origin/master`
  assert_equal `git rev-parse HEAD` `git rev-parse master`
  run git rev-parse --verify branch-to-be-pruned
  assert_failure
}

@test "prune-merged does not prune master" {
  commit_file new-file
  create_remote_sandbox origin
  git push --set-upstream origin master
  git reset HEAD~ --hard
  git-prune-merged
  assert_not_equal `git rev-parse --abbrev-ref HEAD` "master"
  assert_equal `git rev-parse HEAD` `git rev-parse origin/master`
  assert_not_equal `git rev-parse HEAD` `git rev-parse master`
  run git rev-parse --verify master
  assert_success
}

#@test "prune-merged checks out master and pruns merged branches (no remote)" {
#  git checkout -b new-branch -q
#  run git-prune-merged
#  assert_equal `git rev-parse --abbrev-ref HEAD` "master"
#}

teardown() {
  cd "$project"
  clean_sandbox_repos
}
