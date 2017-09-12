#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

setup() {
  create_sandbox_git_and_cd "test-git"
  start_path_with "$project/bin"
  assert_equal `which git-upload` "$project/bin/git-upload"
}

@test "upload help text" {
  run git-upload -h
  assert_output --partial "usage: git upload"
}

@test "upload new branch" {
  git config user.email userEmail@email.com
  create_sandbox_remote origin
  git checkout -b new-branch
  git-upload
  assert_equal `git rev-parse new-branch` `git rev-parse origin/userEmail/new-branch`
  assert_equal `git config --get branch.new-branch.remote` "origin"
  assert_equal `git config --get branch.new-branch.merge` "refs/heads/userEmail/new-branch"
}

@test "upload to existing tracking branch" {
  create_sandbox_remote origin
  git checkout -b new-branch
  git push -u origin new-branch:existing-tracking-branch
  commit_file "newFile"
  git-upload
  assert_equal `git rev-parse new-branch` `git rev-parse origin/existing-tracking-branch`
  assert_equal `git config --get branch.new-branch.remote` "origin"
  assert_equal `git config --get branch.new-branch.merge` "refs/heads/existing-tracking-branch"
}

@test "upload to new branch despite existing tracking branch" {
  git config user.email userEmail@email.com
  create_sandbox_remote origin
  git checkout -b new-branch
  git push -u origin new-branch:existing-tracking-branch
  commit_file "newFile"
  git-upload -n
  assert_equal `git rev-parse new-branch` `git rev-parse origin/userEmail/new-branch`
  assert_equal `git config --get branch.new-branch.remote` "origin"
  assert_equal `git config --get branch.new-branch.merge` "refs/heads/userEmail/new-branch"
}

@test "upload cannot change remote history without force" {
  git config user.email userEmail@email.com
  create_sandbox_remote origin
  git checkout -b new-branch
  commit_file "oldFile"
  oldRev=`git rev-parse HEAD`
  git-upload
  git reset HEAD~ --hard
  commit_file "newFile"
  run git-upload ; assert_failure
  assert_equal $oldRev `git rev-parse origin/userEmail/new-branch`
  git upload -f
  assert_equal `git rev-parse new-branch` `git rev-parse origin/userEmail/new-branch`
}

teardown() {
  remove_sandbox_and_cd
}
