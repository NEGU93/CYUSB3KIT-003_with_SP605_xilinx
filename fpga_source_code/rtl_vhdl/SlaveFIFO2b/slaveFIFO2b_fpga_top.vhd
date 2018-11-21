library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity slaveFIFO2b_fpga_top is
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
--		PMODE_2	   : out std_logic
--		int_n      : in std_logic;
--		tri_state  : in std_logic_vector(12 downto 0)
	    );
end entity slaveFIFO2b_fpga_top;

architecture slaveFIFO2b_fpga_top_arch of slaveFIFO2b_fpga_top is
--components clk_gen
component clk_wiz_v3_6_2
	port(
	     CLK_IN1	: in std_logic;
	     CLK_OUT1   : out std_logic;
	     RESET      : in std_logic;
	     LOCKED	: out std_logic);
end component;

component ODDR2                       
	port(   
			  D0	: in std_logic;              
	        D1	: in std_logic;
	        C0	: in std_logic;
	        C1	: in std_logic;
	        Q 	: out std_logic;
			  CE  : in std_logic;
			  S   : in std_logic; 
			  R 	: in std_logic
		);      
end component;

--component partial
component slaveFIFO2b_partial
	port(
		reset_n			: in std_logic;
	        clk_100			: in std_logic;
                partial_mode_selected   : in std_logic;
                flaga_d                 : in std_logic;
                flagb_d 		: in std_logic;
                slwr_partial_n		: out std_logic;
                pktend_partial_n	: out std_logic;
                data_out_partial	: out std_logic_vector(31 downto 0)
	     );
end component;

--component zlp
component slaveFIFO2b_zlp
	port(
		reset_n                : in std_logic;
                clk_100                : in std_logic;
                zlp_mode_selected      : in std_logic;
                flaga_d                : in std_logic;
                flagb_d                : in std_logic;
                slwr_zlp_n             : out std_logic;
                pktend_zlp_n           : out std_logic;
                data_out_zlp           : out std_logic_vector(31 downto 0)
	    );
end component;

--component stremIN
component slaveFIFO2b_streamIN
	port(
		reset_n                   : in std_logic;
                clk_100                   : in std_logic;
                stream_in_mode_selected   : in std_logic;
                flaga_d                   : in std_logic;
                flagb_d                   : in std_logic;
                slwr_streamIN_n           : out std_logic;
                data_out_stream_in        : out std_logic_vector(31 downto 0)
	    );
end component;

--component streamOUT
component slaveFIFO2b_streamOUT
	port(
		reset_n                   : in std_logic;
                clk_100                   : in std_logic;
                stream_out_mode_selected  : in std_logic;
                flagc_d                   : in std_logic;
                flagd_d                   : in std_logic;
                stream_out_data_from_fx3  : in std_logic_vector(31 downto 0);
                slrd_streamOUT_n          : out std_logic;
                sloe_streamOUT_n          : out std_logic
	     );
end component;

component slaveFIFO2b_loopback
	port(
		 reset_n                             : in std_logic;
		 clk_100			     : in std_logic;
                 loopback_mode_selected              : in std_logic;
                 flaga_d                             : in std_logic;
                 flagb_d                             : in std_logic;
                 flagc_d                             : in std_logic;
                 flagd_d                             : in std_logic;
                 data_in_loopback                    : in std_logic_vector(31 downto 0);
                 slrd_loopback_n                     : out std_logic;
                 sloe_loopback_n                     : out std_logic;
                 slwr_loopback_n                     : out std_logic;
                 loopback_rd_select_slavefifo_addr   : out std_logic;
		 data_out_loopback                   : out std_logic_vector(31 downto 0)
	    );
end component;
	

--fixed transfer mode values
constant LOOPBACK    : std_logic_vector(2 downto 0) := "101";
constant PARTIAL     : std_logic_vector(2 downto 0) := "001";
constant ZLP         : std_logic_vector(2 downto 0) := "010";
constant STREAM_IN   : std_logic_vector(2 downto 0) := "011";
constant STREAM_OUT  : std_logic_vector(2 downto 0) := "100";

-------------------------------
---signals
------------------------------
signal reset_n			      : std_logic;
signal clk_100			      : std_logic;
signal clk_100_180		      : std_logic;
signal lock			      : std_logic;
signal mode_changed                   : std_logic;
signal data_out			      : std_logic_vector(31 downto 0);
signal data_out_d		      : std_logic_vector(31 downto 0);
signal fpga_master_data_out	      : std_logic_vector(31 downto 0);

signal slrd_n                        : std_logic;
signal slwr_n			      : std_logic;
signal slwr_n_d			      : std_logic;
signal sloe_n			      : std_logic;
signal slcs_n      		      : std_logic;

signal fifo_address                   : std_logic_vector(1 downto 0);
signal fifo_address_d                 : std_logic_vector(1 downto 0);


signal mode                           : std_logic_vector(2 downto 0);


signal data_out_partial	              : std_logic_vector(31 downto 0);
signal data_out_loopback              : std_logic_vector(31 downto 0);
signal data_out_zlp	              : std_logic_vector(31 downto 0);
signal data_out_stream_in             : std_logic_vector(31 downto 0);

--internal counter signals to delay

signal pktend_n		              : std_logic;
signal pktend_n_d	              : std_logic;
signal flaga_d                        : std_logic;
signal flagb_d                        : std_logic;
signal flagc_d                        : std_logic;
signal flagd_d                        : std_logic;

signal partial_mode_selected          : std_logic;
signal zlp_mode_selected              : std_logic;
signal stream_in_mode_selected        : std_logic;
signal stream_out_mode_selected       : std_logic;
signal loopback_mode_selected         : std_logic;

----------------------------
--states of fsms
----------------------------
--fpga master mode fsm
type fpga_master_states is (fpga_master_mode_idle, fpga_master_mode_loopback, fpga_master_mode_partial, fpga_master_mode_zlp, fpga_master_mode_stream_in, fpga_master_mode_stream_out);
signal current_fpga_master_mode, next_fpga_master_mode, current_fpga_master_mode_d : fpga_master_states;


--signals to dbug on board
signal fdata_d   : std_logic_vector(31 downto 0);
signal slwr_d    : std_logic;
signal pktend_d  : std_logic;
signal mode_d    : std_logic_vector(2 downto 0);
signal mode_d_s  : std_logic;


signal loopback_data_from_fx3   : std_logic_vector(31 downto 0);
signal stream_out_data_from_fx3 : std_logic_vector(31 downto 0);
signal reset2pll                : std_logic;

signal slwr_loopback_n    : std_logic;
signal slwr_streamIN_n    : std_logic;
signal slwr_partial_n     : std_logic;
signal slwr_zlp_n         : std_logic;

signal pktend_partial_n   : std_logic;
signal pktend_zlp_n       : std_logic;

signal slrd_loopback_n    : std_logic;
signal sloe_loopback_n    : std_logic;
signal slrd_streamOUT_n    : std_logic;
signal sloe_streamOUT_n    : std_logic;

signal loopback_rd_select_slavefifo_addr : std_logic;

begin  -- architecture begin

--generating the clock(PLL instantiation)
inst_clk : clk_wiz_v3_6_2
	port map (
                CLK_IN1	      => clk,
	        CLK_OUT1      => clk_100,
		RESET         => reset2pll,
                LOCKED	      => lock);

--used for TB
--clk_100 <= clk;


--ODDR2 instantiation to send the clk to FX3
oddr_inst : ODDR2                       
	port map (   
			  D0     => '0',                
	        D1     => '1',
	        C0     => clk_100,
	        C1     => not clk_100,
	        Q      => clk_out,
			  CE     => '1',
			  S      => '0',
			  R      => '0'
		);      

partial_inst : slaveFIFO2b_partial
	port map(
		reset_n			=> reset_n,				
	        clk_100			=> clk_100,			
                partial_mode_selected   => partial_mode_selected,   
                flaga_d                 => flaga_d,                 
                flagb_d 		=> flagb_d,		
                slwr_partial_n		=> slwr_partial_n,		
                pktend_partial_n	=> pktend_partial_n,	
                data_out_partial	=> data_out_partial	
	     );

--component zlp
zlp_inst : slaveFIFO2b_zlp
	port map(
		reset_n                 => reset_n,          
                clk_100                 => clk_100,         
                zlp_mode_selected       => zlp_mode_selected,
                flaga_d                 => flaga_d,          
                flagb_d                 => flagb_d,          
                slwr_zlp_n              => slwr_zlp_n,       
                pktend_zlp_n            => pktend_zlp_n,     
                data_out_zlp            => data_out_zlp    
	    );

--component stremIN
streamIN_inst : slaveFIFO2b_streamIN
	port map(
		reset_n                 => reset_n,                  
                clk_100                 => clk_100,                 
                stream_in_mode_selected => stream_in_mode_selected, 
                flaga_d                 => flaga_d,                 
                flagb_d                 => flagb_d,                 
                slwr_streamIN_n         => slwr_streamIN_n,         
                data_out_stream_in      => data_out_stream_in      
	    );                                                    
--instantiation of streamOUT
streamOUT_inst : slaveFIFO2b_streamOUT
	port map(
		reset_n                   => reset_n,                 
                clk_100                   => clk_100,                 
                stream_out_mode_selected  => stream_out_mode_selected,
                flagc_d                   => flagc_d,                 
                flagd_d                   => flagd_d,                 
                stream_out_data_from_fx3  => stream_out_data_from_fx3,
                slrd_streamOUT_n          => slrd_streamOUT_n,        
                sloe_streamOUT_n          => sloe_streamOUT_n        
	     );

--instantiation of loopback
loopback_inst : slaveFIFO2b_loopback
	port map(
		 reset_n                             => reset_n,                           
		 clk_100			     => clk_100,			  
                 loopback_mode_selected              => loopback_mode_selected,           
                 flaga_d                             => flaga_d,                          
                 flagb_d                             => flagb_d,                          
                 flagc_d                             => flagc_d,                          
                 flagd_d                             => flagd_d,                          
		 data_in_loopback                    => loopback_data_from_fx3,                
                 slrd_loopback_n                     => slrd_loopback_n,                   
                 sloe_loopback_n                     => sloe_loopback_n,                   
                 slwr_loopback_n                     => slwr_loopback_n,                   
                 loopback_rd_select_slavefifo_addr   => loopback_rd_select_slavefifo_addr,
		 data_out_loopback                   => data_out_loopback                
	    );                                       
		                                     
                                


--output signal asignments
slrd   <= slrd_n;
slwr   <= slwr_n_d;   
faddr  <= fifo_address_d;
sloe   <= sloe_n;
fdata  <= fpga_master_data_out;	
PMODE  <= "11";		
RESET  <= '1';	
slcs   <= slcs_n;
pktend <= pktend_n_d;

reset2pll <= not reset_in_n;
reset_n <= lock;

--floping the input data
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		fdata_d <= (others => '0');
	elsif(clk_100'event and clk_100 = '1')then
		fdata_d <= fdata;
	end if;	 
end process;

--selecting the input data for streamOUT or loopBack 
process(current_fpga_master_mode, fdata_d)begin
	if(current_fpga_master_mode = fpga_master_mode_loopback)then
		loopback_data_from_fx3   <= fdata_d;
		stream_out_data_from_fx3 <= (others => '0');
	elsif(current_fpga_master_mode = fpga_master_mode_stream_out)then
		loopback_data_from_fx3   <= (others => '0');
		stream_out_data_from_fx3 <= fdata_d;
	else
		loopback_data_from_fx3   <= (others => '0');
		stream_out_data_from_fx3 <= (others => '0');
	end if;
end process;	

--floping the INPUT mode
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		mode <= "000";
	elsif(clk_100'event and clk_100 = '1')then
		mode <= mode_p;
	end if;	 
end process;

--flopping the INPUTs flags
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		flaga_d <= '0';
		flagb_d <= '0';
		flagc_d <= '0';
		flagd_d <= '0';
	elsif(clk_100'event and clk_100 = '1')then
		flaga_d <= flaga;
		flagb_d <= flagb;
		flagc_d <= flagc;
		flagd_d <= flagd;
	end if;	
end process;


--chip selection
process(current_fpga_master_mode)begin
	if(current_fpga_master_mode = fpga_master_mode_idle)then
		slcs_n <= '1';
	else
		slcs_n <= '0';
	end if;	
end process;


--selection of slave fifo address
process(loopback_rd_select_slavefifo_addr, current_fpga_master_mode)begin
	if((loopback_rd_select_slavefifo_addr = '1') or (current_fpga_master_mode = fpga_master_mode_stream_out))then
		fifo_address <= "11";
	elsif((current_fpga_master_mode = fpga_master_mode_partial) or (current_fpga_master_mode = fpga_master_mode_zlp) or (current_fpga_master_mode = fpga_master_mode_stream_in))then
		fifo_address <= "00";
	else
		fifo_address <= "00";
	end if;	
end process;	

--flopping the output slave fifo address
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		fifo_address_d <= "00";
	elsif(clk_100'event and clk_100 = '1')then
		fifo_address_d <= fifo_address;
	end if;	 
end process;



--OUTPUT read/oe control signals generation
process(current_fpga_master_mode, slrd_loopback_n, sloe_loopback_n, slrd_streamOUT_n, sloe_streamOUT_n)begin
	case current_fpga_master_mode is
		when fpga_master_mode_loopback =>	
			slrd_n <= slrd_loopback_n;
		        sloe_n <= sloe_loopback_n;
		when fpga_master_mode_stream_out =>
			slrd_n <= slrd_streamOUT_n;
			sloe_n <= sloe_streamOUT_n;
		when others =>
			slrd_n <= '1';
			sloe_n <= '1';
	end case;
end process;	

--OUTPUT write control signal generation
process(current_fpga_master_mode, slwr_partial_n, slwr_zlp_n, slwr_loopback_n, slwr_streamIN_n)begin
	case current_fpga_master_mode is
		when fpga_master_mode_partial =>
			slwr_n <= slwr_partial_n;	
		when fpga_master_mode_zlp =>
			slwr_n <= slwr_zlp_n;
		when fpga_master_mode_stream_in =>
			slwr_n <= slwr_streamIN_n;
		when fpga_master_mode_loopback =>
			slwr_n <= slwr_loopback_n;	
		when others =>
			slwr_n <= '1';
	end case;
end process;	

process(clk_100, reset_n) begin
	if(reset_n = '0')then
		slwr_n_d <= '1';
        elsif(clk_100'event and clk_100 = '1')then
                slwr_n_d <= slwr_n;
        end if;
end process;


--pktend generation
process(current_fpga_master_mode, pktend_partial_n, pktend_zlp_n)begin
	case current_fpga_master_mode is
		when fpga_master_mode_partial =>
			pktend_n <= pktend_partial_n;
		when fpga_master_mode_zlp =>
			pktend_n <= pktend_zlp_n;
		when others =>
			pktend_n <= '1';
	end case;
end process;	

process(clk_100, reset_n) begin
	if(reset_n = '0')then
		pktend_n_d <= '1';
        elsif(clk_100'event and clk_100 = '1')then
                pktend_n_d <= pktend_n;
        end if;
end process;




--selection of loopback mode
process(current_fpga_master_mode)begin
	if(current_fpga_master_mode = fpga_master_mode_loopback)then
		loopback_mode_selected <= '1';
	else
		loopback_mode_selected <= '0';
	end if;
end process;	

--selection of partial
process(current_fpga_master_mode)begin
	if(current_fpga_master_mode = fpga_master_mode_partial)then
		partial_mode_selected <= '1';
	else
		partial_mode_selected <= '0';
	end if;
end process;

--selection of zlp mode
process(current_fpga_master_mode)begin
	if(current_fpga_master_mode = fpga_master_mode_zlp)then
		zlp_mode_selected <= '1';
	else
		zlp_mode_selected <= '0';
	end if;
end process;

--selection of stream in mode
process(current_fpga_master_mode)begin
	if(current_fpga_master_mode = fpga_master_mode_stream_in)then
		stream_in_mode_selected <= '1';
	else
		stream_in_mode_selected <= '0';
	end if;
end process;	

--selection of stream in mode
process(current_fpga_master_mode)begin
	if(current_fpga_master_mode = fpga_master_mode_stream_out)then
		stream_out_mode_selected <= '1';
	else
		stream_out_mode_selected <= '0';
	end if;
end process;



--Mode select state machine
fpga_master_mode_fsm_f : process(clk_100, reset_n) begin
	if(reset_n = '0')then
      		current_fpga_master_mode <= fpga_master_mode_idle;
        elsif(clk_100'event and clk_100 = '1')then
                current_fpga_master_mode <= next_fpga_master_mode;
        end if;
  end process;

--Mode select state machine combo
fpga_master_mode_fsm : process(current_fpga_master_mode, mode) begin
	next_fpga_master_mode <= current_fpga_master_mode;
	case current_fpga_master_mode is
		when fpga_master_mode_idle =>
			case mode is
				when LOOPBACK =>
					next_fpga_master_mode <= fpga_master_mode_loopback;
				when PARTIAL =>
					next_fpga_master_mode <= fpga_master_mode_partial;
				when ZLP =>
					next_fpga_master_mode <= fpga_master_mode_zlp;
				when STREAM_IN =>
					next_fpga_master_mode <= fpga_master_mode_stream_in;
				when STREAM_OUT =>
				   	next_fpga_master_mode <= fpga_master_mode_stream_out;
				when others =>
					next_fpga_master_mode <= fpga_master_mode_idle;
			end case;		
		when fpga_master_mode_loopback =>
			if(mode = LOOPBACK)then
				next_fpga_master_mode <= fpga_master_mode_loopback;
			else
				next_fpga_master_mode <= fpga_master_mode_idle;
			end if;
		when fpga_master_mode_partial =>
			if(mode = PARTIAL)then
				next_fpga_master_mode <= fpga_master_mode_partial;
			else
				next_fpga_master_mode <= fpga_master_mode_idle;
			end if;
		when fpga_master_mode_zlp =>
			if(mode = ZLP)then
				next_fpga_master_mode <= fpga_master_mode_zlp;
			else
				next_fpga_master_mode <= fpga_master_mode_idle;
			end if;
		when fpga_master_mode_stream_in =>
			if(mode = STREAM_IN)then
				next_fpga_master_mode <= fpga_master_mode_stream_in;
			else
				next_fpga_master_mode <= fpga_master_mode_idle;
			end if;
		when fpga_master_mode_stream_out =>
			if(mode = STREAM_OUT)then
				next_fpga_master_mode <= fpga_master_mode_stream_out;
			else
				next_fpga_master_mode <= fpga_master_mode_idle;
			end if;
		when others =>
			next_fpga_master_mode <= fpga_master_mode_idle;
	end case;
end process;	



--selection of data_out based on current mode
process(current_fpga_master_mode, data_out_partial, data_out_zlp, data_out_stream_in, data_out_loopback)begin
	case current_fpga_master_mode is
	when fpga_master_mode_partial =>
		data_out <= data_out_partial;

	when fpga_master_mode_zlp =>
		data_out <= data_out_zlp;

	when fpga_master_mode_stream_in =>
		data_out <= data_out_stream_in;
	
	when fpga_master_mode_loopback =>
		data_out <= data_out_loopback;

	when others =>
		data_out <= (others => '0');
	
	end case;
end process;


process(clk_100, reset_n) begin
	if(reset_n = '0')then
      		data_out_d <= (others => '0');
        elsif(clk_100'event and clk_100 = '1')then
                data_out_d <= data_out;
        end if;
  end process;


process(slwr_n_d, data_out_d)begin
	if(slwr_n_d = '1')then
		fpga_master_data_out <= (others =>'Z');
	else
		fpga_master_data_out <= data_out_d;
	end if;
end process;



--for dbuging on board
--process(clk_100, reset_al)begin
--	if(reset_al = '0')then
--		fdata_d <= (others =>'0');
--		slwr_d <= '1';
--		pktend_d <= '1';
--		mode_d   <= "000";
--	elsif(clk_100'event and clk_100 = '1')then
--		fdata_d <= fdata;
--		slwr_d <= slwr_al;
--		pktend_d <= pktend_al;
--		mode_d <= mode;
--	end if;
--end process;	

--mode_d_s <= mode_d(0) or mode_d(1) or mode_d(2);

--process(flaga_d,flagb_d,flagc_d,flagd_d,slwr_d,pktend_d) begin
--	if((flaga_d = '1') or (flagb_d = '1') or (flagc_d = '1') or (flagd_d = '1') or (slwr_d = '0') or (mode_d_s = '1') or(pktend_d = '0'))then
--		PMODE_2 <= '1';
--	else
--		PMODE_2 <= '0';
--	end if;
--end process;	



end architecture;
		
