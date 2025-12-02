{
  nixpkgs,
  self,
  system,
}: let
  inherit
    (self.packages.${system})
    nixos-generate
    ;

  pkgs = nixpkgs.legacyPackages.${system};
in
  pkgs.runCommand "test-format-search-path" {} ''
    rc=$?

    fail() {
      rc="$?"

      if (( "$#" > 0 )); then
        printf 1>&2 -- "$@"
      else
        printf 1>&2 -- 'unknown error\n'
      fi
    }

    run() {
      ${nixos-generate}/bin/nixos-generate "$@"
    }

    showFormatSearchPath() {
      run --show-format-search-path "$@"
    }

    list() {
      run --list "$@"
    }

    fixtures="${self}/checks/fixtures/formats"
    builtin="${nixos-generate}/share/nixos-generator/formats"

    path="$(showFormatSearchPath)" || fail 'error running nixos-generate\n'

    expected="$builtin"

    [[ "$path" == "$expected" ]] \
      || fail 'expected format search path to contain:\n%s\ngot:\n%s\n' "$expected" "$path"

    export NIXOS_GENERATORS_FORMAT_SEARCH_PATH="''${fixtures}/c:''${fixtures}/d"

    path="$(showFormatSearchPath --format-search-path "''${fixtures}/b" --format-search-path "''${fixtures}/a")" \
      || fail 'error running nixos-generate\n'

    expected="\
    ''${fixtures}/a
    ''${fixtures}/b
    ''${fixtures}/c
    ''${fixtures}/d
    $builtin"

    [[ "$path" == "$expected" ]] \
      || fail 'expected format search path to contain:\n%s\ngot:\n%s\n' "$expected" "$path"

    declare -A formats
    while read -r format; do
      formats["$format"]=1
    done < <(list --format-search-path "''${fixtures}/b" --format-search-path "''${fixtures}/a")

    for format in foo bar baz quux; do
      [[ -n "''${formats["$format"]:-}" ]] \
        || fail 'expected formats to include %s\n' "$format"
    done

    if (( rc == 0 )); then
      touch "$out"
    fi

    exit "$rc"
  ''
