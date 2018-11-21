library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fifo is
	port(
		din		: in std_logic_vector(31 downto 0);
                write_busy	: in std_logic;
                fifo_full	: out std_logic;
                dout		: out std_logic_vector(31 downto 0);
                read_busy 	: in std_logic;
                fifo_empty	: out std_logic;
                fifo_clk	: in std_logic;
                reset_al		: in std_logic; 
                fifo_flush	: in std_logic
	    );
end entity fifo;	    

architecture fifo_arch of fifo is

signal write_occupancy       : std_logic_vector(8 downto 0);
signal read_occupancy        : std_logic_vector(8 downto 0);
signal next_write_occupancy  : std_logic_vector(8 downto 0);
signal next_read_occupancy   : std_logic_vector(8 downto 0);
signal next_write_ptr        : std_logic_vector(7 downto 0);
signal write_ptr             : std_logic_vector(7 downto 0);
signal next_read_ptr         : std_logic_vector(7 downto 0);
signal read_ptr              : std_logic_vector(7 downto 0);
signal read_index            : std_logic_vector(7 downto 0);
signal dout_next             : std_logic_vector(31 downto 0);
signal write_busy_d          : std_logic;
signal fifo_full_s           : std_logic;
signal fifo_empty_s          : std_logic;
signal read_occ_case_sel     : std_logic_vector(1 downto 0);
signal write_occ_case_sel    : std_logic_vector(1 downto 0);

type memory is array (255 downto 0) of std_logic_vector(31 downto 0);

signal data_array : memory;


begin -- arch begin


process(fifo_clk, reset_al) begin
	if (reset_al = '0') then
		write_ptr <= "00000000";
	elsif(fifo_clk'event and fifo_clk = '1') then 
		write_ptr <= next_write_ptr;
	end if; 
end process;

--Calculate next write pointer value
process (fifo_flush, write_busy, write_ptr, fifo_full_s) begin
	if(fifo_flush = '1')then
		next_write_ptr <= "00000000";
	else
		next_write_ptr <= (write_ptr + (write_busy and (not fifo_full_s)));
	end if;
end process;	


process(fifo_clk, reset_al) begin
	if (reset_al = '0') then 
       		read_ptr <= "00000000";
  	elsif(fifo_clk'event and fifo_clk = '1') then
		read_ptr <= next_read_ptr;
	end if;	
end process;

--Calculate next read pointer value

process (fifo_flush, read_busy, read_ptr, fifo_empty_s) begin
	if(fifo_flush = '1')then
		next_read_ptr <= "00000000";
	else
		next_read_ptr <= (read_ptr + (read_busy and (not fifo_empty_s)));
	end if;
end process;

--Read correct memory location
process (read_busy, read_ptr, next_read_ptr) begin
	if(read_busy = '1')then
		read_index <= next_read_ptr;
	else
		read_index <=  read_ptr;
	end if;
end process;

--Write data into memory
process(fifo_clk)begin
	if(fifo_clk'event and fifo_clk = '1')then
		if (write_busy = '1')then
			data_array(conv_integer(write_ptr)) <= din;
		end if;
	end if;
end process;	


-- read memory data 
process(fifo_clk) begin
	if(fifo_clk'event and fifo_clk = '1')then
		dout <= dout_next; 
	end if;	
end process;

dout_next <= data_array(conv_integer(read_index(7 downto 0)));

process(fifo_clk, reset_al) begin
	if (reset_al  = '0') then
		write_occupancy <= "000000000";
	elsif(fifo_clk'event and fifo_clk = '1')then  
		write_occupancy <= next_write_occupancy;
	end if;
end process;

process(fifo_clk, reset_al) begin
	if (reset_al  = '0')then
		read_occupancy <= "000000000";
	elsif(fifo_clk'event and fifo_clk = '1')then  
		read_occupancy <= next_read_occupancy;
	end if;
end process;


process(fifo_clk, reset_al) begin
        if(reset_al = '0') then 
                write_busy_d <= '0';
        elsif(fifo_clk'event and fifo_clk = '1')then    
                write_busy_d <= write_busy;
        end if;
end process;

read_occ_case_sel  <= write_busy_d & read_busy;
write_occ_case_sel <= write_busy & read_busy;

process(fifo_flush, read_occ_case_sel, read_occupancy) begin
	if (fifo_flush = '1') then 
		next_read_occupancy <= "000000000"; 
	else  
		case read_occ_case_sel is
			when "00" => next_read_occupancy <= read_occupancy;
			when "01" => next_read_occupancy <= read_occupancy - '1';
			when "10" => next_read_occupancy <= read_occupancy + '1';
			when "11" => next_read_occupancy <= read_occupancy;
			when others =>   next_read_occupancy <= read_occupancy;
		end case;	
	end if;
end process;

process(fifo_flush, write_occ_case_sel, write_occupancy) begin
	if (fifo_flush = '1') then 
		next_write_occupancy <= "000000000"; 
	else  
		case write_occ_case_sel is
			when "00" => next_write_occupancy <= write_occupancy;
			when "01" => next_write_occupancy <= write_occupancy - '1';
			when "10" => next_write_occupancy <= write_occupancy + '1';
			when "11" => next_write_occupancy <= write_occupancy;
			when others =>   next_write_occupancy <= write_occupancy;
		end case;	
	end if;
end process;


process(fifo_clk, reset_al) begin
	if (reset_al = '0')then
		fifo_full_s <= '0';
	elsif(fifo_clk'event and fifo_clk = '1')then 
		 if (next_write_occupancy = "100000000")then
			fifo_full_s <= '1';
		else 
			fifo_full_s <= '0'; 
		end if;
	end if;	
end process;


fifo_full <= fifo_full_s;

process(fifo_clk, reset_al) begin
		if (reset_al = '0')then
			fifo_empty_s <= '1';
		elsif(fifo_clk'event and fifo_clk = '1')then	
			 if (next_read_occupancy = "000000000")then
				fifo_empty_s <= '1';
			 else
				fifo_empty_s <= '0';
			end if;
		end if;	
end process;

fifo_empty <= fifo_empty_s;

end architecture fifo_arch;

