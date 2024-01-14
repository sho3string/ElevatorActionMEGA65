@echo off
setlocal

set "outputFile1=pad4096.bin"
set "outputFile2=pad3840.bin"
set "length1=4096"
set "length2=3840"


echo "Create files used for padding"
fsutil file createnew %outputFile1% %length1%
fsutil file createnew %outputFile2% %length2%

echo File %outputFile1% created with %length1% bytes.
echo File %outputFile2% created with %length2% bytes.

endlocal

echo "Create the maincpu rom."
copy /b eabl_12.2732.ic69+ea_13.2732.ic68+ea_14.2732.ic67+eabl_15.2732.ic66+ea_16.2732.ic65+ea_17.2732.ic64+eabl_18.2732.ic55+eabl_19.2732.ic54 maincpu.rom

echo "Create the banked cpu rom."
copy /b eabl_12.2732.ic69+ea_13.2732.ic68+ea_14.2732.ic67+eabl_15.2732.ic66+ea_16.2732.ic65+ea_17.2732.ic64+pad4096.bin+eabl.2732.ic52 bankedcpu.rom

echo "Create the video rom."
copy /b  ea_20.2732.ic1+ea_21.2732.ic2+ea_22.2732.ic3+ea_23.2732.ic4+ea_24.2732.ic5+ea_25.2732.ic6+ea_26.2732.ic7+ea_27.2732.ic8 video.rom

echo "Create the sound rom."
copy /b ea_9.2732.ic70+ea_10.2732.ic71+pad4096.bin+pad4096.bin soundcpu.rom

echo "Create the layer rom."
copy/b eb16.ic22+pad3840.bin layer.rom

echo "Remove files used for padding"
del pad4096.bin
del pad3840.bin
