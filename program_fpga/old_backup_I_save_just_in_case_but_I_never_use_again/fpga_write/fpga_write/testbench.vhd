--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:28:55 03/31/2010
-- Design Name:   
-- Module Name:   C:/Documents and Settings/hrid/My Documents/myexample project/my fpga project/FX2LP-FPGA/test folder/itworks/commented/stream in/FX2LP-FPGA/testbench.vhd
-- Project Name:  FX2LP-FPGA
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fpga_master
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fpga_master
    PORT(
	 
	--	gsr       : in  STD_LOGIC;    
  --  data      : inout  STD_LOGIC_VECTOR(31 downto 0); 
    faddr      : out STD_LOGIC_VECTOR(1 downto 0); 
    slrd      : out STD_LOGIC;                    
    slwr      : out STD_LOGIC;     
	slcs  	  : out STD_LOGIC;
    
    flagd     : in  STD_LOGIC;                    
    flaga     : in  STD_LOGIC;                   
    clk       : in  STD_LOGIC;                   
    sloe      : out STD_LOGIC 

--	mode	  : in  STD_LOGIC_VECTOR(1 downto 0) ;
--	pktend      : out STD_LOGIC 
	
        );
    END COMPONENT;
	 
	 
    

   --Inputs
   signal flagf : std_logic := '0';
   signal flage : std_logic := '0';
   signal clk : std_logic := '0';

	--BiDirs
   signal fdata : std_logic_vector(31 downto 0);

 	--Outputs
   signal faddr : std_logic_vector(1 downto 0);
   signal slrd : std_logic;
   signal slwr : std_logic;
   signal slcs : std_logic;
   signal gstate : std_logic_vector(3 downto 0);
   signal mode : std_logic_vector(1 downto 0);
   signal sloe : std_logic;
   signal pktend : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20.83 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fpga_master PORT MAP (
	
	-- gsr      => '0',
  --  data     => fdata,
    faddr     => faddr,
    slrd     => slrd ,                
    slwr     => slwr ,   
	slcs  	 => slcs,
    
    flagd    => flagf  ,                
    flaga    =>  flage ,               
    clk      =>  clk   ,               
    sloe     => sloe

	--mode		 => mode,
	--pktend   => pktend  

        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for 50 us;
		clk <= '1';
		wait for 50 us;
   end process;
	
	pktend <= '1';
	
	
	process
   begin	

		flagf <= '1';
		flage <= '1';
		mode  <= "01";

		
		wait for 100 ms;
		

		flagf <= '0';
		flage <= '0';
		mode  <= "10";

		
		wait for 100 ms ;
		
		
		
   end process;
	

 



END;


