#!/bin/bash

if ! [ -f "$PWD/.tvirus_jitb1NGl" ]
then
        echo "You must run this from the root of the repo."
        exit 1
fi

firmware="$PWD/images"
temp="$PWD/temp"
mkdir -p "$temp"
trap 'rm -r "${temp:?}"' EXIT

if [ -z "$_treble_download_dest" ]
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
	dest=$_treble_download_dest
fi

function already_exists() {
    if [ -d "$1" ]
    then
        echo
        echo "$1 already exists, want to start over?"
        select opt in "Yes" "No"; do
            case $opt in
               "Yes") return 0 ;;
               "No") return 1 ;;
                *) echo "Your input should be one of the numbers in the list!"
            esac
        done
    else
        return 0
    fi
    return 1
}

mkdir -p "$firmware"

if already_exists "$firmware/common"
then
    wget -O "$temp/common.zip" 'https://github.com/resident-nokia/t-virus/releases/download/tvirus-images_2021-10-08/common.zip'
    mkdir -p "$firmware/common"
    unzip "$temp/common.zip" -d "$firmware/common"
    echo
fi

if [ "$dest" == "treble" ]
then
    if already_exists "$firmware/treble"
    then
        wget -O "$temp/treble.zip" 'https://github.com/resident-nokia/t-virus/releases/download/tvirus-images_2021-10-08/treble.zip'
        mkdir -p "$firmware/treble"
        unzip "$temp/treble.zip" -d "$firmware/treble"
        echo
    fi
else
    if already_exists "$firmware/stock"
    then
        wget -O "$temp/stock.zip" 'https://github.com/resident-nokia/t-virus/releases/download/tvirus-images_2021-10-08/stock.zip'
        mkdir -p "$firmware/stock"
        unzip "$temp/stock.zip" -d "$firmware/stock"
        echo
    fi
fi
