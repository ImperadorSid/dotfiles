#!/usr/bin/env fish

function repo
  switch $argv[1]
    case i install
      repo_install
    case s sync
      repo_sync
    case a archive
      repo_archive
    case r remote
      repo_remote
    case n non-default
      repo_nondefault
  end
end

function repo_install
  echo Installing...
end

function repo_sync
  echo Syncing...
end

function repo_archive
  echo Archiving...
end

function repo_remote
  echo Syncing remote...
end

function repo_nondefault
  echo Installing on...
end

