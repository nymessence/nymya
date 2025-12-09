#!/bin/bash

# Set git configuration
git config user.name "Nymessence"
git config user.email "nymessence@gmail.com"

# Set up credential helper to use the GitHub token
if [ -f ~/.gh_token ]; then
    TOKEN=$(cat ~/.gh_token)
    git remote set-url origin https://${TOKEN}@github.com/nymessence/nymya.git
else
    echo "GitHub token not found at ~/.gh_token"
    exit 1
fi

git remote -v
git push origin main
