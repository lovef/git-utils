#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "test_helper/assert-utils"
load "test_helper/git-test-utils"

@test "all scripts under bin/ have tests" {
  cd "$project/bin"
  for file in * ; do
    assert [ -e "$project/test/$file.bats" ]
  done
}

@test "all scripts under bin/ have help texts" {
  for file in "$project/bin/*" ; do
    run $file -h
    assert_output --partial "usage: git"
  done
}
