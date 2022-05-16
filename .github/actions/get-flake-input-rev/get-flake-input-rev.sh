#!/bin/sh

getRev() {
  # Run in nix shell in order to use jq
  # shellcheck disable=SC2016
  "${NIX_EXEC_PATH:-nix}" develop "${FLAKE:-.}" --command \
    bash -c '"$1" flake metadata --json "$2" | jq -r --arg input "$3" ".locks.nodes[\$input].locked.rev"' \
      "$0" "${NIX_EXEC_PATH:-nix}" "${FLAKE:-.}" "${1?}"
}

rev=$(getRev "${FLAKE_INPUT_NAME:-nixpkgs}") || exit

if [ "$rev" = null ]; then
  echo "::error file=${FLAKE:-.}::unable to retrieve revision for flake input ${FLAKE_INPUT_NAME:-nixpkgs}"
  exit 1
fi

echo "::set-output name=rev::${rev}"
