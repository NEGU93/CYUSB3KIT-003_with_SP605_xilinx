
module tb_clock_typ_inverted(tb_status, CLK, offset_bits, period_bits, duty_bits, minLH_bits, maxLH_bits, minHL_bits, maxHL_bits, jRise_bits, jFall_bits);
  parameter initialize = 0;

  input [1:0] tb_status;
  output CLK;
  input [63:0] offset_bits;
  input [63:0] period_bits;
  input [63:0] duty_bits;
  input [63:0] minLH_bits;
  input [63:0] maxLH_bits;
  input [63:0] minHL_bits;
  input [63:0] maxHL_bits;
  input [63:0] jRise_bits;
  input [63:0] jFall_bits;

  reg  CLK;
  real offset;
  real period;
  real duty;
  real minLH;
  real maxLH;
  real minHL;
  real maxHL;
  real jRise;
  real jFall;
  real CLK_high;
  real CLK_low;
 
  always
    begin
    @(posedge tb_status[0])
    offset = $bitstoreal( offset_bits );
    period = $bitstoreal( period_bits );
    duty  = $bitstoreal( duty_bits );
    minLH = $bitstoreal( minLH_bits );
    maxLH = $bitstoreal( maxLH_bits );
    minHL = $bitstoreal( minHL_bits );
    maxHL = $bitstoreal( maxHL_bits );
    jRise = $bitstoreal( jRise_bits );
    jFall = $bitstoreal( jFall_bits );
    if (period <= 0.0)
      $display("Error: Period for clock %m is invalid (period=%f).  Clock will not be driven", period);
    else if (duty <= 0.0)
      $display("Error: Duty for clock %m is invalid (duty=%f).  Clock will not be driven", duty);
    else
      begin
      CLK_low = period * duty / 100;
      CLK_high = period - CLK_low;
      
      if ( (offset + (maxHL + minHL)/2) >= 0.0 )
        begin
        if (initialize)
          CLK <= 1'b1; // drive initial state
        #(offset + (maxHL + minHL)/2)
        ;
        end
      else
        begin 
        if (initialize)
          CLK <= 1'b0; // in middle of 0 region, init to 0
        // #(clk_low + offset) reduced
        #(CLK_low + (maxLH + minLH)/2 + offset)   
        CLK <= 1'b1;
        #((CLK_high - ((maxLH + minLH)/2) + ((maxHL + minHL)/2)))
        ;
       end
  
      while ( tb_status[0] == 1'b1 )
        begin : clock_loop
        CLK <= 1'b0;
        #((CLK_low - ((maxHL + minHL)/2) + ((maxLH + minLH)/2)))
        CLK <= 1'b1;
        #((CLK_high - ((maxLH + minLH)/2) + ((maxHL + minHL)/2)))
        ;
        end
      end
    end
endmodule

