#!/bin/sh

set -e
# do not quote GIT_PULL_ARGS or GIT_*_ARGS. As they may contain
# more than one argument.

# set user credentials in git config
config_git() {
    # store original user config for reset later
    ORIG_USER=$(git config --global --get --default="null" user.name)
    ORIG_EMAIL=$(git config --global --get --default="null" user.email)
    ORIG_PULL_CONFIG=$(git config --global --get --default="null" pull.rebase)

    if [ "${INPUT_GIT_USER}" != "null" ]; then
        git config --global user.name "${INPUT_GIT_USER}"
    fi

    if [ "${INPUT_GIT_EMAIL}" != "null" ]; then
        git config --global user.email "${INPUT_GIT_EMAIL}"
    fi

    if [ "${INPUT_GIT_PULL_REBASE_CONFIG}" != "null" ]; then
        git config --global pull.rebase "${INPUT_GIT_PULL_REBASE_CONFIG}"
    fi

    echo 'Git user and email credentials set for action' 1>&1
}

# reset user credentials to originals
reset_git() {
    if [ "${ORIG_USER}" = "null" ]; then
        git config --global --unset user.name
    else
        git config --global user.name "${ORIG_USER}"
    fi

    if [ "${ORIG_EMAIL}" = "null" ]; then
        git config --global --unset user.email
    else
        git config --global user.email "${ORIG_EMAIL}"
    fi

    if [ "${ORIG_PULL_CONFIG}" = "null" ]; then
        git config --global --unset pull.rebase
    else
        git config --global pull.rebase "${ORIG_PULL_CONFIG}"
    fi

    echo 'Git user name and email credentials reset to original state' 1>&1
    echo 'Git pull config reset to original state' 1>&1
}

### functions above ###
### --------------- ###
### script below    ###

# set user credentials in git config
config_git
git config --global push.default current

git fetch --prune --unshallow

git pull --no-edit origin main
git push

# echo 'Fetching origin...'
# git fetch --prune --unshallow

# echo 'Tracking all relevant branches...'
# for remote in $(git branch -r); do
#     if [ "$remote" != 'origin/main' ]; then
#         git branch --track ${remote#origin/} $remote
#     fi
# done

# for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
#     echo $branch

#     case "$branch" in
#         *\/*) 
#             echo "Branch has a forward slash in it, ignoring..."
#             ;;
#         *)
#             echo 'Attempting to pull non-destructive changes from main to '
#             echo -ne "$branch"
#             git checkout $branch
#             git pull --no-edit origin main
#             echo $?
#             if [ $? -eq 0 ]; then
#                 git push origin $branch
#             else
#                 git merge --abort
#             fi
#             ;;
#     esac
# done

# echo 'Checking out main before finishing...'
# git checkout -f main

# reset user credentials for future actions
reset_git
