library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity slaveFIFO2b_streamIN is
	port(
		reset_n                   : in std_logic;
                clk_100                   : in std_logic;
                stream_in_mode_selected   : in std_logic;
                flaga_d                   : in std_logic;
                flagb_d                   : in std_logic;
                slwr_streamIN_n           : out std_logic;
                data_out_stream_in        : out std_logic_vector(31 downto 0)
	    );
end entity slaveFIFO2b_streamIN;

architecture slaveFIFO2b_streamIN_arch of slaveFIFO2b_streamIN is

--stream IN fsm
type streamIN_states is (stream_in_idle, stream_in_wait_flagb, stream_in_write, stream_in_write_wr_delay);
signal current_stream_in_state, next_stream_in_state : streamIN_states;

signal data_gen_stream_in   : std_logic_vector(31 downto 0);
signal slwr_streamIN      : std_logic;

begin --architecture begining

process(current_stream_in_state, flagb_d)begin
	if((current_stream_in_state = stream_in_write) and (flagb_d = '1'))then
		slwr_streamIN <= '0';
	else
		slwr_streamIN <= '1';
	end if;
end process;	

slwr_streamIN_n <= slwr_streamIN;

--streamIN mode state machine
stream_in_fsm_f : process(clk_100, reset_n)begin
	if(reset_n = '0')then 
		current_stream_in_state <= stream_in_idle;
	elsif(clk_100'event and clk_100 = '1')then 
		current_stream_in_state <= next_stream_in_state;
	end if;	
end process;

--StreamIN mode state machine combo
stream_in_fsm : process(current_stream_in_state, stream_in_mode_selected, flaga_d, flagb_d)begin
	next_stream_in_state <= current_stream_in_state;
	case current_stream_in_state is
	when stream_in_idle =>
		if((stream_in_mode_selected ='1') and (flaga_d = '1'))then
			next_stream_in_state <= stream_in_wait_flagb; 
		else 
			next_stream_in_state <= stream_in_idle;
		end if;	
	
	when stream_in_wait_flagb =>
		if (flagb_d = '1')then
			next_stream_in_state <= stream_in_write; 
		else 
			next_stream_in_state <= stream_in_wait_flagb; 
		end if;
	
	when stream_in_write =>
		if(flagb_d = '0')then
			next_stream_in_state <= stream_in_write_wr_delay;
		else
		 	next_stream_in_state <= stream_in_write;
		end if;
	
        when stream_in_write_wr_delay =>
		next_stream_in_state <= stream_in_idle;
	when others =>
		next_stream_in_state <= stream_in_idle;
		
	end case;
end process;

--data generator counter for Partial mode
process(clk_100, reset_n)begin
	if(reset_n = '0')then
		data_gen_stream_in <= (others => '0');
	elsif(clk_100'event and clk_100 = '1')then
		if((slwr_streamIN = '0') and (stream_in_mode_selected = '1'))then
			data_gen_stream_in <= data_gen_stream_in + '1';
		elsif(stream_in_mode_selected = '0')then
			data_gen_stream_in <= (others => '0');
		end if;	
	end if;	
end process;

data_out_stream_in <= data_gen_stream_in;

end architecture;

