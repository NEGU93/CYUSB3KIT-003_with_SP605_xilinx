
module tb_divider_clock(tb_status, 
                        referenceCLK, 
                        CLK, 
                        pulseOffset, 
                        pulseWidth,
                        divisor, 
                        delay1_bits, 
                        delay2_bits,
                        state1,
                        state2);
  parameter initialize = 0;
  parameter initialReferenceClkState = 1;
  
  input [1:0] tb_status;
  input referenceCLK;
  output CLK;
  input [31:0] pulseOffset;
  input [31:0] pulseWidth;
  input [31:0] divisor;
  input [63:0] delay1_bits;
  input [63:0] delay2_bits;
  input state1;
  input state2;
  
  reg CLK;
  integer tb_EdgeCount;

  real delay1;
  real delay2;
  
  integer secondPulseWidth;
 
  always
    begin : CLK_process
    @(posedge tb_status[0])
    delay1 = $bitstoreal( delay1_bits );
    delay2 = $bitstoreal( delay2_bits );
    secondPulseWidth = (divisor*2 - pulseWidth);
    
    if (divisor < 1)
      begin
      $display("Error: Divisor for clock %m is invalid (divisor=%d).  Clock will not be driven", divisor);
      end

    // drive initial value
    CLK <= state2;
    
    // wait for reference clock to start
    while(referenceCLK !== initialReferenceClkState)
      @(referenceCLK);
      
    // wait for pulse offset
    tb_EdgeCount = 0;
    while(tb_EdgeCount < pulseOffset)
      begin
      @(referenceCLK);
      if (referenceCLK !== 1'bx)
        tb_EdgeCount = tb_EdgeCount + 1;
      end
            
    while(tb_status[0] === 1'b1)
      begin
      // drive the first half of the cycle
      if (delay1 > 0)
        CLK <= #(delay1) state1;
      else
        CLK <= state1;

      tb_EdgeCount = 0;
      while(tb_EdgeCount < pulseWidth)
        begin
        @(referenceCLK);
        if (referenceCLK !== 1'bx)
          tb_EdgeCount = tb_EdgeCount + 1;
        end

      // drive the second half of the cycle
      if (delay2 > 0)
        CLK <= #(delay2) state2;
      else
        CLK <= state2;
        
      tb_EdgeCount = 0;
     
      while(tb_EdgeCount < secondPulseWidth)
        begin
        @(referenceCLK);
        if (referenceCLK !== 1'bx)
          tb_EdgeCount = tb_EdgeCount + 1;
        end
      end
    end
endmodule

