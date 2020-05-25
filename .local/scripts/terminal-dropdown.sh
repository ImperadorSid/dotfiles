#!/usr/bin/env bash
PATH=~/.local/tmux/bin:~/.local/tdrop/bin:$PATH
[ -n "$*" ] && TERM_EXEC=$* || TERM_EXEC=alacritty

tdrop -h 100% -tms 0 $TERM_EXEC
