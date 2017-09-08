#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

@test "help text" {
  run bin/git-start -h
  assert_output --partial "usage: git start"
}
