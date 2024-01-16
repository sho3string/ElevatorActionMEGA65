#!/bin/bash

outputFile1="pad4096.bin"
outputFile2="pad3840.bin"
outputFile3="eacfg"
length1=4096
length2=3840
length3=93

echo "Create files used for padding"
dd if=/dev/zero of="$outputFile1" bs=1 count=$length1
dd if=/dev/zero of="$outputFile2" bs=1 count=$length2
dd if=/dev/zero bs=1 count=93 | tr "\000" "\377" > $outputFile3

echo "File $outputFile1 created with $length1 bytes."
echo "File $outputFile2 created with $length2 bytes."

echo "Create the maincpu rom."
cat eabl_12.2732.ic69 ea_13.2732.ic68 ea_14.2732.ic67 eabl_15.2732.ic66 ea_16.2732.ic65 ea_17.2732.ic64 eabl_18.2732.ic55 eabl_19.2732.ic54 > maincpu.rom

echo "Create the banked cpu rom."
cat eabl_12.2732.ic69 ea_13.2732.ic68 ea_14.2732.ic67 eabl_15.2732.ic66 ea_16.2732.ic65 ea_17.2732.ic64 pad4096.bin eabl.2732.ic52 > bankedcpu.rom

echo "Create the video rom."
cat ea_20.2732.ic1 ea_21.2732.ic2 ea_22.2732.ic3 ea_23.2732.ic4 ea_24.2732.ic5 ea_25.2732.ic6 ea_26.2732.ic7 ea_27.2732.ic8 > video.rom

echo "Create the sound rom."
cat ea_9.2732.ic70 ea_10.2732.ic71 pad4096.bin pad4096.bin > soundcpu.rom

echo "Create the layer rom."
cat eb16.ic22 pad3840.bin > layer.rom

echo "Remove files used for padding"
rm "$outputFile1" "$outputFile2"
