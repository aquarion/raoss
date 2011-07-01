#!/bin/bash

. /etc/bash_completion

git_dirty_flag() {
  git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) printf "%s", "!"}'
}

#parse_git_branch
__git_ps1
git_dirty_flag
echo -n " "
