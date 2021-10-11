#!/bin/bash

set -euf

if ! [ -f "$PWD/.tvirus_jitb1NGl" ]
then
    echo "You must run this from the root of the repo."
    exit 1
fi

firmware="$PWD/images"
temp="$PWD/temp"
mkdir -p "$temp"
trap 'rm -r "${temp:?}"' EXIT

if [ -z "${_treble_download_dest:-}" ]
then
    echo "Welcome to T-Virus downloader!"
    select opt in "Convert" "Revert"; do
        case $opt in
            "Convert")
                dest="treble"
                break
                ;;
            "Revert")
                dest="stock"
                break
                ;;
            *)
                echo "Your input should be one of the numbers in the list!"
        esac
    done
else
	dest="$_treble_download_dest"
fi

function already_exists() {
    if [ -d "$firmware/$1" ]
    then
        while true
        do
            read -r -p "Images for $1"$' already exist.\nDo you want to start over? [y/n]: ' yn
            case $yn in
                [Yy]*) return 0 ;;
                [Nn]*) return 1 ;;
            esac
            echo
        done
    else
        return 0
    fi

    return 1
}

echo
mkdir -p "$firmware"
for image in "common" "$dest"
do
    echo "Downloading $image..."
    if already_exists "$image"
    then
        wget --no-verbose --show-progress -O "$temp/$image.zip" "https://github.com/resident-nokia/t-virus/releases/download/tvirus-images_2021-10-08/$image.zip"
        mkdir -p "$firmware/$image"
        unzip "$temp/$image.zip" -d "$firmware/$image"
        echo "Download for $image is completed."
    else
        echo "Download for $image is skipped."
    fi
    echo
done
