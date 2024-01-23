#!/usr/bin/env bash

set -e

# Test if distrobox with the folder name exists
dirname=$(basename "$(pwd)")
hash=$(md5sum "distrobox.ini" | cut -d' ' -f1)

remove_if_exists() {
  if test "$(distrobox list | grep "$1")" ; then
    distrobox assemble rm
  fi
}

if test -f "distrobox.ini" ; then
  if ! test -f .hash ; then
    echo "Generating new distrobox..."

    remove_if_exists "$dirname"
    distrobox assemble create
  else
    # We found the hash.
    hash_old=$(cat .hash)
    # If hash is not the same, regenerate.
    if test "$hash_old" != "$hash" ; then
      remove_if_exists "$dirname"
      distrobox assemble create
    fi
  fi
  echo "$hash" > .hash

  # Final step, enter the distrobox
  distrobox enter "$dirname"
fi
