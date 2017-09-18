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
  git push -u origin master
  git checkout -b new-branch
  git-upload
  assert_equal `git rev-parse new-branch` `git rev-parse origin/userEmail/new-branch`
  assert_equal `git config --get branch.new-branch.remote` "origin"
  assert_equal `git config --get branch.new-branch.merge` "refs/heads/userEmail/new-branch"
}

@test "upload to existing tracking branch" {
  create_sandbox_remote origin
  git push -u origin master
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
  git push -u origin master
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
  git push -u origin master
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

@test "upload to non existing target branch" {
  git config user.email userEmail@email.com
  create_sandbox_remote origin

  # If target do not exist, upload fails
  git checkout -b new-branch
  run git-upload non-existing-target ; assert_failure
  assert_output --partial "target branch origin/non-existing-target not found"
}

@test "upload to invalid target branch" {
  git config user.email userEmail@email.com
  create_sandbox_remote origin

  # If target branch is invalid, upload fails
  git checkout -b invalid/target
  git push -u origin invalid/target
  git checkout -b new-branch
  run git-upload invalid/target ; assert_failure
  assert_output --partial "target branch origin/invalid/target is invalid"
}

@test "upload to specific target branch" {
  git config user.email userEmail@email.com
  create_sandbox_remote origin

  git checkout -b target-branch
  git push -u origin target-branch

  # upload new branch with a specific target branch
  git checkout -b new-branch
  git-upload target-branch
  assert_end_with `git config --get branch.new-branch.merge` \
      '/target=target-branch/new-branch'
}

@test "upload existing tracking branch do not match target branch" {
  git config user.email userEmail@email.com
  create_sandbox_remote origin

  git checkout -b target-branch
  git push -u origin target-branch

  # Create branch with non matching target branch
  git checkout -b new-branch
  git push -u origin new-branch

  # Uploading to specific target yields an error
  run git-upload target-branch ; assert_failure
  assert_output --partial "current tracking branch does not match target branch"

  # It can be uploaded with --new-branch
  git-upload -n target-branch
  assert_end_with `git config --get branch.new-branch.merge` \
      '/target=target-branch/new-branch'
}

teardown() {
  remove_sandbox_and_cd
}
