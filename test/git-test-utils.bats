#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

start_dir=`pwd`

setup() {
  assert_equal `pwd` $start_dir
  assert [ ! -e "$sandbox" ]
}

@test "project dir" {
  assert_equal $project $start_dir
}

@test "create sandbox" {
  create_sandbox_and_cd
  assert_equal `pwd` $sandbox
  assert_not_equal $sandbox $start_dir
  assert_start_with $sandbox $start_dir
}

@test "remove sandbox" {
  create_sandbox_and_cd
  remove_sandbox_and_cd
  assert_equal `pwd` $start_dir
  assert [ ! -e "$sandbox" ]
}

@test "create sandbox git" {
  run create_sandbox_git_and_cd ; assert_failure
  create_sandbox_git_and_cd new-git
  assert_equal `pwd` "$sandbox/new-git"
  assert_equal `git rev-parse --show-toplevel` `pwd`
  assert_equal `git symbolic-ref -q --short HEAD` "master"
  assert_equal `git rev-list --count master` 1
  assert_equal `git log -1 --pretty=%B` "first-commit"

  create_sandbox_git_and_cd second-git
  assert_equal `pwd` "$sandbox/second-git"
}

@test "commit file" {
  run commit_file ; assert_failure
  run commit_file "failing-commit-file" ; assert_failure

  create_sandbox_git_and_cd "test-git"
  assert_equal `pwd` "$sandbox/test-git"
  assert_equal `git rev-parse --show-toplevel` `pwd`

  run commit_file ; assert_failure
  commit_file "new-file"
  assert_equal `git log -1 --pretty=%B` "new-file"
}

@test "create sandbox remote" {
  run create_sandbox_remote ; assert_failure

  test_remote="test-remote"
  create_sandbox_remote "$test_remote"
  assert [ -e "$sandbox/$test_remote/HEAD" ]
  assert [ -z `git config --get remote.$test_remote.url` ]

  create_sandbox_git_and_cd "test-git"
  assert_equal `pwd` "$sandbox/test-git"
  assert_equal `git rev-parse --show-toplevel` `pwd`

  commit_file "test-file"
  assert_equal `git log -1 --pretty=%B` "test-file"
  git remote add "$test_remote" "$sandbox/$test_remote"
  git push -u "$test_remote" master

  create_sandbox_git_and_cd "second-test-git"
  assert_equal `pwd` "$sandbox/second-test-git"
  assert_equal `git rev-parse --show-toplevel` `pwd`
  git remote add "$test_remote" "$sandbox/$test_remote"
  git fetch "$test_remote"
  git checkout "$test_remote/master"
  assert_equal `git log -1 --pretty=%B` "test-file"
}

@test "created sandbox remote is not added to project git" {
  test_remote="test-remote"
  create_sandbox_remote "$test_remote"
  assert [ -z `git config --get remote.$test_remote.url` ]
}

@test "created sandbox remote is added to current sandbox git" {
  create_sandbox_git_and_cd "test-git"
  assert_equal `pwd` "$sandbox/test-git"
  assert_equal `git rev-parse --show-toplevel` `pwd`

  test_remote="test-remote"
  create_sandbox_remote "$test_remote"
  assert_equal `git config --get remote.$test_remote.url` "$sandbox/$test_remote"
}

@test "create sandbox clone" {
  test_remote="test-remote"
  run create_sandbox_clone_and_cd ; assert_failure
  run create_sandbox_clone_and_cd $test_remote ; assert_failure
  run create_sandbox_clone_and_cd $test_remote "failing-clone" ; assert_failure

  create_sandbox_git_and_cd "base-git"
  head=`git rev-parse HEAD`
  create_sandbox_remote $test_remote
  git push $test_remote master
  run create_sandbox_clone_and_cd ; assert_failure
  run create_sandbox_clone_and_cd $test_remote ; assert_failure

  test_clone="test-clone"
  create_sandbox_clone_and_cd $test_remote $test_clone
  assert_equal `pwd` "$sandbox/$test_clone"
  assert_equal `git rev-parse --show-toplevel` `pwd`
  assert_equal `git config --get remote.origin.url` "$sandbox/$test_remote"
  assert_equal `git rev-parse HEAD` $head
  assert_equal `git symbolic-ref -q --short HEAD` "master"
}

@test "start path with" {
  original=$PATH
  path="$sandbox/bin"
  run assert_start_with $PATH $path ; assert_failure
  start_path_with $path
  assert_equal $PATH "$path:$original"
}

teardown() {
  cd $start_dir
  rm -rf "$sandbox"
}
