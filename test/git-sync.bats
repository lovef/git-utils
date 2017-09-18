#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

test_git="test-git"

setup() {
  create_sandbox_git_and_cd $test_git
  start_path_with "$project/bin"
  assert_equal `which git-sync` "$project/bin/git-sync"
}

@test "sync help text" {
  run git-sync -h
  assert_output --partial "usage: git sync"
}

@test "sync with origin/master" {
  # Start a new branch with one commit
  git checkout -b new-branch
  commit_file "newFile"

  # Update master and push to origin
  git checkout master
  commit_file "masterUpdate"
  create_sandbox_remote origin
  git push -u origin master

  # Assert that new branch is not synced with master
  git checkout new-branch
  assert_not_equal `git rev-parse new-branch~` `git rev-parse origin/master`

  # Sync
  git-sync
  assert_equal `git rev-parse new-branch~` `git rev-parse origin/master`
}

@test "sync with origin/master with --sync" {
  # Push master to origin
  oldRev=`git rev-parse master`
  create_sandbox_remote origin
  git push -u origin master

  # Update origin from a clone
  create_sandbox_clone_and_cd origin clone
  commit_file "masterUpdate"
  newRev=`git rev-parse master`
  git push origin master

  # Start a new branch
  cd "$sandbox/$test_git"
  git checkout -b new-branch
  commit_file "newFile"
  assert_equal `git rev-parse new-branch~` $oldRev

  # Sync without --sync flag
  git-sync
  assert_equal `git rev-parse new-branch~` $oldRev
  # Sync with --sync flag
  git-sync -s
  assert_equal `git rev-parse new-branch~` $newRev
}

@test "sync with target branch specified in tracking branch name" {
  create_sandbox_remote origin

  # given a new target branch
  git checkout -b target-branch
  commit_file "targetCommit"
  targetHead=`git rev-parse target-branch`
  git push -u origin target-branch

  # and new branch based on master
  git checkout -b new-branch master
  commit_file "newFile"

  # When uploading it with the specified target branch
  git-upload target-branch

  # It is first not synced
  assert_not_equal `git rev-parse new-branch~` $targetHead

  # Syncing it will automatically sync it against target branch
  git-sync
  assert_equal `git rev-parse new-branch~` $targetHead
}

@test "sync with target branch passed as parameter" {
  create_sandbox_remote origin
  git push -u origin master

  # given a new target branch
  git checkout -b target-branch
  commit_file "targetCommit"
  targetHead=`git rev-parse target-branch`
  git push -u origin target-branch

  # and new branch based on master
  git checkout -b new-branch master
  commit_file "newFile"

  # When uploading it without the specified target branch
  git push -u origin new-branch

  # It is first not synced
  assert_not_equal `git rev-parse new-branch~` $targetHead

  # Syncing it will sync it with master
  git-sync
  assert_not_equal `git rev-parse new-branch~` $targetHead

  # It can be synced with target branch passed as parameter
  git-sync target-branch
  assert_equal `git rev-parse new-branch~` $targetHead
}

teardown() {
  remove_sandbox_and_cd
}
