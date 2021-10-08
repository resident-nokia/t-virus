#!/bin/bash

if ! [ -f "$PWD/.tvirus_jitb1NGl" ]
then
	echo "You must run this from the root of the repo."
	exit 1
fi

fastboot="$PWD/tools/linux/fastboot"
dumper="$PWD/tools/linux/payload-dumper-go"
firmware="$PWD/images"

echo "Welcome to T-Virus!"

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

function flash_ab() {
    if ! "$fastboot" flash "$1_a" "$2"; then echo "Flash $1_a error"; exit 1; fi

    if ! "$fastboot" flash "$1_b" "$2"; then echo "Flash $1_b error"; exit 1; fi
}

function flash() {
    if ! "$fastboot" flash "$1" "$2"; then echo "Flash $1 error"; exit 1; fi
}

function flash_raw_ab() {
    if ! "$fastboot" flash:raw "$1_a" "$2"; then echo "Flash $1_a error"; exit 1; fi

    if ! "$fastboot" flash:raw "$1_b" "$2"; then echo "Flash $1_b error"; exit 1; fi
}

function erase() {
    if ! "$fastboot" erase "$1"; then echo "${2:-"Erase $1 error"}"; exit 1; fi
}

function erase_ab() {
    if ! "$fastboot" erase "$1_a"; then echo "Erase $1_a error"; exit 1; fi

    if ! "$fastboot" erase "$1_b"; then echo "Erase $1_b error"; exit 1; fi
}

function check_if_dir_exists() {
	if ! [ -d "$firmware/$1" ]
	then
		echo
		echo "You need to download the firmware first."
		echo "Would you like to download the firmware?"


		select opt in "Yes" "No"; do
			case $opt in
			"Yes") _treble_download_dest=$dest "$PWD/download.sh"; break; ;;
			"No") exit 1 ;;
			*) echo "Your input should be one of the numbers in the list!"
			esac
		done
	fi
}

echo "Repartitioning device..."
erase misc "ERROR: Failed to modify partition table, please unlock the bootloader of your device!"


check_if_dir_exists "$dest"
if ! "$fastboot" "${@}" flash partition:0 "$firmware/$dest/gpt_both0.bin"; then
     echo "Flash main partition table error"

     exit 1
fi

check_if_dir_exists "common"
flash_ab abl "$firmware/common/abl.img"
flash_ab xbl "$firmware/common/xbl.img"

echo "Repartitioning done"
"$fastboot" reboot bootloader

echo "Flashing firmware..."
flash_ab bluetooth "$firmware/common/bluetooth.img"
flash_ab cda "$firmware/common/cda.img"
flash_ab cmnlib "$firmware/common/cmnlib.img"
flash_ab cmnlib64 "$firmware/common/cmnlib64.img"
flash_ab devcfg "$firmware/common/devcfg.img"
flash_ab dsp "$firmware/common/dsp.img"
flash_ab hidden "$firmware/common/hidden.img"
flash_ab hyp "$firmware/common/hyp.img"
flash_ab keymaster "$firmware/common/keymaster.img"
flash_ab mdtp "$firmware/common/mdtp.img"
flash_ab mdtpsecapp "$firmware/common/mdtpsecapp.img"
flash_ab modem "$firmware/common/modem.img"
flash_ab nvdef "$firmware/common/nvdef.img"
flash persist "$firmware/common/persist.img"
flash_ab pmic "$firmware/common/pmic.img"
flash_ab rpm "$firmware/common/rpm.img"
flash_ab splash "$firmware/common/splash.img"
flash_ab systeminfo "$firmware/common/systeminfo.img"
flash_ab tz "$firmware/common/tz.img"

echo "Flashing firmware done"

echo "Preparing for ROM flashing..."

flash_raw_ab boot "$firmware/$dest/boot.img"
erase_ab system
erase misc

if [ "$dest" == "treble" ]; then
    # Check all the zip files in the current directory
    unset options i
    while IFS= read -r -d $'\0' f; do
    # Is it a ROM zip? (Does it contain a payload file?)
    if unzip -Z1 "$f" | grep -q payload.bin; then options[i++]=$(echo "$f" | cut -c 3-); fi
    done < <(find . -maxdepth 1 -name "*.zip" -print0 )

    if [ ${#options[@]} -eq 0 ]; then
	    echo "No ROM files found, proceed with normal conversion."
        echo

        erase_ab vendor

        # Flash the modified misc partition to boot into recovery
        flash misc "$firmware/$dest/misc.img"
    elif [ ${#options[@]} -gt 1 ]; then
	    # Prompt for which zip if multiple found
        echo "Multiple ROM files detected. Please select which to use:"
        select opt in "${options[@]}"; do
            case $opt in
                *.zip)
                echo "ROM file $opt selected"
                "$dumper" "${@}" -c "$(nproc --all)" -o "$PWD/temp" "$opt"
                rom_dumped=1
                break
                ;;
                *)
                echo "Your input should be one of the numbers in the list!"
                ;;
            esac
            done
    elif [ ${#options[@]} -eq 1 ]; then
        echo "ROM zip detected: ${options[0]}"
        "$dumper" "${@}" -c "$(nproc --all)" -o "$PWD/temp" "${options[0]}"
        rom_dumped=1
    fi

    if [ "$rom_dumped" == "1" ]; then
        # Flash ROM
        flash_ab system "$PWD/temp/system.img"
        erase_ab vendor
        flash_ab vendor "$PWD/temp/vendor.img"

        # Delete temp files
        rm -r "$PWD/temp"
    fi
else
    flash_ab cda "$firmware/$dest/cda.img"

    flash box "$firmware/$dest/box.img"
    flash elabel "$firmware/$dest/elabel.img"
    flash_ab hidden "$firmware/$dest/hidden.img.ext4"

    flash logfs "$firmware/$dest/logfs_ufs_8mb.bin"
    flash storsec "$firmware/$dest/storsec.mbn"
    flash sutinfo "$firmware/$dest/sutinfo.img"

    # Flash stock ROM
    flash_ab system "$firmware/$dest/system.img"
fi

"$fastboot" "${@}" format userdata
"$fastboot" "${@}" set_active a

echo "All done! Enjoy your $dest device."

"$fastboot" "${@}" reboot
