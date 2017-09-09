
# Assert that values are not equal.
# Fail and display details if the expected and actual values do
# equal. Details include both values.
#
# Globals:
#   none
# Arguments:
#   $1 - actual value
#   $2 - unexpected value
# Returns:
#   0 - values do not equal
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_not_equal() {
  if [[ $1 == "$2" ]]; then
    batslib_print_kv_single_or_multi 8 \
        'expected not' "$2" \
        'actual      ' "$1" \
      | batslib_decorate 'values do not equal' \
      | fail
  fi
}
