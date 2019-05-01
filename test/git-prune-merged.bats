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

@test "prune-merged checks out original branch if it was not pruned" {
  create_sandbox_remote origin
  git push --set-upstream origin master
  git checkout -b "should-not-be-pruned"
  commit_file "new-commit"
  git-prune-merged
  assert_equal `git rev-parse --abbrev-ref HEAD` "should-not-be-pruned"
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
  git-prune-merged --sync
  run git rev-parse --verify $to_be_pruned ; assert_failure
  assert_equal `git rev-parse HEAD` $updated_head
}

@test "prune-merged with target branch specified in tracking branch name" {
  create_sandbox_remote origin
  git push -u origin master

  # given a new target branch
  git checkout -b target-branch
  commit_file "targetCommit"
  targetHead=`git rev-parse target-branch`
  git push -u origin target-branch

  # and a new, unmerged branch
  git checkout -b new-branch
  commit_file "newFile"

  # When uploading it with the specified target branch
  git-upload target-branch

  # And pruning it
  git-prune-merged

  # new-branch is not pruned as it is not merged
  run git rev-parse --verify new-branch ; assert_success

  # Once merged
  git checkout target-branch
  git merge new-branch
  git push origin target-branch

  # It can be pruned
  git checkout new-branch
  git-prune-merged
  run git rev-parse --verify new-branch ; assert_failure
}

@test "prune-merged with target branch passed as parameter" {
  create_sandbox_remote origin
  git push -u origin master

  # given a new target branch
  git checkout -b target-branch
  commit_file "targetCommit"
  targetHead=`git rev-parse target-branch`
  git push -u origin target-branch

  # and a new, unmerged branch
  git checkout -b new-branch
  commit_file "newFile"

  # When uploading it without the specified target branch
  git push -u origin new-branch

  # And pruning it with target branch passed as parameter
  git-prune-merged target-branch

  # new-branch is not pruned as it is not merged
  run git rev-parse --verify new-branch ; assert_success

  # Once merged
  git checkout target-branch
  git merge new-branch
  git push origin target-branch

  # It can not be pruned without specifying target branch
  git checkout new-branch
  git-prune-merged
  run git rev-parse --verify new-branch ; assert_success

  # It can be pruned when specifying target branch
  git-prune-merged target-branch
  run git rev-parse --verify new-branch ; assert_failure
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

@test "prune branches that have been rebased on remote" {
  # Given a remote
  create_sandbox_remote origin
  git push -u origin master

  # With two branches
  create_sandbox_clone_and_cd origin clone
  git checkout -b branch-a
  commit_file "newFileA"
  git push -u origin branch-a
  git checkout -b branch-b
  commit_file "newFileB"
  git push -u origin branch-b

  # That is rebased against master on remote
  cd "$sandbox/$test_git"
  git fetch origin branch-a
  git rebase origin/branch-a
  git fetch origin branch-b
  git rebase origin/branch-b
  git push origin --delete branch-a
  git push origin --delete branch-b
  git push origin master

  # And synced
  cd "$sandbox/clone"
  git fetch origin master
  git checkout branch-a
  git rebase origin/master
  git checkout branch-b
  git rebase origin/master

  # Can be pruned
  git-prune-merged
  run git rev-parse --verify branch-a ; assert_failure
  run git rev-parse --verify branch-b ; assert_failure
}

teardown() {
  remove_sandbox_and_cd
}
