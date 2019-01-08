library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity testbench_lb is
end testbench_lb;

architecture testbench of testbench_lb is

signal		reset_in_n : std_logic;                                ---input reset active low
signal		clk	   : std_logic;                                ---input clk 27 Mhz  
signal		clk_out	   : std_logic;                               ---output clk 100 Mhz and 180 phase shift 
signal		slcs 	   :  std_logic;                               ---output chip select
signal		fdata      : std_logic_vector(31 downto 0);                 
signal		fdata_out      : std_logic_vector(31 downto 0);         
signal		faddr      : std_logic_vector(1 downto 0);            ---output fifo address
signal		slrd	   : std_logic;                               ---output read select
signal		sloe	   : std_logic;                               ---output output enable select
signal		slwr	   : std_logic;                               ---output write select
                    
signal		flaga	   : std_logic;                                
signal		flagb	   : std_logic;
signal		flagc	   : std_logic;
signal		flagd	   : std_logic;

signal		pktend	: std_logic;                               ---output pkt end 
signal		PMODE	   : std_logic_vector(1 downto 0);
signal		RESET	   : std_logic;
signal		mode_p     : std_logic_vector(2 downto 0);            ----signals for debugging
		
component slaveFIFO2b_fpga_top  
	port(
		reset_in_n : in std_logic;                                ---input reset active low
		clk	   : in std_logic;                                ---input clk 27 Mhz  
		clk_out	   : out std_logic;                               ---output clk 100 Mhz and 180 phase shift 
		slcs 	   : out std_logic;                               ---output chip select
		fdata      : inout std_logic_vector(31 downto 0);         
		faddr      : out std_logic_vector(1 downto 0);            ---output fifo address
		slrd	   : out std_logic;                               ---output read select
		sloe	   : out std_logic;                               ---output output enable select
		slwr	   : out std_logic;                               ---output write select
                    
		flaga	   : in std_logic;                                
		flagb	   : in std_logic;
		flagc	   : in std_logic;
		flagd	   : in std_logic;

		pktend	   : out std_logic;                               ---output pkt end 
		PMODE	   : out std_logic_vector(1 downto 0);
		RESET	   : out std_logic;
		mode_p     : in std_logic_vector(2 downto 0)              ----signals for debugging
);
end component;


begin  -- architecture begin

	-- generate clock	
	clk_gen:process
	 begin
	 	 clk<='0';
	 	 wait for 18518 ps;
	 	 loop
	 	 	 clk<=not clk;
	 	 	 wait for 18518 ps;
	 	 end loop;
	end process;

 	
  slave_top:slaveFIFO2b_fpga_top port map(
		reset_in_n => reset_in_n,                              ---input reset active low
		clk     => clk,                         ---input clk 27 Mhz  
		clk_out	=> clk_out,                              ---output clk 100 Mhz and 180 phase shift 
		slcs 	=> slcs,                              ---output chip select
		fdata   => fdata,      
		faddr   => faddr,           ---output fifo address
		slrd	=> slrd,                              ---output read select
		sloe	=> sloe,                              ---output output enable select
		slwr	=> slwr,                              ---output write select
                    
		flaga	=> flaga,                               
		flagb	=> flagb,
		flagc	=> flagc, 
		flagd	=> flagd,  

		pktend	=> pktend,                              ---output pkt end 
		PMODE	=> PMODE,
		RESET	=> RESET,
		mode_p  => mode_p             ----signals for debugging
  	); 
  	
	
	tb: process
	begin
		reset_in_n <= '0';
		wait for 100 ns;
		reset_in_n <= '1';
		mode_p  <= "000";
		flaga <= '0';
		flagb <= '0';
		flagc <= '0';
		flagd <= '0';
		wait for 5000 ns;
		mode_p  <= "011";
		flaga <= '1';
		flagb <= '1';
		wait for 3000 ns;
		flagb <= '0';
		wait for 40 ns;
		flaga <= '0';
		wait for 30 ns;
		mode_p  <= "000";
		wait for 2000 ns;

		mode_p  <= "100";	
		flagc <= '1';
		flagd <= '1';
		wait for 3000 ns;
		flagd <= '0';
		wait for 40 ns;
		flagc <= '0';
		wait for 30 ns;
		mode_p  <= "000";
		wait for 10000000 ns;		
	end process;

process(clk_out, reset_in_n)begin
	if(reset_in_n = '0')then 
		fdata_out <= (31 downto 0 => '0');
	elsif(clk_out'event and clk_out = '1')then	
		if(mode_p = 4)then
			fdata_out<= (31 downto 0 => '1');	
      end if;
    end if;
end process;

fdata <= (31 downto 0 => 'Z') when (mode_p = 3) else fdata_out;

end testbench;

