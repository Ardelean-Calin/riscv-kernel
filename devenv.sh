#!/usr/bin/env bash

set -e

# Test if distrobox with the folder name exists
dirname=$(basename "$(pwd)")
hash=$(md5sum "distrobox.ini" | cut -d' ' -f1)

if test -f "distrobox.ini" ; then
  if ! test -f .hash ; then
    echo "Hash not found. Generating..."
    echo "$hash" > .hash

    # No hash means no container. TODO: Remove distrobox if exists.
    distrobox assemble create
  else
    # We found the hash.
    echo "Hash found."
    hash_old=$(cat .hash)
    # If hash is not the same, regenerate.
    if test "$hash_old" != "$hash" ; then
      distrobox assemble rm
      distrobox assemble create
    fi

    # Hash is the same. Test if the distrobox exists.
    if ! test "$(distrobox list | grep "$dirname")" ; then
      distrobox assemble create
    fi
  fi

  # Final step, enter the distrobox
  distrobox enter "$dirname"
fi
