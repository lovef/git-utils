#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

test_git="test-git"

setup() {
  create_sandbox_git_and_cd "test-git"
  start_path_with "$project/bin"
  assert_equal `which git-start` "$project/bin/git-start"
}

@test "start help text" {
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
  create_sandbox_remote origin
  git push --set-upstream origin master
  echo "branch master" > master.txt
  git add master.txt
  git commit -m "commit master" -q
  git-start --default-branch b
  assert_equal `git rev-parse b` `git rev-parse origin/master`
  assert_not_equal `git rev-parse b` `git rev-parse master`
  assert [ -z `git config branch.b.merge` ]
}

@test "start from other, local branch" {
  # Given a source branch
  git checkout -b source-branch
  commit_file "sourceCommit"
  git checkout master

  # And a remote whre the soure branch does NOT exist
  create_sandbox_remote origin

  # We can start from another branch that is not the default branch
  git-start new-branch source-branch
  commit_file "newCommit"
  assert_equal `git rev-parse new-branch~` `git rev-parse source-branch`
}

@test "start from other, remote branch" {
  # Given a source branch that only exists remote
  create_sandbox_remote origin
  git checkout -b source-branch
  commit_file "sourceCommit"
  git push -u origin source-branch
  git checkout master
  git branch -D source-branch

  # We can start from the remote source branch without specifying remote
  git-start new-branch source-branch
  commit_file "newCommit"
  assert_equal `git rev-parse new-branch~` `git rev-parse origin/source-branch`
}

@test "start from other branch when both remote and local exist" {
  # Given a source branch that exists localy and remote
  create_sandbox_remote origin
  git checkout -b source-branch
  commit_file "remoteCommit"
  git push -u origin source-branch
  commit_file "localCommit"
  git checkout master

  # We can start from the local source branch
  git-start new-branch-local source-branch
  commit_file "newCommit"
  assert_equal `git rev-parse new-branch-local~` `git rev-parse source-branch`

  # Or from the remote source branch
  git-start new-branch-remote origin/source-branch
  commit_file "newCommit"
  assert_equal `git rev-parse new-branch-remote~` `git rev-parse origin/source-branch`
}

@test "start from other branch with sync" {
  # Given a source branch that exists localy and remote
  create_sandbox_remote origin
  git checkout -b source-branch
  git push -u origin source-branch

  # And the remote is updated from a cloned repo
  create_sandbox_clone_and_cd origin clone
  git checkout source-branch
  commit_file "remoteUpdate"
  updatedRemoteHead=`git rev-parse HEAD`
  git push origin source-branch

  # When starting branch with --sync
  cd "$sandbox/$test_git"
  git start new-branch source-branch -s
  commit_file "newFile"
  assert_equal `git rev-parse new-branch~` $updatedRemoteHead
}

teardown() {
  remove_sandbox_and_cd
}
