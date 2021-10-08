fastboot erase misc

fastboot flash partition:0 images\treble\gpt_both0.bin

fastboot flash abl_a images\common\abl.img
fastboot flash abl_b images\common\abl.img
fastboot flash xbl_a images\common\xbl.img
fastboot flash xbl_b images\common\xbl.img

fastboot reboot bootloader

fastboot flash bluetooth_a images\common\bluetooth.img
fastboot flash bluetooth_b images\common\bluetooth.img
fastboot flash cda_a images\common\cda.img
fastboot flash cda_b images\common\cda.img
fastboot flash cmnlib_a images\common\cmnlib.img
fastboot flash cmnlib_b images\common\cmnlib.img
fastboot flash cmnlib64_a images\common\cmnlib64.img
fastboot flash cmnlib64_b images\common\cmnlib64.img
fastboot flash devcfg_a images\common\devcfg.img
fastboot flash devcfg_b images\common\devcfg.img
fastboot flash dsp_a images\common\dsp.img
fastboot flash dsp_b images\common\dsp.img
fastboot flash hidden_a images\common\hidden.img
fastboot flash hidden_b images\common\hidden.img
fastboot flash hyp_a images\common\hyp.img
fastboot flash hyp_b images\common\hyp.img
fastboot flash keymaster_a images\common\keymaster.img
fastboot flash keymaster_b images\common\keymaster.img
fastboot flash mdtp_a images\common\mdtp.img
fastboot flash mdtp_b images\common\mdtp.img
fastboot flash mdtpsecapp_a images\common\mdtpsecapp.img
fastboot flash mdtpsecapp_b images\common\mdtpsecapp.img
fastboot flash modem_a images\common\modem.img
fastboot flash modem_b images\common\modem.img
fastboot flash nvdef_a images\common\nvdef.img
fastboot flash nvdef_b images\common\nvdef.img
fastboot flash persist images\common\persist.img
fastboot flash pmic_a images\common\pmic.img
fastboot flash pmic_b images\common\pmic.img
fastboot flash rpm_a images\common\rpm.img
fastboot flash rpm_b images\common\rpm.img
fastboot flash splash_a images\common\splash.img
fastboot flash splash_b images\common\splash.img
fastboot flash systeminfo_a images\common\systeminfo.img
fastboot flash systeminfo_b images\common\systeminfo.img
fastboot flash tz_a images\common\tz.img
fastboot flash tz_b images\common\tz.img

fastboot flash:raw boot_a images\treble\boot.img
fastboot flash:raw boot_b images\treble\boot.img
fastboot erase system_a
fastboot erase system_b
erase misc
fastboot erase vendor_a
fastboot erase vendor_b

fastboot flash misc images\treble\misc.img

fastboot format userdata
fastboot set_active a

fastboot reboot
