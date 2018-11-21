library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity slaveFIFO2b_loopback is
	port(
		 reset_n                             : in std_logic;
		 clk_100			     : in std_logic;
                 loopback_mode_selected              : in std_logic;
                 flaga_d                             : in std_logic;
                 flagb_d                             : in std_logic;
                 flagc_d                             : in std_logic;
                 flagd_d                             : in std_logic;
                 data_in_loopback                    : in std_logic_vector(31 downto 0);
                 slrd_loopback_n                      : out std_logic;
                 sloe_loopback_n                      : out std_logic;
                 slwr_loopback_n                      : out std_logic;
                 loopback_rd_select_slavefifo_addr   : out std_logic;
		 data_out_loopback                   : out std_logic_vector(31 downto 0)
	    );
end entity slaveFIFO2b_loopback;

architecture slaveFIFO2b_loopback_arch of slaveFIFO2b_loopback is

--component fifo for LoopBack
component fifo
	  port(
	       din           : in std_logic_vector(31 downto 0);
  	       write_busy    : in std_logic;
               fifo_full     : out std_logic;
               dout	     : out std_logic_vector(31 downto 0);
               read_busy     : in std_logic;
               fifo_empty    : out std_logic;
               fifo_clk      : in std_logic;
               reset_al	     : in std_logic;
               fifo_flush    : in std_logic
	      );
end component;	 


--loopback fsm
type loop_back_states is (loop_back_idle, loop_back_flagc_rcvd, loop_back_wait_flagd, loop_back_read, loop_back_read_rd_and_oe_delay, loop_back_read_oe_delay, loop_back_wait_flaga, loop_back_wait_flagb, loop_back_write, loop_back_write_wr_delay, loop_back_flush_fifo);
signal current_loop_back_state, next_loop_back_state : loop_back_states; 

-------------------------------
---signals
------------------------------

signal fifo_data_in        : std_logic_vector(31 downto 0);

signal slrd_loopback        : std_logic;
signal slrd_looback_d1_n   : std_logic;
signal slrd_looback_d2_n   : std_logic; 
signal slrd_looback_d3_n   : std_logic;
signal slrd_looback_d4_n   : std_logic;

signal fifo_push	   : std_logic; 
signal fifo_pop  	   : std_logic;
signal fifo_flush	   : std_logic;
signal fifo_full	   : std_logic;
signal fifo_empty	   : std_logic;

--internal counter signals to delay
signal rd_oe_delay_cnt     : std_logic_vector(1 downto 0);
signal oe_delay_cnt        : std_logic_vector(1 downto 0);

begin  -- architecture begin


--fifo instantiation for LoopBack mode
fifo_inst : fifo
	port map (
		   din       	=> fifo_data_in,	
                   write_busy   => fifo_push,
                   fifo_full    => fifo_full,
                   dout	        => data_out_loopback,
                   read_busy    => fifo_pop,
                   fifo_empty   => fifo_empty,
                   fifo_clk     => clk_100,
                   reset_al	=> reset_n,
                   fifo_flush   => fifo_flush
		 ); 


--OUTPUT read control signals generation
process(current_loop_back_state)begin
	if((current_loop_back_state = loop_back_read) or (current_loop_back_state = loop_back_read_rd_and_oe_delay))then
		slrd_loopback <= '0';
	else
		slrd_loopback <= '1';
	end if;	
end process;	

slrd_loopback_n <= slrd_loopback;
--OUTPUT read oe control signals generation
process(current_loop_back_state)begin
	if((current_loop_back_state = loop_back_read) or (current_loop_back_state = loop_back_read_rd_and_oe_delay) or (current_loop_back_state = loop_back_read_oe_delay)) then
		sloe_loopback_n <= '0';
	else
	 	sloe_loopback_n <= '1';
	end if;
end process;

--OUTPUT write control signals generation
process(current_loop_back_state)begin
	if((current_loop_back_state = loop_back_write))then
		slwr_loopback_n <= '0';
	else
	        slwr_loopback_n <= '1';
	end if;
end process;

	
--delay for reading from slave fifo(data will be available after two clk cycle and one clk cycle in fpga) 
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		slrd_looback_d1_n <= '1';
		slrd_looback_d2_n <= '1';
		slrd_looback_d3_n <= '1';
		slrd_looback_d4_n <= '1';
	elsif(clk_100'event and clk_100 = '1')then
		slrd_looback_d1_n <= slrd_loopback;
		slrd_looback_d2_n <= slrd_looback_d1_n;
		slrd_looback_d3_n <= slrd_looback_d2_n;
		slrd_looback_d4_n <= slrd_looback_d3_n;
	end if;	 
end process;


--Control signal of fifo for LoopBack mode  
process(slrd_looback_d4_n, loopback_mode_selected)begin
	if((slrd_looback_d4_n = '0') and (loopback_mode_selected = '1'))then
		fifo_push <= '1';
	else
	 	fifo_push <= '0';
	end if;
end process;	

process(current_loop_back_state)begin
	if(current_loop_back_state = loop_back_write)then
		fifo_pop <= '1';
	else
		fifo_pop <= '0';
	end if;
end process;

process(current_loop_back_state)begin
	if(current_loop_back_state = loop_back_flush_fifo)then
		fifo_flush <= '1';
	else
		fifo_flush <= '0';
	end if;
end process;

process(slrd_looback_d4_n, data_in_loopback)begin
	if(slrd_looback_d4_n = '0')then
		fifo_data_in <= data_in_loopback;
	else
		fifo_data_in <= (others => '0');
	end if;	
end process;		

process(current_loop_back_state)begin
	if((current_loop_back_state = loop_back_flagc_rcvd) or (current_loop_back_state = loop_back_wait_flagd) or (current_loop_back_state = loop_back_read) or (current_loop_back_state = loop_back_read_rd_and_oe_delay) or (current_loop_back_state = loop_back_read_oe_delay))then
		loopback_rd_select_slavefifo_addr <= '1';
	else
		loopback_rd_select_slavefifo_addr <= '0';
	end if;
end process;	


--counter to delay the read and output enable signal
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		rd_oe_delay_cnt <= "00";
	elsif(clk_100'event and clk_100 = '1')then	
	 	if(current_loop_back_state = loop_back_read) then
			rd_oe_delay_cnt <= "01";
        	elsif((current_loop_back_state = loop_back_read_rd_and_oe_delay) and (rd_oe_delay_cnt > 0))then
			rd_oe_delay_cnt <= rd_oe_delay_cnt - 1;
		else
			rd_oe_delay_cnt <= rd_oe_delay_cnt;
		end if;
	end if;
end process;

--Counter to delay the OUTPUT Enable(oe) signal
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		oe_delay_cnt <= "00";
	elsif(clk_100'event and clk_100 = '1')then	
	 	if(current_loop_back_state = loop_back_read_rd_and_oe_delay) then
			oe_delay_cnt <= "01";
        	elsif((current_loop_back_state = loop_back_read_oe_delay) and (oe_delay_cnt > 0))then
			oe_delay_cnt <= oe_delay_cnt - 1;
		else
			oe_delay_cnt <= oe_delay_cnt;
		end if;
	end if;
end process;


--loopback mode state machine 
loopback_mode_fsm_f : process(clk_100, reset_n) begin
	if(reset_n = '0')then
      		current_loop_back_state <= loop_back_idle;
        elsif(clk_100'event and clk_100 = '1')then
                current_loop_back_state <= next_loop_back_state;
        end if;
end process;

--LoopBack mode state machine combo
loopback_mode_fsm : process(flaga_d , flagb_d, flagc_d, flagd_d, current_loop_back_state, loopback_mode_selected,rd_oe_delay_cnt, oe_delay_cnt) begin
	next_loop_back_state <= current_loop_back_state;
	case current_loop_back_state is
		when loop_back_idle =>
			if((loopback_mode_selected = '1') and (flagc_d = '1'))then
				next_loop_back_state <= loop_back_flagc_rcvd;
			else
				next_loop_back_state <= loop_back_idle;
			end if;

		when loop_back_flagc_rcvd =>
			next_loop_back_state <= loop_back_wait_flagd;

		when loop_back_wait_flagd =>
			if(flagd_d = '1')then
				next_loop_back_state <= loop_back_read;
			else
				next_loop_back_state <= loop_back_wait_flagd;
			end if;

		when loop_back_read => 
			if(flagd_d = '0')then
				next_loop_back_state <= loop_back_read_rd_and_oe_delay;
			else
				next_loop_back_state <= loop_back_read;
			end if;

		when loop_back_read_rd_and_oe_delay =>
			if(rd_oe_delay_cnt = "00")then
				next_loop_back_state <= loop_back_read_oe_delay;
			else
				next_loop_back_state <= loop_back_read_rd_and_oe_delay;
			end if;

		when loop_back_read_oe_delay =>
			if(oe_delay_cnt = "00")then
				next_loop_back_state <= loop_back_wait_flaga;
			else 
				next_loop_back_state <= loop_back_read_oe_delay;
			end if;

		when loop_back_wait_flaga =>
			if(flaga_d = '1')then
				next_loop_back_state <= loop_back_wait_flagb;
			else 
				next_loop_back_state <= loop_back_wait_flaga;
			end if;
		
		when loop_back_wait_flagb =>
			if(flagb_d = '1')then
				next_loop_back_state <= loop_back_write;
			else 
				next_loop_back_state <= loop_back_wait_flagb;
			end if;

		when loop_back_write =>
			if(flagb_d = '0')then
				next_loop_back_state <= loop_back_write_wr_delay;
			else 
		 		next_loop_back_state <= loop_back_write;
			end if;

		when loop_back_write_wr_delay =>
			next_loop_back_state <= loop_back_flush_fifo;

		when loop_back_flush_fifo =>
			next_loop_back_state <= loop_back_idle;
		
		when others =>
			next_loop_back_state <= loop_back_idle;
		end case;
end process;	

end architecture;

