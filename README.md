# T-Virus
T-Virus (for treble-virus) is a tool that takes a stock Nokia 8 firmware
and "infects" it with various parts from the Nokia 8 Sirocco firmware, generating
a firmware bundle that is compilant with Project Treble and can be flashed to a
Nokia 8 using NOST.

### Firmware sources
The base of T-Virus is the stock Nokia 8 firmware image (5150 at the time of
writing). When being run, the build script takes those files and replaces the
partition table with the one from Nokia 8 Sirocco. This required for creating
a vendor partition that the stock Nokia 8 does not have. The vendor image is taken
from the Sirocco firmware as well. During the build, the vendor image is mounted
as rw, and various files are copied over from the stock Nokia 8 system image, or
get patched to properly support the minor hardware differences between the two
phones. Those actions are defined through very basic scripts inside of the
`vendor` folder in this repository.

The boot image is a [modified](https://github.com/resident-nokia/umbrella/tree/treble)
version of my umbrella kernel, which has support for early mounting vendor. It
also includes a TWRP build with full support for Project Treble.

### SELinux hell
Because Android does some very weird stuff with SELinux contexts, you cannot
launch a service file when it has an unknown context. We have to fix that by
force-setting the SELinux context manually, but due to how SELinux works, this
is only possible on a Linux system **without** SELinux. This means, that you
cannot build this on a distribution with SELinux (Fedora in my case). I
fixed the problem by building the images in a Ubuntu VM.

### How to build?
First you have to download the latest firmware image from
https://tmsp.io/fs/xda/nb1, and the exdupe tool from https://www.quicklz.com/exdupe

Extract the firmware into a folder and then clone this repository, like this:
```bash
$ mkdir firmware
$ ./exdupe -R ~/Downloads/NB1-5150-0-00WW-B03.qlz firmware/
$ git clone https://github.com/resident-nokia/t-virus
$ cd t-virus
```

The build script has two options you have to set: a version and the path to
the extracted firmware. This means you have to run it like this:
```bash
$ ./build.sh --version v0.1 --firmware ../firmware
```

Leave it running and when it asks you, enter your sudo password. This is required
to mount the Android ext4 partitions and edit the files that are only accessable by
the (Android) root user, and retain their permissions.

When the script has finished the flashable firmware image will be inside of the
`out` folder. You can optionally package this as a .qlz file again using exdupe.

### What works?
* It boots
* Data decryption in recovery
* Flashing GSIs / OpenGApps in recovery
* WiFi
* Mobile Data
* Bluetooth
* Sound
* Vibration
* Calling
* Hardware buttons
* Fingerprint
* Camera
* GPS
* NFC
* SDCard
* Multi SIM
* 4k Video

### What doesn't work, or isn't tested
* Haptic feedback for Hardware buttons
* Bluetooth headphones don't get registered properly
* Nokia OZO audio support is missing
* Fingerprint sensor is reported as being on the back of the phone
* VoLTE (untested)

### Download?
**WARNING:** This is not useable as a daily driver. Continue only if you are
able to troubleshoot things if neccessary (bootloops, bricking the phone,
causing the alarm app to declare nuclear war)

You can download the latest release from the releases page. It is a .qlz
firmware, so you will have to flash it through NOST. **You will need a completely
unlocked bootloader.** When flashing, make sure to select the "Erase Userdata"
option, not doing this will most certainly bootloop the phone.

After the installation completed, your phone will reboot into phh's AOSP GSI.
If you want to use a different GSI (you most likely will), follow these steps:
* Download your favorite GSI
* Unpack every form of compression, so you end up with a .img file
* Boot into recovery
* Copy the .img to the internal storage of your phone, or to your SDCard
* Select "Install" -> "Install .img", select the image file you copied and flash
 it to your system partition
* Then install OpenGApps or any other modifications you like.
* Wipe /data to allow the new system image to boot properly and then reboot

To update to a newer version without having to erase userdata, download the
zipped vendor image from the release page, and flash the image inside in TWRP.

If you want to go back to stock, simply download the
[5150-revert](https://github.com/resident-nokia/t-virus/releases/tag/5150-revert)
firmware and flash it with NOST, with the "Erase Userdata" option enabled.
It will revert all changes T-Virus made to your phone. **Firmwares from
https://tmsp.io/fs/xda/nb1 will not work.**

### License
Go nuts. I really don't care what you do with this.
