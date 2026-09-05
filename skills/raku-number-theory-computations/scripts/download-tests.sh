#!/usr/bin/env bash

set -euo pipefail

repository_archive='https://github.com/antononcube/Raku-Math-NumberTheory/archive/refs/heads/main.tar.gz'
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
skill_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
destination=${1:-"$skill_dir/assets"}

if [[ -e "$destination" && ! -d "$destination" ]]; then
    printf 'error: destination exists and is not a directory: %s\n' "$destination" >&2
    exit 1
fi

if [[ -d "$destination" && -n "$(find "$destination" -mindepth 1 -print -quit)" ]]; then
    printf 'error: destination directory is not empty: %s\n' "$destination" >&2
    exit 1
fi

mkdir -p "$destination"

download_work_dir=$(mktemp -d "${TMPDIR:-/tmp}/math-number-theory-tests.XXXXXX")
trap 'rm -rf -- "$download_work_dir"' EXIT

curl --fail --location --silent --show-error \
    --output "$download_work_dir/repository.tar.gz" \
    "$repository_archive"
tar -xzf "$download_work_dir/repository.tar.gz" -C "$download_work_dir"

test_source="$download_work_dir/Raku-Math-NumberTheory-main/t"
if [[ ! -d "$test_source" ]]; then
    printf 'error: the downloaded archive does not contain the expected t directory\n' >&2
    exit 1
fi

cp -R "$test_source/". "$destination/"
printf 'Downloaded Math::NumberTheory tests to %s\n' "$destination"
