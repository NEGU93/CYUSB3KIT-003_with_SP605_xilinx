library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity slaveFIFO2b_partial is
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
end entity slaveFIFO2b_partial;

architecture slaveFIFO2b_partial_arch of slaveFIFO2b_partial is

--partial fsm
type partial_states is (partial_idle, partial_wait_flagb, partial_write, partial_write_wr_delay, partial_wait);
signal current_partial_state, next_partial_state : partial_states;

signal short_pkt_cnt                  : std_logic_vector(3 downto 0);
signal strob_cnt                      : std_logic_vector(3 downto 0);
signal strob			      : std_logic;
signal data_gen_partial               : std_logic_vector(31 downto 0);
signal slwr_partial		      : std_logic;
signal pktend_prtl_n		      : std_logic;

begin -- architecture begining

process(current_partial_state, flagb_d)begin
	if((current_partial_state = partial_write) and (flagb_d = '1'))then
		slwr_partial <= '0';
	else
		slwr_partial <= '1';
	end if;
end process;	

slwr_partial_n <= slwr_partial;
--counters for short pkt
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		short_pkt_cnt <= "0000";
	elsif(clk_100'event and clk_100 = '1')then	
		if(current_partial_state = partial_idle)then
			short_pkt_cnt <= "0000";
		elsif((current_partial_state = partial_write))then
			short_pkt_cnt <= short_pkt_cnt + 1;
		else 
		 	short_pkt_cnt <= short_pkt_cnt;
	        end if;	
        end if;
end process;	

--counter to generate the strob for PARTIAL and ZLP data pkts
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		strob_cnt <= "0000";
	elsif(clk_100'event and clk_100 = '1')then	
		if(current_partial_state = partial_idle)then
			strob_cnt<= "0000";
		elsif(current_partial_state = partial_wait)then
			strob_cnt <= strob_cnt + 1;
		else 
		 	strob_cnt <= strob_cnt;
	        end if;	
        end if;
end process;

--Strob logic
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		strob <= '0';
	elsif(clk_100'event and clk_100 = '1')then	
		if((current_partial_state = partial_wait) and (strob_cnt = "0111"))then
			strob <= not strob;
		else
		        strob <= strob;
	        end if;
	end if;	
end process;

--OUTPUT packetend generation logic 
process(partial_mode_selected, strob, short_pkt_cnt)begin
	if((partial_mode_selected = '1') and (strob = '1') and (short_pkt_cnt = "1111"))then
		pktend_prtl_n <= '0';
	--elsif((current_fpga_master_mode = fpga_master_mode_zlp) and (strob_cnt = "0011") and (strob = '1'))then
	--	pktend_prtl_n <= '0';
	else
		pktend_prtl_n <= '1';
	end if;
end process;	

pktend_partial_n <= pktend_prtl_n;


--partial mode fsm
partial_mode_fsm_f : process(clk_100, reset_n) begin
	if(reset_n = '0')then
      		current_partial_state <= partial_idle;
        elsif(clk_100'event and clk_100 = '1')then
                current_partial_state <= next_partial_state;
        end if;
end process;

--PARTIAL mode state machine combo
partial_mode_fsm : process(current_partial_state, partial_mode_selected, flaga_d, flagb_d, strob_cnt, strob, short_pkt_cnt)begin
	next_partial_state <= current_partial_state;
	case current_partial_state is
	when partial_idle =>
		if((partial_mode_selected = '1') and (flaga_d = '1'))then
			next_partial_state <= partial_wait_flagb; 
	  	else 
			next_partial_state <= partial_idle;
		end if;	
		
	when partial_wait_flagb =>
		if (flagb_d = '1')then
			next_partial_state <= partial_write; 
		else 
			next_partial_state <= partial_wait_flagb; 
		end if;

	when partial_write =>
		if((flagb_d = '0') or ((strob = '1') and (short_pkt_cnt = "1111")))then
			next_partial_state <= partial_write_wr_delay;
		else 
	 		next_partial_state <= partial_write;
		end if;	
	
	when partial_write_wr_delay =>
		next_partial_state <= partial_wait;
	
	when partial_wait =>
		if(strob_cnt = "0111")then
			next_partial_state <= partial_idle;
		else 
			next_partial_state <= partial_wait;
		end if;

	when others =>
		next_partial_state <= partial_idle;
	
	end case;
end process;




--data generator counter for Partial mode
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		data_gen_partial <= (others => '0');
	elsif(clk_100'event and clk_100 = '1')then
		if((slwr_partial = '0') and (partial_mode_selected = '1'))then
			data_gen_partial <= data_gen_partial + '1';
		elsif(partial_mode_selected = '0')then
			data_gen_partial <= (others => '0');
		end if;	
	end if;	
end process;

data_out_partial <= data_gen_partial;

end architecture;
