#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

test_git="test-git"

setup() {
  create_sandbox_git_and_cd $test_git
  start_path_with "$project/bin"
  assert_equal `which git-prune-merged` "$project/bin/git-prune-merged"
}

@test "prune-merged help text" {
  run git-prune-merged -h
  assert_output --partial "usage: git prune-merged"
}

@test "prune-merged has nothing to prune" {
  create_sandbox_remote origin
  git push --set-upstream origin master
  run git-prune-merged
  assert_success
  assert_not_equal `git rev-parse --abbrev-ref HEAD` "master"
}

@test "prune-merged checks out origin/master and prunes merged branches" {
  create_sandbox_remote origin
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
  create_sandbox_remote origin
  git push --set-upstream origin master
  git checkout -b master-reference
  git-prune-merged
  run git rev-parse --verify master
  assert_success
  run git rev-parse --verify master-reference
  assert_failure
}

@test "prune-merged with --sync" {
  create_sandbox_remote origin
  git push -u origin master
  create_sandbox_clone_and_cd origin clone
  to_be_pruned="to-be-pruned"
  git checkout -b $to_be_pruned
  commit_file "new-commit"
  updated_head=`git rev-parse HEAD`
  git push -u origin $to_be_pruned

  cd "$sandbox/$test_git"
  git fetch origin $to_be_pruned
  git merge origin/$to_be_pruned
  git push origin master
  git push --delete origin $to_be_pruned

  cd "$sandbox/clone"
  git-prune-merged
  run git rev-parse --verify $to_be_pruned ; assert_success
  assert_not_equal `git rev-parse HEAD` $updated_head
  git-prune-merged -s
  run git rev-parse --verify $to_be_pruned ; assert_failure
  assert_equal `git rev-parse HEAD` $updated_head
}

@test "prune-merged prunes origin" {
  create_sandbox_remote origin
  git push -u origin master
  create_sandbox_clone_and_cd origin clone
  to_be_pruned="to-be-pruned"
  git checkout -b $to_be_pruned
  git push -u origin $to_be_pruned

  cd "$sandbox/$test_git"
  git push --delete origin $to_be_pruned

  cd "$sandbox/clone"
  run git branch -r ; assert_output --partial "origin/$to_be_pruned"
  git-prune-merged
  run git branch -r ; refute_output --partial "origin/$to_be_pruned"
}

teardown() {
  remove_sandbox_and_cd
}
