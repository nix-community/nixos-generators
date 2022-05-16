#!/bin/sh

set -x

printenv

die() {
  rc="$?"
  echo "::error file=nixos-generate::$*"
  exit "$rc"
}

generate() {
  timeout 20m \
    "${NIX_EXEC_PATH:-nix}" run . \
    -- \
    -I "nixpkgs=${NIXPKGS?}" \
    "$@"
}

getCheck() {
  "${NIX_EXEC_PATH:-nix}" eval --json "${FLAKE:-.}#checks.\"${1?}\"" --apply "(builtins.hasAttr \"${2?}\")"
}

hasCheck() {
  has_check=$(getCheck "$@") || die "failed to confirm availablity of check output"
  [ "$has_check" = true ]
}

buildCheck() {
  "${NIX_EXEC_PATH:-nix}" build "${FLAKE:-.}#checks.\"${1?}\".\"${2?}\""
}

buildAnyway() {
  [ -n "${FORCE_BUILD:-}" ]
}

checkOutputs() {
  path_var="$1"
  shift

  path="$1"
  shift

  test_type="$1"
  shift

  test "$test_type" "$path" || die "path $path does not exist or is not the expected type"
  real=$(readlink -f "$path") || die "unable to resolve path to $path"
  store_paths=$(nix-store -q --outputs "$real") || die "unable to get store path of $real"
  echo "::set-output name=${path_var}::$(echo "$store_paths" | head -n 1)"
}

format="${FORMAT?}"
system="${SYSTEM:-x86_64-linux}"
nixpkgs_name="${NIXPKGS_NAME:-nixpkgs}"
check="${format}-${nixpkgs_name}"
out_link="./result-${format}"

if hasCheck "$system" "$check"; then
  : # NOP
elif buildAnyway; then
  buildCheck() { : ; }
else
  printf 1>&2 -- "No flake check defined for format '%s' on system '%s' using nixpkgs '%s', and force-building is not enabled; exiting.\\n" \
    "$format" "$system" "$nixpkgs_name"

  exit 0
fi

out=$(generate -f "$format" --system "$system" -o "$out_link") || die "build exited with status $?"
buildCheck "$system" "$check" || die "flake build exited with status $?"
checkOutputs out "$out" -f
checkOutputs out_link "$out_link" -e
