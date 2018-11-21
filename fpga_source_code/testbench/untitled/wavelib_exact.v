// Begin wavelib_exact.v
`ifdef __WAVELIB_V
//wavelib already included
`else

`define __WAVELIB_V

//`include "sram.v"

//*************************************************
// Register, Negative Edge Triggered, Asynchronous Set and Clear
// (first use v5.0)
//************************************************* 
module registerN_Asyn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
    
  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(negedge clock) //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))              //if set is not active then let the output change
        if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))        //if clear is not active then let the output change
           begin
           if (clock === 1'hx)   //if clock didn't transition directly from 1 to 0 (did 1 -> x instead)
             begin
             inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
          undelayedOut = 'hx;    //  begin transitioning to new state
             @(negedge clock) //end of clock transition region
                inClockingRegion = 0;
              end
           if (inputStayedStable)
             undelayedOut <= initialInputState;
      end
  end
    
  //verifies input stability during clocking region
  //stores an x if input changes
//commented out to handle clock divider circuit
//    always @(in)
//    if (inClockingRegion)
//      begin
//      inputStayedStable = 0;
//      undelayedOut = 'hx;
//      end

    
  always @(set)
    begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow==0 && set==1'b1))
      undelayedOut <= {n{1'b1}}; // set output *** Need to use clocktoout times
    end
  
  always @(clear)
    begin
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))   //if set is not active then let clear work
        if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow==0 && clear==1'b1))
          undelayedOut <= {n{1'b0}}; // set output *** uses clocktoout times
    end

  //model min-max clock to output delay with transport delay
  reg [n-1:0] temp1;
  reg [n-1:0] temp2;
  always @(undelayedOut)
    begin
    temp1 <= #($bitstoreal(clock2outMin_bits)) undelayedOut;
    temp2 <= #($bitstoreal(clock2outMax_bits)) undelayedOut;
    end
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule


//*************************************************
// Register, Positive Edge Triggered, Asynchronous Set and Clear
// (first use v5.0)
//************************************************* 
module registerP_Asyn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
 
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(posedge clock) //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))              //if set is not active then let the output change
        if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))        //if clear is not active then let the output change
          begin
          if (clock === 1'hx)   //if clock didn't transition directly from 0 to 1 (did 0 -> x instead)
            begin
            inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
            if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
              undelayedOut = 'hx;    //  begin transitioning to new state
            @(posedge clock) //end of clock transition region
              inClockingRegion = 0;
            end
          if (inputStayedStable)
            undelayedOut <= initialInputState;
          end
    else if (clockEnable === 1'bx)
    undelayedOut <= 'bx;
  end
    
  //verifies input stability during clocking region
  //stores an x if input changes
//  always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end

  always @(set)
  begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow==0 && set==1'b1))
      undelayedOut <= {n{1'b1}}; // set output *** uses clocktoout times
  end

  always @(clear)
  begin
    if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))       //if set is not active then let clear work
      if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow==0 && clear==1'b1))
        undelayedOut <= {n{1'b0}}; // set output *** uses clocktoout times
  end

  reg [n-1:0] temp1;
  reg [n-1:0] temp2;
  always @(undelayedOut)
  begin
    temp1 <= #($bitstoreal(clock2outMin_bits)) undelayedOut;
    temp2 <= #($bitstoreal(clock2outMax_bits)) undelayedOut;
  end

//  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
//  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

//*************************************************
// Register, Both Edge Triggered, Asynchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module registerB_Asyn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(clock)   //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))              //if set is not active then let the output change
        if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))        //if clear is not active then let the output change
          begin
          if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
            begin
            inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
            if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
              undelayedOut = 'hx;    //  begin transitioning to new state
            @(clock) //end of clock transition region
              inClockingRegion = 0;
            end
          if (inputStayedStable)
            undelayedOut <= initialInputState;
     end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//  always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end

  always @(set)
    begin
      if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow==0 && set==1'b1))
  undelayedOut <= {n{1'b1}}; // set output *** uses clocktoout times
    end
  
  always @(clear)
    begin
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))          //if set is not active then let clear work
  if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow==0 && clear==1'b1))
    undelayedOut <= {n{1'b0}};                                                      // set output *** uses clocktoout times
    end

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

//*************************************************
// Register, Negative Edge Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module registerN_Syn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(negedge clock) //start of clock transition region
  begin
  initialInputState = enabled_in;
  inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      begin
      if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
        begin
        inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
            begin
            if ( sc_activeLow == 1)
              begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
              2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
          end
            else
              begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
              end
            end   
        @(clock) //end of clock transition region
          inClockingRegion = 0;
        end
      if (inputStayedStable)
        begin
          if ( sc_activeLow == 1)
            begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end
          else
            begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end   
        end
        //else if clockEnable is not active then do nothing
      end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//    always @(in)
//      if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end
    
  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

//*************************************************
// Register, Positive Edge Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module registerP_Syn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(posedge clock) //start of clock transition region
  begin
    initialInputState = in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      begin
      if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
        begin
        inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== in)  //if flip-flop is changing state
            begin
            if ( sc_activeLow == 1)
              begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
              2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
          end
            else
              begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
              end
            end   
        @(posedge clock) //end of clock transition region
        inClockingRegion = 0;
        end
      if (inputStayedStable)
        begin
          if ( sc_activeLow == 1)
            begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end
          else
            begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end   
          end
        //else if clockEnable is not active then do nothing
      end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//      always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end
    
  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

//*************************************************
// Register, Both Edge Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module registerB_Syn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
  
  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(clock)  //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      begin
      if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
        begin
        inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== in)  //if flip-flop is changing state, 
            begin
            if ( sc_activeLow == 1)
              begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
              2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
          end
            else
              begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
              end
            end   
        @(clock) //end of clock transition region
          inClockingRegion = 0;
        end
      if (inputStayedStable)
        begin
          if ( sc_activeLow == 1)
            begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end
          else
            begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end   
          end
        //else if clockEnable is not active then do nothing
      end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//  always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end
//    
  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

//*************************************************
// Latch, Low Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module latchL_Syn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or negedge clock or set or clear)
    begin
    //if clock is active and enabled Let output change
    if ((clock == 1'b0) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))      )
      begin
        if ( sc_activeLow == 1)
          begin
          case ({set, clear})                      //SC are active low
            2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
            2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
            2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
            2'b11: begin undelayedOut <= enabled_in; end    //Q = D 
            endcase
          end
        else
          begin      
          case ({set, clear})                      //SC are active High
            2'b11: begin undelayedOut <= { n{1'b1} }; end  //Set output   
            2'b10: begin undelayedOut <= { n{1'b1} }; end  //Set output   
            2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
            2'b00: begin undelayedOut <= enabled_in; end    //Q = D 
            endcase
          end   //if active low or high
        end //if clock active
      end  //always

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;

endmodule

//*************************************************
// Latch, High Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 

module latchH_Syn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end
  
  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;

  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or posedge clock or set or clear)
    begin
    //if clock is active and enabled Let output change
    if ((clock == 1'b1) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))      )
      begin
      if ( sc_activeLow == 1)
        begin
          case ({set, clear})                      //SC are active low
            2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
            2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
            2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
            2'b11: begin undelayedOut <= enabled_in; end    //Q = D 
          endcase
        end
      else
        begin      
          case ({set, clear})                      //SC are active High
            2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
            2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
            2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
            2'b00: begin undelayedOut <= enabled_in; end    //Q = D 
          endcase
        end   //if active low or high
      end //if clock active
    end //always

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;

endmodule

//*************************************************
// Latch, Low Triggered, Asynchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module latchL_Asyn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end
  
  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;

  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or negedge clock or set or clear)
    begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow == 0 && set==1'b1))
      undelayedOut <= {n{1'b1}}; // set output *** uses clocktoout times
    else if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow == 0 && clear==1'b1))
      undelayedOut <= {n{1'b0}}; // set output *** uses clocktoout times
    else if ((clock == 1'b0) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))) //if clock is active and enabled Let output change
      undelayedOut <= enabled_in;    //Q = D
    end

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;

endmodule

//*************************************************
// Latch, High Triggered, Asynchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module latchH_Asyn(out,clock,in,clockEnable,set,clear,clock2outMin_bits,clock2outMax_bits,SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMin_bits;
  input [63:0] clock2outMax_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end
  
  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;

  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or posedge clock or set or clear)
    begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow == 0 && set==1'b1))
      undelayedOut <= {n{1'b1}};                                                        // set output *** uses clocktoout times
    else if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow == 0 && clear==1'b1))
      undelayedOut <= {n{1'b0}};                                                      // set output *** uses clocktoout times
    else if ((clock == 1'b1) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))) //if clock is active and enabled Let output change
      undelayedOut <= enabled_in;                                                                                        //Q = D
    end

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;

endmodule

//*************************************************
// Register, Negative Edge Triggered, Asynchronous Set and Clear
// (first use v5.0)
//************************************************* 
module registerN_Asyn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
    
  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(negedge clock) //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))              //if set is not active then let the output change
        if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))        //if clear is not active then let the output change
           begin
           if (clock === 1'hx)   //if clock didn't transition directly from 1 to 0 (did 1 -> x instead)
             begin
             inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
          undelayedOut = 'hx;    //  begin transitioning to new state
             @(negedge clock) //end of clock transition region
                inClockingRegion = 0;
              end
           if (inputStayedStable)
             undelayedOut <= initialInputState;
      end
  end
    
  //verifies input stability during clocking region
  //stores an x if input changes
//commented out to handle clock divider circuit
//    always @(in)
//    if (inClockingRegion)
//      begin
//      inputStayedStable = 0;
//      undelayedOut = 'hx;
//      end

    
  always @(set)
    begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow==0 && set==1'b1))
      undelayedOut <= {n{1'b1}}; // set output *** Need to use clocktoout times
    end
  
  always @(clear)
    begin
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))   //if set is not active then let clear work
        if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow==0 && clear==1'b1))
          undelayedOut <= {n{1'b0}}; // set output *** uses clocktoout times
    end

 //model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);
  
endmodule


//*************************************************
// Register, Positive Edge Triggered, Asynchronous Set and Clear
// (first use v5.0)
//************************************************* 
module registerP_Asyn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(posedge clock) //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))              //if set is not active then let the output change
        if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))        //if clear is not active then let the output change
          begin
          if (clock === 1'hx)   //if clock didn't transition directly from 0 to 1 (did 0 -> x instead)
            begin
            inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
            if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
              undelayedOut = 'hx;    //  begin transitioning to new state
            @(posedge clock) //end of clock transition region
              inClockingRegion = 0;
            end
          if (inputStayedStable)
            undelayedOut <= initialInputState;
          end
  end
    
  //verifies input stability during clocking region
  //stores an x if input changes
//  always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end

  always @(set)
  begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow==0 && set==1'b1))
      undelayedOut <= {n{1'b1}}; // set output *** uses clocktoout times
  end

  always @(clear)
  begin
    if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))       //if set is not active then let clear work
      if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow==0 && clear==1'b1))
        undelayedOut <= {n{1'b0}}; // set output *** uses clocktoout times
  end

//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);
  
endmodule


//*************************************************
// Register, Both Edge Triggered, Asynchronous Set and Clear, Separate LH HL Delays
//  (first use v5.0)
//************************************************* 
module registerB_Asyn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(clock)   //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))              //if set is not active then let the output change
        if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))        //if clear is not active then let the output change
          begin
          if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
            begin
            inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
            if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
              undelayedOut = 'hx;    //  begin transitioning to new state
            @(clock) //end of clock transition region
              inClockingRegion = 0;
            end
          if (inputStayedStable)
            undelayedOut <= initialInputState;
     end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//  always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end

  always @(set)
    begin
      if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow==0 && set==1'b1))
  undelayedOut <= {n{1'b1}}; // set output *** uses clocktoout times
    end
  
  always @(clear)
    begin
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))          //if set is not active then let clear work
  if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow==0 && clear==1'b1))
    undelayedOut <= {n{1'b0}};                                                      // set output *** uses clocktoout times
    end

//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);
endmodule

//*************************************************
// Register, Negative Edge Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module registerN_Syn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(negedge clock) //start of clock transition region
  begin
  initialInputState = enabled_in;
  inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      begin
      if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
        begin
        inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
            begin
            if ( sc_activeLow == 1)
              begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
              2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
          end
            else
              begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
              end
            end   
        @(clock) //end of clock transition region
          inClockingRegion = 0;
        end
      if (inputStayedStable)
        begin
          if ( sc_activeLow == 1)
            begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end
          else
            begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end   
        end
        //else if clockEnable is not active then do nothing
      end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//    always @(in)
//      if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end
    
//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);
  
endmodule

//*************************************************
// Register, Positive Edge Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module registerP_Syn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(posedge clock) //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      begin
      if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
        begin
        inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== enabled_in)  //if flip-flop is changing state
            begin
            if ( sc_activeLow == 1)
              begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
          end
            else
              begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
              end
            end   
        @(posedge clock) //end of clock transition region
        inClockingRegion = 0;
        end
      if (inputStayedStable)
        begin
          if ( sc_activeLow == 1)
            begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end
          else
            begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end   
          end
        //else if clockEnable is not active then do nothing
      end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//      always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end
 
//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);
  
endmodule

//*************************************************
// Register, Both Edge Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module registerB_Syn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] initialInputState;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;
   
  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
  
  reg inClockingRegion;  //true when in clock transition region
  reg inputStayedStable; //true if input stayed stable during clock transition

  always @(clock)  //start of clock transition region
  begin
    initialInputState = enabled_in;
    inputStayedStable = 1;
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      begin
      if (clock === 1'hx)   //if clock didn't transition directly to 0 or 1 (did 0 or 1 -> x instead)
        begin
        inClockingRegion = 1;  //enable stability checker (flip-flop goes clocks an x if input changes during clocking region)
        if (undelayedOut !== enabled_in)  //if flip-flop is changing state, 
            begin
            if ( sc_activeLow == 1)
              begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
              2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
          end
            else
              begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut = 'hx; end   // begin transitioning to new value
              endcase
              end
            end   
        @(clock) //end of clock transition region
          inClockingRegion = 0;
        end
      if (inputStayedStable)
        begin
          if ( sc_activeLow == 1)
            begin
              case ({set, clear})                      //SC are active low
                2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
                2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
                2'b11: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end
          else
            begin      
              case ({set, clear})                      //SC are active High
                2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
                2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
                2'b00: begin undelayedOut <= initialInputState; end    //Q = D 
              endcase
            end   
          end
        //else if clockEnable is not active then do nothing
      end
  end

  //verifies input stability during clocking region
  //stores an x if input changes
//  always @(in)
//    if (inClockingRegion)
//      begin
//        inputStayedStable = 0;
//        undelayedOut = 'hx;
//      end
//  
//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);
  
endmodule

//*************************************************
// Latch, Low Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module latchL_Syn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end
  
  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;

  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or negedge clock or set or clear)
    begin
    //if clock is active and enabled Let output change
    if ((clock == 1'b0) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))      )
    begin
      if ( sc_activeLow == 1)
  begin
    case ({set, clear})                      //SC are active low
      2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
      2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
      2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
      2'b11: begin undelayedOut <= enabled_in; end    //Q = D 
    endcase
  end
      else
   begin      
     case ({set, clear})                      //SC are active High
       2'b11: begin undelayedOut <= { n{1'b1} }; end  //Set output   
       2'b10: begin undelayedOut <= { n{1'b1} }; end  //Set output   
       2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
       2'b00: begin undelayedOut <= enabled_in; end    //Q = D 
     endcase
   end   
  end
      end
  
//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);

endmodule

//*************************************************
// Latch, High Triggered, Synchronous Set and Clear
//  (first use v5.0)
//************************************************* 

module latchH_Syn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end
  
  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;

  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or posedge clock or set or clear)
    begin
    //if clock is active and enabled Let output change
    if ((clock == 1'b1) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))      )
      begin
  if ( sc_activeLow == 1)
    begin
      case ({set, clear})                      //SC are active low
        2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
        2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
        2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
        2'b11: begin undelayedOut <= enabled_in; end    //Q = D 
      endcase
    end
  else
    begin      
      case ({set, clear})                      //SC are active High
        2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
        2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
        2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
        2'b00: begin undelayedOut <= enabled_in; end    //Q = D 
      endcase
    end   
      end
    end   

//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);

endmodule

//*************************************************
// Latch, Low Triggered, Asynchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module latchL_Asyn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end
  
  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;

  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or negedge clock or set or clear)
    begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow == 0 && set==1'b1))
      undelayedOut <= {n{1'b1}}; // set output *** uses clocktoout times
    else if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow == 0 && clear==1'b1))
      undelayedOut <= {n{1'b0}}; // set output *** uses clocktoout times
    else if ((clock == 1'b0) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))) //if clock is active and enabled Let output change
      undelayedOut <= enabled_in;    //Q = D
    end

//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);

endmodule

//*************************************************
// Latch, High Triggered, Asynchronous Set and Clear
//  (first use v5.0)
//************************************************* 
module latchH_Asyn_Sep(out,clock,in,clockEnable,set,clear,clock2outMinLH_bits,clock2outMaxLH_bits,clock2outMinHL_bits,clock2outMaxHL_bits,
                      SETUPTIME_bits,HOLDTIME_bits);

  parameter n = 1;
  parameter ce_activeLow = 1; //active low by default
  parameter sc_activeLow = 1; //active low by default

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in;
  input clockEnable;   //active low by default
  input set;           //active low by default
  input clear;         //active low by default
  input [63:0] clock2outMinLH_bits;
  input [63:0] clock2outMaxLH_bits;
  input [63:0] clock2outMinHL_bits;
  input [63:0] clock2outMaxHL_bits;
  input [63:0] SETUPTIME_bits;
  input [63:0] HOLDTIME_bits;

  real LastInputTime;
  real LastClockTime;
  reg [n-1:0] undelayedOut;
  wire enabled;
  wire [n-1:0] enabled_in;
      
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end
  
  assign enabled = (ce_activeLow == 1'b1 && clockEnable == 1'b0) || (ce_activeLow == 1'b0 && clockEnable == 1'b1);
  assign enabled_in = enabled ? in : undelayedOut;

  always @(enabled_in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) < $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) < $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(enabled_in or posedge clock or set or clear)
    begin
    if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow == 0 && set==1'b1))
      undelayedOut <= {n{1'b1}};                                                        // set output *** uses clocktoout times
    else if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow == 0 && clear==1'b1))
      undelayedOut <= {n{1'b0}};                                                      // set output *** uses clocktoout times
    else if ((clock == 1'b1) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))) //if clock is active and enabled Let output change
      undelayedOut <= enabled_in;                                                                                        //Q = D
    end

//model min-max clock to output delay as transport delay
  reg [n-1:0] tempP1;
  reg [n-1:0] tempP2;
  reg [n-1:0] tempN1;
  reg [n-1:0] tempN2;
  always @(undelayedOut)
    begin
    tempP1 <= #($bitstoreal(clock2outMinLH_bits)) undelayedOut;
    tempP2 <= #($bitstoreal(clock2outMaxLH_bits)) undelayedOut;
    tempN1 <= #($bitstoreal(clock2outMinHL_bits)) undelayedOut;
    tempN2 <= #($bitstoreal(clock2outMaxHL_bits)) undelayedOut;
    end

  assign out = 
    undelayedOut == {n{1'b1}} ?
      ((tempP1 == tempP2) ? tempP1 : 'hx)
    :
      ((tempN1 == tempN2) ? tempN1 : 'hx);

endmodule


`endif
// End wavelib_exact.v
