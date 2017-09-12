#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

setup() {
  create_sandbox_git_and_cd "test-git"
  start_path_with "$project/bin"
  assert_equal `which git-sync` "$project/bin/git-sync"
}

@test "sync help text" {
  run git-sync -h
  assert_output --partial "usage: git sync"
}

teardown() {
  remove_sandbox_and_cd
}
