
-- VHDL Instantiation Created from source file slaveFIFO2b_fpga_top.vhd -- 17:06:04 02/12/2019
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT slaveFIFO2b_fpga_top
	PORT(
		reset_in_n : IN std_logic;
		clk : IN std_logic;
		flaga : IN std_logic;
		flagb : IN std_logic;
		flagc : IN std_logic;
		flagd : IN std_logic;
		mode_p : IN std_logic_vector(2 downto 0);    
		fdata : INOUT std_logic_vector(31 downto 0);      
		clk_out : OUT std_logic;
		slcs : OUT std_logic;
		faddr : OUT std_logic_vector(1 downto 0);
		slrd : OUT std_logic;
		sloe : OUT std_logic;
		slwr : OUT std_logic;
		pktend : OUT std_logic;
		PMODE : OUT std_logic_vector(1 downto 0);
		RESET : OUT std_logic
		);
	END COMPONENT;

	Inst_slaveFIFO2b_fpga_top: slaveFIFO2b_fpga_top PORT MAP(
		reset_in_n => ,
		clk => ,
		clk_out => ,
		slcs => ,
		fdata => ,
		faddr => ,
		slrd => ,
		sloe => ,
		slwr => ,
		flaga => ,
		flagb => ,
		flagc => ,
		flagd => ,
		pktend => ,
		PMODE => ,
		RESET => ,
		mode_p => 
	);


