#!/usr/bin/env bash
PATH=~/.cargo/bin:~/.local/tdrop/bin:~/.local/tmux/bin:$PATH
[ -n "$*" ] && TERM_EXEC=$* || TERM_EXEC=alacritty

tdrop -h 100% -tms 0 $TERM_EXEC
