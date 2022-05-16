#!/bin/sh

listFormats() {
  # Run in nix shell in order to use jq
  # shellcheck disable=SC2016
  "${NIX_EXEC_PATH:-nix}" develop "${FLAKE:-.}" --command \
    bash -c '"$1" --list | jq -cnMR "[inputs]"' \
      "$0" "${NIXOS_GENERATE_EXEC_PATH:-./nixos-generate}"
}

formats=$(listFormats) || exit
echo "::set-output name=formats::${formats}"
