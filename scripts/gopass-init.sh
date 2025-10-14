#!/usr/bin/env bash

# Why is there no home-manager module for this?

if [[ -e "$HOME/.local/share/gopass/stores" ]]; then
        echo "Existing gopass stores detected, these will be wiped!"
fi

if [[ -e "$HOME/.config/gopass" ]]; then
        echo "Existing gopass config detected, this will be wiped!"
fi

read -p "Starting gopass init, continue? (y/N): " answer
if [[ "$answer" != "y" ]]; then
        echo "Aborting."
        exit 1
fi

echo "Deleting old stores"
rm -rf "$HOME/.local/share/gopass"
echo "Deleting old config"
rm -rf "$HOME/.config/gopass"

echo "Cloning store from github"
gopass clone git@github.com:Gigahawk/passwords
