# t-virus
t-virus (for treble-virus) is a tool that takes a stock Nokia 8 (NB1) firmware
and "infects" it with various parts from the Nokia 8 Sirocco firmware, generating 
a firmware bundle that is compilant with Project Treble and can be flashed to a 
Nokia 8 using NOST.

### Firmware sources
The majority of the files are taken from a stock NB1 firmware. It is not downloaded
automatically, if you want to run the script you have to download and unpack a
firmware that your image will be based on.

The GPT partition table and the vendor image are from the 4120 A1N firmware.
They are shipped with the tool, you don't have to download them yourself.
The system image that gets installed is not the image that is shipped with A1N,
but phh's AOSP GSI, providing a barebones testing environment. There
is no reason to download a 2 GB system image when everyone will flash their
favorite GSI anyways.

The boot image is a [modified](https://github.com/resident-nokia/umbrella/tree/treble)
version of my umbrella kernel, which has support for early mounting vendor. The
boot image also includes a TWRP build that has support for Project Treble.

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

### What doesn't work, or isn't tested
* The second SIM slot
* Haptic feedback for Hardware buttons
* Fingerprint sensor is reported as being on the back of the phone
* VoLTE (untested)

### SELinux hell
Because Android does some very weird stuff with SELinux contexts, you cannot
launch a service file when it has an unknown context. We have to fix that by
force-setting the SELinux context manually, but due to how SELinux works, this
is only possible on a Linux system **without** SELinux. This means, that you
cannot build this on a distribution with SELinux (Fedora in my case). I
fixed the problem by building the images in a Ubuntu VM.

### Download?
**WARNING:** This is not useable as a daily driver. Continue only if you are 
able to troubleshoot things if neccessary (bootloops, bricking the phone, 
causing the alarm app to declare nuclear war)

**WARNING:** There are currently some issues with reverting to stock. The system
boots but gets stuck at the bootlogo.

You can download the latest release from the releases page. It is a .qlz
firmware, so you will have to flash it through NOST. **You will need a completely unlocked 
bootloader.** When flashing, make sure to select the "Erase Userdata" option,
not doing this will most certainly bootloop the phone.

If you want to go back to stock, simply download the latest firmware from https://bit.ly/nokia-nb1
and flash it with NOST. It will revert all changes t-virus made to your phone.

### License
Go nuts. I really don't care what you do with this.
