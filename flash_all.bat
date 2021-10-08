set FASTBOOT=%~dp0platform-tools\windows\fastboot.exe
set IMG_PATH=%~dp0images

@echo "Repartitioning device..."
%FASTBOOT% %* erase boot_a || @echo "ERROR: Failed to modify partition table, please unlock your device!" & exit /B 1
%FASTBOOT% %* flash partition:0 %IMG_PATH%\gpt_both0.bin || @echo "Flash main partition table error" & exit /B 1
%FASTBOOT% %* flash abl --slot=all %IMG_PATH%\abl.img || @echo "Flash abl partition error" & exit /B 1
%FASTBOOT% %* flash xbl --slot=all %IMG_PATH%\xbl.img || @echo "Flash xbl partition error" & exit /B 1
@echo "Repartitioning done..."
%FASTBOOT% reboot bootloader

@echo "Flashing firmware..."
%FASTBOOT% %* flash bluetooth --slot=all %IMG_PATH%\bluetooth.img || @echo "Flash bluetooth error" & exit /B 1
%FASTBOOT% %* flash cda --slot=all %IMG_PATH%\cda.img || @echo "Flash cda error" & exit /B 1
%FASTBOOT% %* flash cmnlib --slot=all %IMG_PATH%\cmnlib.img || @echo "Flash cmnlib error" & exit /B 1
%FASTBOOT% %* flash cmnlib64 --slot=all %IMG_PATH%\cmnlib64.img || @echo "Flash cmnlib64 error" & exit /B 1
%FASTBOOT% %* flash devcfg --slot=all %IMG_PATH%\devcfg.img || @echo "Flash devcfg error" & exit /B 1
%FASTBOOT% %* flash dsp --slot=all %IMG_PATH%\dsp.img || @echo "Flash dsp error" & exit /B 1
%FASTBOOT% %* flash hidden --slot=all %IMG_PATH%\hidden.img || @echo "Flash hidden error" & exit /B 1
%FASTBOOT% %* flash hyp --slot=all %IMG_PATH%\hyp.img || @echo "Flash hyp error" & exit /B 1
%FASTBOOT% %* flash keymaster --slot=all %IMG_PATH%\keymaster.img || @echo "Flash keymaster error" & exit /B 1
%FASTBOOT% %* flash mdtp --slot=all %IMG_PATH%\mdtp.img || @echo "Flash mdtp error" & exit /B 1
%FASTBOOT% %* flash mdtpsecapp --slot=all %IMG_PATH%\mdtpsecapp.img || @echo "Flash mdtpsecapp error" & exit /B 1
%FASTBOOT% %* flash modem --slot=all %IMG_PATH%\modem.img || @echo "Flash modem error" & exit /B 1
%FASTBOOT% %* flash nvdef --slot=all %IMG_PATH%\nvdef.img || @echo "Flash nvdef error" & exit /B 1
%FASTBOOT% %* flash pmic --slot=all %IMG_PATH%\pmic.img || @echo "Flash pmic error" & exit /B 1
%FASTBOOT% %* flash rpm --slot=all %IMG_PATH%\rpm.img || @echo "Flash rpm error" & exit /B 1
%FASTBOOT% %* flash splash --slot=all %IMG_PATH%\splash.img || @echo "Flash splash error" & exit /B 1
%FASTBOOT% %* flash systeminfo --slot=all %IMG_PATH%\systeminfo.img || @echo "Flash systeminfo error" & exit /B 1
%FASTBOOT% %* flash tz --slot=all %IMG_PATH%\tz.img || @echo "Flash tz error" & exit /B 1
@echo "Flashing firmware done..."

@echo "Preparing for ROM flashing..."
%FASTBOOT% %* flash:raw boot --slot=all %IMG_PATH%\boot.img || @echo "Flash boot error" & exit /B 1
%FASTBOOT% %* erase system --slot=all || @echo "Erase system error" & exit /B 1
%FASTBOOT% %* erase vendor --slot=all || @echo "Erase vendor error" & exit /B 1
%FASTBOOT% %* erase misc || @echo "Erase misc error" & exit /B 1
%FASTBOOT% %* --set_active=a
%FASTBOOT% %* format userdata
@echo "All done! Enjoy your treble device."

%FASTBOOT% %* reboot
