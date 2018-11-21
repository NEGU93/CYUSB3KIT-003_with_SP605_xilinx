
module tb_divider_clock_minmax(tb_status, 
                               referenceCLK, 
                               CLK, 
                               pulseOffset, 
                               pulseWidth,
                               divisor, 
                               mindelay1_bits, 
                               maxdelay1_bits, 
                               mindelay2_bits, 
                               maxdelay2_bits,
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
  input [63:0] mindelay1_bits;
  input [63:0] maxdelay1_bits;
  input [63:0] mindelay2_bits;
  input [63:0] maxdelay2_bits;
  input state1;
  input state2;
  
  reg CLK;
  integer tb_EdgeCount;

  real mindelay1;
  real maxdelay1;
  real mindelay2;
  real maxdelay2;
  
  integer secondPulseWidth;
 
  always
    begin : CLK_process
    @(posedge tb_status[0])
    mindelay1 = $bitstoreal( mindelay1_bits );
    maxdelay1 = $bitstoreal( maxdelay1_bits );
    mindelay2 = $bitstoreal( mindelay2_bits );
    maxdelay2 = $bitstoreal( maxdelay2_bits );
    secondPulseWidth = (divisor*2 - pulseWidth);
    
    if (divisor < 1)
      begin
      $display("Error: Divisor for clock %m is invalid (divisor=%d).  Clock will not be driven", divisor);
      end

    // drive initial value
    CLK <= state2;
    
    // wait for reference clock to start
    while(referenceCLK !== initialReferenceClkState)
      begin
      @(referenceCLK);
      if (referenceCLK === 1'bx)
        begin
        if (pulseOffset == 0)
          begin
          if (mindelay1 > 0)
            CLK <= #(mindelay1) 1'bx;
          else
            CLK <= 1'bx;
          end
        end
      end
      
    // wait for pulse offset
    tb_EdgeCount = 0;
    while(tb_EdgeCount < pulseOffset)
      begin
      @(referenceCLK);
      if (referenceCLK !== 1'bx)
        tb_EdgeCount = tb_EdgeCount + 1;
      else if (tb_EdgeCount == (pulseOffset - 1))
        begin
        if (mindelay1 > 0)
          CLK <= #(mindelay1) 1'bx;
        else
          CLK <= 1'bx;
        end
      end
            
    while(tb_status[0] === 1'b1)
      begin
      // drive the first half of the cycle
      // if there is no delay, then just perform assignment
      if (mindelay1 == 0 && maxdelay1 == 0)
        CLK <= state1;
      else if (mindelay1 == 0 || maxdelay1 == 0 || (mindelay1 == maxdelay1))
        begin // if the delays are the same or one of them is zero, 
              // then we just have to delay by one of them
        if (mindelay1 == 0)
          CLK <= #(maxdelay1) state1;
        else
          CLK <= #(mindelay1) state1;
        end
      else // both delays are non-zero AND different from each other (model X region)
        begin
        CLK <= #(mindelay1) 1'bx;
        CLK <= #(maxdelay1) state1;
        end

      tb_EdgeCount = 0;
      while(tb_EdgeCount < pulseWidth)
        begin
        @(referenceCLK);
        if (referenceCLK !== 1'bx)
          tb_EdgeCount = tb_EdgeCount + 1;
        else if (tb_EdgeCount == (pulseWidth - 1))
          begin
          if (mindelay2 > 0)
            CLK <= #(mindelay2) 1'bx;
          else
            CLK <= 1'bx;
          end
        end

      // drive the second half of the cycle
      // if there is no delay, then just perform assignment
      if (mindelay2 == 0 && maxdelay2 == 0)
        CLK <= state2;
      else if (mindelay2 == 0 || maxdelay2 == 0 || (mindelay2 == maxdelay2))
        begin // if the delays are the same or one of them is zero, 
              // then we just have to delay by one of them
        if (mindelay2 == 0)
          CLK <= #(maxdelay2) state2;
        else
          CLK <= #(mindelay2) state2;
        end
      else // both delays are non-zero AND different from each other (model X region)
        begin
        CLK <= #(mindelay2) 1'bx;
        CLK <= #(maxdelay2) state2;
        end
        
      tb_EdgeCount = 0;
     
      while(tb_EdgeCount < secondPulseWidth)
        begin
        @(referenceCLK);
        if (referenceCLK !== 1'bx)
          tb_EdgeCount = tb_EdgeCount + 1;
        else if (tb_EdgeCount == (secondPulseWidth - 1))
          begin
          if (mindelay1 > 0)
            CLK <= #(mindelay1) 1'bx;
          else
            CLK <= 1'bx;
          end
        end
      end
    end
endmodule

