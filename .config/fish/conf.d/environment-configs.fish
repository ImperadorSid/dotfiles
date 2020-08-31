#!/usr/bin/env fish

# Make
set -x MAKEFLAGS j 12

# ripgrep
set -x RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc

# TS Node
set -x TS_NODE_TRANSPILE_ONLY true

