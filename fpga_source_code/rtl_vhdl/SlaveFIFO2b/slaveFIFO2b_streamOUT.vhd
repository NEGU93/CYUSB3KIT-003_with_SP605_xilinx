library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity slaveFIFO2b_streamOUT is
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
end entity slaveFIFO2b_streamOUT;

architecture slaveFIFO2b_streamOUT_arch of slaveFIFO2b_streamOUT is

--stream OUT fsm
type streamOUT_states is (stream_out_idle, stream_out_flagc_rcvd, stream_out_wait_flagd, stream_out_read, stream_out_read_rd_and_oe_delay, stream_out_read_oe_delay);
signal current_stream_out_state, next_stream_out_state : streamOUT_states;

signal rd_oe_delay_cnt     : std_logic_vector(1 downto 0);
signal oe_delay_cnt        : std_logic_vector(1 downto 0);

begin  -- architecture begin

--OUTPUT read control signals generation
process(current_stream_out_state)begin
	if((current_stream_out_state = stream_out_read) or (current_stream_out_state = stream_out_read_rd_and_oe_delay))then
		slrd_streamOUT_n <= '0';
	else
		slrd_streamOUT_n <= '1';
	end if;	
end process;	


--OUTPUT read oe control signals generation
process(current_stream_out_state)begin
	if((current_stream_out_state = stream_out_read) or (current_stream_out_state = stream_out_read_rd_and_oe_delay) or (current_stream_out_state = stream_out_read_oe_delay)) then
		sloe_streamOUT_n <= '0';
	else
	 	sloe_streamOUT_n <= '1';
	end if;
end process;


--counter to delay the read and output enable signal
process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		rd_oe_delay_cnt <= "00";
	elsif(clk_100'event and clk_100 = '1')then	
	 	if(current_stream_out_state = stream_out_read) then
			rd_oe_delay_cnt <= "01";
        	elsif((current_stream_out_state = stream_out_read_rd_and_oe_delay) and (rd_oe_delay_cnt > 0))then
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
	 	if(current_stream_out_state = stream_out_read_rd_and_oe_delay) then
			oe_delay_cnt <= "10";
        	elsif((current_stream_out_state = stream_out_read_oe_delay) and (oe_delay_cnt > 0))then
			oe_delay_cnt <= oe_delay_cnt - 1;
		else
			oe_delay_cnt <= oe_delay_cnt;
		end if;
	end if;
end process;


--streamOUT mode state machine
stream_out_fsm_f : process(clk_100, reset_n)begin
	if(reset_n = '0')then
		current_stream_out_state <= stream_out_idle;
	elsif(clk_100'event and clk_100 = '1')then 
		current_stream_out_state <= next_stream_out_state;
	end if;	
end process;

--steamOUT mode state machine combo
stream_out_fsm : process(current_stream_out_state, stream_out_mode_selected, flagc_d, flagd_d, rd_oe_delay_cnt, oe_delay_cnt)begin
	next_stream_out_state <= current_stream_out_state;
	case current_stream_out_state is
	when stream_out_idle =>
		if((stream_out_mode_selected = '1') and (flagc_d = '1'))then
			next_stream_out_state <= stream_out_flagc_rcvd;
		else 
			next_stream_out_state <= stream_out_idle;
		end if;
		
        when stream_out_flagc_rcvd =>
		next_stream_out_state <= stream_out_wait_flagd;
	
	when stream_out_wait_flagd =>
		if(flagd_d = '1')then
			next_stream_out_state <= stream_out_read;
		else
			next_stream_out_state <= stream_out_wait_flagd;
		end if;
		
        when stream_out_read =>
		if(flagd_d = '0')then
			next_stream_out_state <= stream_out_read_rd_and_oe_delay;
		else
			next_stream_out_state <= stream_out_read;
		end if;
	
	when stream_out_read_rd_and_oe_delay =>
		if(rd_oe_delay_cnt = "00")then
			next_stream_out_state <= stream_out_read_oe_delay;
		else
			next_stream_out_state <= stream_out_read_rd_and_oe_delay;
		end if;
	
        when stream_out_read_oe_delay =>
		if(oe_delay_cnt = "00")then
			next_stream_out_state <= stream_out_idle;
		else
			next_stream_out_state <= stream_out_read_oe_delay;
		end if;
	when others =>
		next_stream_out_state <= stream_out_idle;
		
	end case;
end process;

end architecture;

