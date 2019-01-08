library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity slaveFIFO2b_ZLP is
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
end entity slaveFIFO2b_ZLP;

architecture slaveFIFO2b_ZLP_arch of slaveFIFO2b_ZLP is
--ZLP fsm
type zlp_states is (zlp_idle, zlp_wait_flagb, zlp_write, zlp_write_wr_delay, zlp_wait);
signal current_zlp_state, next_zlp_state : zlp_states;

signal strob_cnt      : std_logic_vector(3 downto 0);
signal strob	      : std_logic;
signal data_gen_zlp   : std_logic_vector(31 downto 0);
signal pktend_zlpkt_n : std_logic;
signal slwr_zlp : std_logic;

begin --architecture begining

process(current_zlp_state, flagb_d)begin
	if((current_zlp_state = zlp_write) and (flagb_d = '1'))then
		slwr_zlp <= '0';
	else
		slwr_zlp <= '1';
	end if;
end process;

slwr_zlp_n <= slwr_zlp; 

--counter to generate the strob for PARTIAL and ZLP data pkts
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		strob_cnt <= "0000";
	elsif(clk_100'event and clk_100 = '1')then	
		if(current_zlp_state = zlp_idle)then
			strob_cnt<= "0000";
		elsif(current_zlp_state = zlp_wait)then
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
		if((current_zlp_state = zlp_wait) and (strob_cnt = "0111"))then
			strob <= not strob;
		else
		        strob <= strob;
	        end if;
	end if;	
end process;

--OUTPUT packetend generation logic 
process(zlp_mode_selected, strob, strob_cnt)begin
	if((zlp_mode_selected = '1') and (strob_cnt = "0011") and (strob = '1'))then
		pktend_zlpkt_n <= '0';
	else
		pktend_zlpkt_n <= '1';
	end if;
end process;	

pktend_zlp_n <= pktend_zlpkt_n;


-- ZLP mode fsm
zlp_mode_fsm_f : process(clk_100,reset_n)begin
	if(reset_n = '0')then 
		current_zlp_state <= zlp_idle;
	elsif (clk_100'event and clk_100 = '1')then
		current_zlp_state <= next_zlp_state;
	end if;	
end process;

--ZLP mode state machine combo
zlp_mode_fsm : process(current_zlp_state, zlp_mode_selected, flaga_d, strob, flagb_d, strob_cnt)begin
	next_zlp_state <= current_zlp_state;
	case current_zlp_state is
	when zlp_idle =>
		if((zlp_mode_selected = '1') and (flaga_d = '1'))then
			next_zlp_state <= zlp_wait_flagb; 
		else
			next_zlp_state <= zlp_idle;
		end if;	
	
	when zlp_wait_flagb =>
		if((strob = '1') and (flagb_d = '1'))then
			next_zlp_state <= zlp_wait;
		elsif ((flagb_d = '1') and (strob = '0'))then
			next_zlp_state <= zlp_write; 
		else 
			next_zlp_state <= zlp_wait_flagb; 
		end if;
	
	when zlp_write =>
		if(flagb_d = '0')then
			next_zlp_state <= zlp_write_wr_delay;
		else
		 	next_zlp_state <= zlp_write;
		end if;
	
        when zlp_write_wr_delay =>
		next_zlp_state <= zlp_wait;
	
	when zlp_wait =>
		if(strob_cnt = "1111")then
			next_zlp_state <= zlp_idle;
		else
			next_zlp_state <= zlp_wait;
		end if;
	when others =>
		next_zlp_state <= zlp_idle;
	end case;
end process;


--data generator counter for ZLP mode
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		data_gen_zlp <= (others => '0');
	elsif(clk_100'event and clk_100 = '1')then
		if((slwr_zlp = '0') and (zlp_mode_selected = '1'))then
			data_gen_zlp <= data_gen_zlp + '1';
		elsif(zlp_mode_selected = '0')then
			data_gen_zlp <= (others => '0');
		end if;	
	end if;	
end process;

data_out_zlp <= data_gen_zlp;

end architecture;
