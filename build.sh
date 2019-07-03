#!/bin/bash

DIR=$(dirname $(readlink -f "$0"))
OUT=$DIR/out
mkdir -p $OUT

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -v|--version)
        VERSION="$2"
        shift
        shift
        ;;
        -f|--firmware)
        FIRMWARE="$2"
        shift
        shift
        ;;
        -h|--help)
        echo "build.sh --version 0.x --firmware /path/to/stock/fw"
        exit 0
        ;;
        *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}"

NB1=$FIRMWARE
A1N="$DIR/data"

getImageNV() {
    cp ${!1}/$(ls ${!1} | grep $2) $OUT/$2
}

getImage() {
    cp ${!1}/$(ls ${!1} | grep $2) "$OUT/TV-$VERSION-$2"
    sed -i "s/\"$2\"/\"TV-$VERSION-$2\"/g" $OUT/t-virus-$VERSION.mlf
}

unpackSplit() {
    cat $DIR/data/*$1.zip* > $DIR/data/$1.zip
    unzip $DIR/data/$1.zip -d $DIR/data
    rm $DIR/data/$1.zip
}

cp $DIR/t-virus.mlf $OUT/t-virus-$VERSION.mlf

# Unpack zipped A1N files
unpackSplit vendor
unpackSplit boot
unpackSplit system

mountSparse() {
    mkdir -p $2
    $DIR/bin/simg2img $1 $2.img
    sudo mount -o rw $2.img $2
}

# We need to patch vendor for better NB1 support. Mount the original
# system image to copy over files
VENDOR=$(ls $DIR/data | grep vendor.img)
SYSTEM=$(ls $FIRMWARE | grep system.img)

mountSparse $DIR/data/$VENDOR $DIR/tmp/vendor
mountSparse $FIRMWARE/$SYSTEM $DIR/tmp/system

# Copy blobs
IFS=$'\n'
for line in $(cat $DIR/vendor/*.copy.txt)
do
    line=$(echo $line | sed 's/\t/ /g' | sed 's/  */ /g')
    from=$(echo $line | cut -d' ' -f1)
    to=$(echo $line | cut -d' ' -f2)

    sudo cp -a $DIR/tmp/system/$from $DIR/tmp/vendor/$to
done

for line in $(cat $DIR/vendor/*.selinux.txt)
do
    line=$(echo $line | sed 's/\t/ /g' | sed 's/  */ /g')
    file=$(echo $line | cut -d' ' -f1)
    selinux=$(echo $line | cut -d' ' -f2)

    sudo setfattr -n security.selinux -v "$selinux" $DIR/tmp/vendor/$file
done

# Patch files
for line in $(cat $DIR/vendor/*.patch.txt | sed 's/\\n/{NL}/g')
do
    file=$(echo $line | cut -d' ' -f1)
    sed=$(echo ${line#"$file"} | xargs | sed 's/{NL}/\\n/g')

    sudo perl -pe "$sed" -i $DIR/tmp/vendor/$file
done
unset IFS
sudo umount $DIR/tmp/system
sudo umount $DIR/tmp/vendor
$DIR/bin/img2simg $DIR/tmp/vendor.img $DIR/data/$VENDOR
sudo rm -r $DIR/tmp

# Use the main partition table from sirocco
getImage "A1N" "gpt_both0.bin"
getImage "A1N" "gpt_main0.bin"
getImage "A1N" "gpt_backup0.bin"

# Get the other ones from NB1
getImage "NB1" "gpt_both1.bin"
getImage "NB1" "gpt_main1.bin"
getImage "NB1" "gpt_backup1.bin"
getImage "NB1" "gpt_both2.bin"
getImage "NB1" "gpt_main2.bin"
getImage "NB1" "gpt_backup2.bin"
getImage "NB1" "gpt_both3.bin"
getImage "NB1" "gpt_main3.bin"
getImage "NB1" "gpt_backup3.bin"
getImage "NB1" "gpt_both4.bin"
getImage "NB1" "gpt_main4.bin"
getImage "NB1" "gpt_backup4.bin"
getImage "NB1" "gpt_both5.bin"
getImage "NB1" "gpt_main5.bin"
getImage "NB1" "gpt_backup5.bin"

getImage "NB1" "tz.mbn"
getImage "NB1" "rpm.mbn"
getImage "NB1" "hyp.mbn"
getImage "NB1" "pmic.elf"
getImage "NB1" "keymaster.mbn"
getImage "NB1" "cmnlib.mbn"
getImage "NB1" "cmnlib64.mbn"
getImage "NB1" "devcfg.mbn"
getImageNV "NB1" "NB1-0-488B-00WW-abl_service.zip"
getImageNV "NB1" "NB1-0-488B-xbl_service.zip"
getImageNV "NB1" "systeminfo.img"

# System, Boot and Vendor come from A1N
getImage "A1N" "system.img"
getImage "A1N" "vendor.img"
getImage "A1N" "boot.img"

getImage "NB1" "persist.img"
getImage "NB1" "NON-HLOS.bin"
getImage "NB1" "adspso.bin"
getImage "NB1" "BTFM.bin"
getImage "NB1" "mdtp.img"
getImage "NB1" "logfs_ufs_8mb.bin"
getImage "NB1" "NV-default.mbn"
getImage "NB1" "cda.img"
getImage "NB1" "hidden.img.ext4"
getImage "NB1" "sutinfo.img"
getImage "NB1" "splash.img"
getImage "NB1" "splash2.img"
getImage "NB1" "mdtpsecapp.mbn"
getImage "NB1" "storsec.mbn"
getImage "NB1" "abl.elf"
getImage "NB1" "xbl.elf"
getImage "NB1" "keyinfo.img"

getImage "NB1" "patch0.xml"
getImage "NB1" "patch1.xml"
getImage "NB1" "patch2.xml"
getImage "NB1" "patch3.xml"
getImage "NB1" "patch4.xml"
getImage "NB1" "patch5.xml"
getImage "NB1" "rawprogram0.xml"
getImage "NB1" "rawprogram1.xml"
getImage "NB1" "rawprogram2.xml"
getImage "NB1" "rawprogram3.xml"
getImage "NB1" "rawprogram4.xml"
getImage "NB1" "rawprogram5.xml"
getImage "NB1" "prog_ufs_firehose_8998_ddr.elf"
getImage "NB1" "provision_fih.xml"
getImageNV "NB1" "NvDefinition.xml"

rm $DIR/data/*vendor.img
rm $DIR/data/*boot.img
rm $DIR/data/*system.img
