Elevator Action - for MEGA65
============================

Elevator Action is a classic arcade video game that originated in 1983 and quickly became a standout title in the golden age of arcade gaming. Developed by Taito, Elevator Action is renowned for its innovative gameplay and unique premise.

In Elevator Action, players take on the role of a secret agent tasked with infiltrating a high-rise building filled with enemy agents. The goal is to retrieve secret documents hidden within the building's various floors while avoiding or eliminating opposition along the way.

The game's primary mechanic revolves around navigating elevators and escalators to move between different floors of the building. Players must strategically time their movements to avoid enemy agents and utilize the elevators to their advantage. Elevator Action's dynamic level design, coupled with its challenging enemy encounters, adds an engaging layer of complexity to the gameplay.

As players progress through the levels, they encounter various obstacles and adversaries, including armed guards, surveillance cameras, and other hazards. Elevator Action's combination of stealth, strategic planning, and action-packed sequences provides a unique gaming experience.

Elevator Action features classic pixel art visuals and an iconic soundtrack that contributes to the overall nostalgic charm of the game. Originally designed for arcade cabinets, Elevator Action has been adapted and preserved through various platforms and emulators, allowing players to enjoy its timeless gameplay.

This core is based on the MiSTer Elevator Action core, leveraging the collaborative efforts of the MiSTer community. The MEGA65 adaptation of the Elevator Action core was accomplished in 2023 by [Developer Name], utilizing the MiSTer2MEGA65 framework and incorporating QNICE-FPGA for FAT32 support and on-screen menu functionality.


[MiSTer](https://github.com/MiSTer-devel/Arcade-TaitoSystemSJ_MiSTer) ElevatorAction core which itself is based on the work of [many others](AUTHORS).

[Muse aka sho3string](https://github.com/sho3string)
ported the core to the MEGA65 in 2024.

The core uses the [MiSTer2MEGA65](https://github.com/sy2002/MiSTer2MEGA65)
framework and [QNICE-FPGA](https://github.com/sy2002/QNICE-FPGA) for
FAT32 support (loading ROMs, mounting disks) and for the
on-screen-menu.

How to install the core
-----------------------

1. **Download ROM**: Download the Bosconian MAME ROM ZIP file (do not unzip!) from the internet.
   Search for the Elevator Action bootleg rom ( elevatorb ).
 
3. **Download the batch script**: Download the provided Python script that
   prepares the ROMs
   [Link](https://github.com/sho3string/ElevatorActionMEGA65/blob/master/ElevatorAction_rom_installer.bat).

4. **Run the Batch script**: First extract all the files within the zip to any folder. Execute the batch script within this folder to create the following roms.
   maincpu.rom, bankedcpu.rom, soundcpu.rom, video.rom and later.rom
   
   Use the command `ElevatorAction_rom_installer.bat` .

7. **Copy the ROMs to your MEGA65 SD card**: Copy the generated folder with
   the ROMs to your MEGA65 SD card. You can use either the bottom SD card tray
   of the MEGA65 or the tray at the backside of the computer (the latter has
   precedence over the first).
   The ROMs need to be in the folder `arcade/elevator`.


8. **Setting up dip switches**

   Gto Game Setup after pressing the 'HELP' key, set the individual dip switches for that version in the dip section. There are three dipswitch settings.

   See below for description of dip settings.
   
   https://www.arcade-museum.com/dipswitch-settings/7700.html

   Once done, press the reset switch on the MEGA65 to load the new settings.


   
    
