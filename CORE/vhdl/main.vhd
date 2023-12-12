----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   generic (
      G_VDNUM                 : natural                     -- amount of virtual drives
   );
   port (
      clk_main_i              : in  std_logic;
      clk_video_i             : in  std_logic;
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;
      dim_video_o             : out std_logic;

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      -- Video output
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(2 downto 0);
      video_green_o           : out std_logic_vector(2 downto 0);
      video_blue_o            : out std_logic_vector(2 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0);
      
       -- Dipswitches
      dsw_a_i                 : in  std_logic_vector(7 downto 0);
      dsw_b_i                 : in  std_logic_vector(7 downto 0);
      dsw_c_i                 : in  std_logic_vector(7 downto 0);

      dn_clk_i                : in  std_logic;
      dn_addr_i               : in  std_logic_vector(24 downto 0);
      dn_data_i               : in  std_logic_vector(7 downto 0);
      dn_wr_i                 : in  std_logic;

      
      osm_control_i      : in  std_logic_vector(255 downto 0)
      
   );
end entity main;

architecture synthesis of main is

signal keyboard_n        : std_logic_vector(79 downto 0);
signal pause_cpu         : std_logic;
signal status            : signed(31 downto 0);
signal flip_screen       : std_logic;
signal flip              : std_logic := '0';
signal forced_scandoubler: std_logic;
signal gamma_bus         : std_logic_vector(21 downto 0);
signal audio             : std_logic_vector(15 downto 0);


-- I/O board button press simulation ( active high )
-- b[1]: user button
-- b[0]: osd button

signal buttons           : std_logic_vector(1 downto 0);
signal reset             : std_logic  := reset_hard_i or reset_soft_i;


-- highscore system
signal hs_address       : std_logic_vector(15 downto 0);
signal hs_data_in       : std_logic_vector(7 downto 0);
signal hs_data_out      : std_logic_vector(7 downto 0);
signal hs_write_enable  : std_logic;

signal hs_pause         : std_logic;
signal options          : std_logic_vector(1 downto 0);
signal self_test        : std_logic;

constant C_MENU_OSMPAUSE     : natural := 2;
constant C_MENU_OSMDIM       : natural := 3;
constant C_MENU_FLIP         : natural := 9;

-- Game player inputs
constant m65_1             : integer := 56; --Player 1 Start
constant m65_2             : integer := 59; --Player 2 Start
constant m65_5             : integer := 16; --Insert coin 1
constant m65_6             : integer := 19; --Insert coin 2

-- Offer some keyboard controls in addition to Joy 1 Controls
constant m65_up_crsr       : integer := 73; --Player up
constant m65_vert_crsr     : integer := 7;  --Player down
constant m65_left_crsr     : integer := 74; --Player left
constant m65_horz_crsr     : integer := 2;  --Player right
constant m65_z             : integer := 12; --Fire
constant m65_x             : integer := 23; -- ump


-- Pause, credit button & test mode
constant m65_p             : integer := 41; --Pause button
constant m65_s             : integer := 13; --Service 1
constant m65_capslock      : integer := 72; --Service Mode
constant m65_help          : integer := 67; --Help key

begin
  
    options(0) <= osm_control_i(C_MENU_OSMPAUSE);
    options(1) <= osm_control_i(C_MENU_OSMDIM);
    flip_screen <= osm_control_i(C_MENU_FLIP);
    

    i_ttsj : entity work.taitosj_fpga
    port map (
        clkm_48MHZ      => clk_video_i,
        clkm_32MHZ      => clk_main_i,
        pcb             => (others => '0'),  -- to do
        RED             => video_red_o,
        GREEN           => video_green_o,
        BLUE            => video_blue_o,
        core_pix_clk    => video_ce_o,
        H_SYNC          => video_hs_o,
	    V_SYNC          => video_vs_o,
	    H_BLANK         => video_hblank_o,
	    V_BLANK         => video_vblank_o,
        RESET_n         => not reset,
        pause           => pause_cpu or pause_i,
        m_service       => keyboard_n(m65_s),
        m_coina         => keyboard_n(m65_5),
        m_start1p       => keyboard_n(m65_1),
        m_right         => joy_1_right_n_i or keyboard_n(m65_horz_crsr),
        m_left          => joy_1_left_n_i or keyboard_n(m65_left_crsr),
        m_down          => joy_1_down_n_i or keyboard_n(m65_vert_crsr),
        m_up            => joy_1_up_n_i or keyboard_n(m65_up_crsr),
        m_shoot         => joy_1_fire_n_i or keyboard_n(m65_z),
        m_shoot2        => joy_1_fire_n_i or keyboard_n(m65_x),
        m_coinb         => keyboard_n(m65_6),
        m_start2p       => keyboard_n(m65_2),
        DIP1            => dsw_a_i,
        DIP2            => dsw_b_i,
        DIP3            => dsw_c_i,
        dn_clk          => dn_clk_i,
        dn_addr         => dn_addr_i,
        dn_data         => dn_data_i,
        dn_wr           => dn_wr_i,
        hs_address      => hs_address,
        hs_data_out     => hs_data_out,
        hs_data_in      => hs_data_in,
        hs_write        => hs_write_enable,
        audio_l         => audio_left_o,
	    audio_r         => audio_right_o
        
    );

    i_pause : entity work.pause
     generic map (
     
        RW  => 3,
        GW  => 3,
        BW  => 3,
        CLKSPD => 32
        
     )         
     port map (
     
         clk_sys        => clk_main_i,
         reset          => reset,
         user_button    => keyboard_n(m65_p),
         pause_request  => hs_pause,
         options        => options,  -- not status(11 downto 10), - TODO, hookup to OSD.
         OSD_STATUS     => '0',       -- disabled for now - TODO, to OSD
         r              => video_red_o,
         g              => video_green_o,
         b              => video_blue_o,
         pause_cpu      => pause_cpu,
         dim_video      => dim_video_o
         --rgb_out        TODO
         
      );
      
   -- @TODO: Keyboard mapping and keyboard behavior
   -- Each core is treating the keyboard in a different way: Some need low-active "matrices", some
   -- might need small high-active keyboard memories, etc. This is why the MiSTer2MEGA65 framework
   -- lets you define literally everything and only provides a minimal abstraction layer to the keyboard.
   -- You need to adjust keyboard.vhd to your needs
   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         keyboard_n_o          => keyboard_n
      ); -- i_keyboard

end architecture synthesis;

