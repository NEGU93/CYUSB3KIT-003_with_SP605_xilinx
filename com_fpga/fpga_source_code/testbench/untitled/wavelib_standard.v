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
  reg [n-1:0] undelayedOut;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
    
  always @(negedge clock)
    begin
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
	if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))              //if set is not active then let the output change
	  if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))        //if clear is not active then let the output change
	    undelayedOut <= in;    //Q = D
    end

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

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

//*************************************************
// Register, Positive Edge Triggered, Asynchronous Set and Clear
//  (first use v5.0)
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
  reg [n-1:0] undelayedOut;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
    
    
  always @(posedge clock)
    begin
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))  //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))                 //if set is     not active then let the output change
	if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))           //if clear is not active then let the output change
	  undelayedOut <= in;                                                                    //Q = D
    end

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

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
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
  reg [n-1:0] undelayedOut;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

    
  always @(clock)
    begin
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow ==0 && clockEnable==1'b1)) //if ClockEnable is active then let the Output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow==0 && set==1'b0))                     //if set is not active then let the output change
	if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow==0 && clear==1'b0))         //if clear is not active then let the output change
	  undelayedOut <= in;    //Q = D
    end

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
  reg [n-1:0] undelayedOut;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

    
  always @(negedge clock)
    begin
      //if ClockEnable is active then let the Output change
      if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))   
	begin
	  if ( sc_activeLow == 1)
	    begin
	      case ({set, clear})                      //SC are active low
		2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
		2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
		2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
		2'b11: begin undelayedOut <= in; end    //Q = D 
	      endcase
	    end
	  else
	     begin      
		case ({set, clear})                      //SC are active High
		2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
		2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
		2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
		2'b00: begin undelayedOut <= in; end    //Q = D 
		endcase
	      end   
	end
      //else if clockEnable is not active then do nothing
    end
    
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
  reg [n-1:0] undelayedOut;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
   
    
  always @(posedge clock)
  begin
    //if ClockEnable is active then let the Output change
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))   
      begin
	if ( sc_activeLow == 1)
	  begin
	    case ({set, clear})                      //SC are active low
	      2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
	      2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
	      2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
	      2'b11: begin undelayedOut <= in; end    //Q = D 
	    endcase
	  end
	else
	  begin      
	    case ({set, clear})                      //SC are active High
	      2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
	      2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
	      2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
	      2'b00: begin undelayedOut <= in; end    //Q = D 
	    endcase
	  end   
      end
    //else if clockEnable is not active then do nothing
  end
    
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
  reg [n-1:0] undelayedOut;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    
   
    
  always @(clock)
  begin
    //if ClockEnable is active then let the Output change
    if ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))   
      begin
	if ( sc_activeLow == 1)
	  begin
	    case ({set, clear})                      //SC are active low
	      2'b00: begin undelayedOut <= {n{1'b1}}; end  //Set output   
	      2'b01: begin undelayedOut <= {n{1'b1}}; end  //Set output   
	      2'b10: begin undelayedOut <= {n{1'b0}}; end  //Clear output    
	      2'b11: begin undelayedOut <= in; end    //Q = D 
	    endcase
	  end
	else
	  begin      
	     case ({set, clear})                      //SC are active High
	       2'b11: begin undelayedOut <= { n{1'b1} }; end  //Set output   
	       2'b10: begin undelayedOut <= { n{1'b1} }; end  //Set output   
	       2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
	       2'b00: begin undelayedOut <= in; end    //Q = D 
	     endcase
	  end   
      end
    //else if clockEnable is not active then do nothing
  end
    
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
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    

  always @(in or negedge clock or set or clear)
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
	    2'b11: begin undelayedOut <= in; end    //Q = D 
	  endcase
	end
      else
	 begin      
	   case ({set, clear})                      //SC are active High
	     2'b11: begin undelayedOut <= { n{1'b1} }; end  //Set output   
	     2'b10: begin undelayedOut <= { n{1'b1} }; end  //Set output   
	     2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
	     2'b00: begin undelayedOut <= in; end    //Q = D 
	   endcase
	 end   
	end
      end   

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
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    


  always @(in or posedge clock or set or clear)
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
	      2'b11: begin undelayedOut <= in; end    //Q = D 
	    endcase
	  end
	else
	  begin      
	    case ({set, clear})                      //SC are active High
	      2'b11: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
	      2'b10: begin undelayedOut <= { n{1'b1} } ; end  //Set output   
	      2'b01: begin undelayedOut <= { n{1'b0} }; end  //Clear output    
	      2'b00: begin undelayedOut <= in; end    //Q = D 
	    endcase
	  end   
      end
    end   

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
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    


  always @(in or negedge clock)
    begin
    if ((clock == 1'b0) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))) //if clock is active and enabled Let output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow == 0 && set==1'b0))                                   //if set is not active then let the output change
	if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow == 0 && clear==1'b0))                             //if clear is not active then let the output change
	  undelayedOut <= in;    //Q = D
    end

  always @(set)
    begin
      if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow == 0 && set==1'b1))
	undelayedOut <= {n{1'b1}}; // set output *** uses clocktoout times
    end
  
  always @(clear)
    begin
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow == 0 && set==1'b0))       //if set is not active then let clear work
	if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow == 0 && clear==1'b1))
	  undelayedOut <= {n{1'b0}}; // set output *** uses clocktoout times
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
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= $bitstoreal(HOLDTIME_bits))
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, $bitstoreal(HOLDTIME_bits), ($realtime - LastClockTime));
    end

  always @posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= $bitstoreal(SETUPTIME_bits) )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, $bitstoreal(SETUPTIME_bits), ($realtime - LastInputTime));
    end    


  always @(in or posedge clock)
    begin
    if ((clock == 1'b1) && ((ce_activeLow == 1 && clockEnable==1'b0) ||  (ce_activeLow == 0 && clockEnable==1'b1))) //if clock is active and enabled Let output change
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow == 0 && set==1'b0))                                   //if set is not active then let the output change
	if (( sc_activeLow == 1 && clear == 1'b1)|| (sc_activeLow == 0 && clear==1'b0))                             //if clear is not active then let the output change
	  undelayedOut <= in;                                                                                        //Q = D
    end

  always @(set)
    begin
      if (( sc_activeLow == 1 && set == 1'b0)|| (sc_activeLow == 0 && set==1'b1))
	undelayedOut <= {n{1'b1}};                                                        // set output *** uses clocktoout times
    end
  
  always @(clear)
    begin
      if (( sc_activeLow == 1 && set == 1'b1)|| (sc_activeLow == 0 && set==1'b0))        //if set is not active then let clear work
	if (( sc_activeLow == 1 && clear == 1'b0)|| (sc_activeLow == 0 && clear==1'b1))
	  undelayedOut <= {n{1'b0}};                                                      // set output *** uses clocktoout times
    end

  wire [n-1:0] #($bitstoreal(clock2outMin_bits)) temp1 = undelayedOut;
  wire [n-1:0] #($bitstoreal(clock2outMax_bits)) temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;

endmodule

//************************************
// Old Models (v4.5) needed to support legacy of startState
//************************************
//** Latch active Low *** old model(v4.5) support legacy of startState
module latchL(out,clock,in,startState);

  parameter n = 1;
  parameter clock2outMin = 0;
  parameter clock2outMax = 0;
  parameter SETUPTIME = 0;
  parameter HOLDTIME = 0;

  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in, startState;

  reg [n-1:0] undelayedOut;
  real LastInputTime;
  real LastClockTime;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= HOLDTIME)
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, HOLDTIME, ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= SETUPTIME )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, SETUPTIME, ($realtime - LastInputTime));
    end


  initial
    #0 if (clock == 1'b0)
   undelayedOut <= in;
       else
   undelayedOut <= startState;

  always @(in or negedge clock)
    if (clock == 1'b0)
      undelayedOut <= in;

  wire [n-1:0] #clock2outMin temp1 = undelayedOut;
  wire [n-1:0] #clock2outMax temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;

endmodule

//** Latch active High *** old model(v4.5) support legacy of startState
module latchH(out,clock,in,startState);

  parameter n = 1;
  parameter clock2outMin = 0;
  parameter clock2outMax = 0;
  parameter SETUPTIME = 0;
  parameter HOLDTIME = 0;
  
  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in, startState;
  
  reg [n-1:0] undelayedOut;
  real LastInputTime;
  real LastClockTime;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= HOLDTIME)
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, HOLDTIME, ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= SETUPTIME )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, SETUPTIME, ($realtime - LastInputTime));
    end

  
  initial
    begin
    #0 if (clock == 1'b1)
   undelayedOut <= in;
       else
   undelayedOut <= startState;
    end
    
  always @(in or posedge clock)
    if (clock == 1'b1)
      undelayedOut <= in;
    
  wire [n-1:0] #clock2outMin temp1 = undelayedOut;
  wire [n-1:0] #clock2outMax temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

//** Register Negative Edge trigger *** old model(v4.5) support legacy of startState
module registerN(out,clock,in,startState);

  parameter n = 1;
  parameter clock2outMin = 0;
  parameter clock2outMax = 0;
  parameter SETUPTIME = 0;
  parameter HOLDTIME = 0;
  
  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in, startState;

  reg [n-1:0] undelayedOut;
  real LastInputTime;
  real LastClockTime;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= HOLDTIME)
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, HOLDTIME, ($realtime - LastClockTime));
    end

  always @(negedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= SETUPTIME )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, SETUPTIME, ($realtime - LastInputTime));
    end
    
    
  initial
    #0 undelayedOut <= startState;
    
  always @(negedge clock)
    undelayedOut <= in;
  
//  always @(notifier)
//    if (notifier)
//      assign undelayedOut = 'hx;
//    else
//      deassign undelayedOut;

  wire [n-1:0] #clock2outMin temp1 = undelayedOut;
  wire [n-1:0] #clock2outMax temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule
    

//** Register Positive Edge trigger *** old model(v4.5) support legacy of startState
module registerP(out,clock,in,startState);

  parameter n = 1;
  parameter clock2outMin = 0;
  parameter clock2outMax = 0;
  parameter SETUPTIME = 0;
  parameter HOLDTIME = 0;
 
  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in, startState;
  
  reg [n-1:0] undelayedOut;
  real LastInputTime;
  real LastClockTime;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= HOLDTIME)
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, HOLDTIME, ($realtime - LastClockTime));
    end

  always @(posedge clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= SETUPTIME )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, SETUPTIME, ($realtime - LastInputTime));
    end

  
  initial
    #0 undelayedOut <= startState;
    
  always @(posedge clock)
    undelayedOut <= in;

  wire [n-1:0] #clock2outMin temp1 = undelayedOut;
  wire [n-1:0] #clock2outMax temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule
 
//** Register Both Edge trigger *** old model(v4.5) support legacy of startState
module registerB(out,clock,in,startState);

  parameter n = 1;
  parameter clock2outMin = 0;
  parameter clock2outMax = 0;
  parameter SETUPTIME = 0;
  parameter HOLDTIME = 0;
  
  output [n-1:0] out;
  input          clock;
  input  [n-1:0] in, startState;
  
  reg [n-1:0] undelayedOut;
  real LastInputTime;
  real LastClockTime;
    
  initial
    begin
    LastInputTime = 0.0;
    LastClockTime = 0.0;
    end

  always @(in)
    begin
    LastInputTime = $realtime;
    if (LastClockTime != 0)
      if (($realtime - LastClockTime) <= HOLDTIME)
        $display("Hold Time violation on signal input of %m at time %t (HoldTime is %g, actual hold was %g).", $realtime, HOLDTIME, ($realtime - LastClockTime));
    end

  always @(clock)
    begin
    LastClockTime = $realtime;
    if (LastInputTime != 0)   
      if (($realtime - LastInputTime) <= SETUPTIME )
        $display("Setup Time violation on signal input of %m, at time %t (SetupTime is %g, actual setup was %g).", $realtime, SETUPTIME, ($realtime - LastInputTime));
    end

  
  initial
    #0 undelayedOut <= startState;
    
  always @(clock)
    undelayedOut <= in;

  wire [n-1:0] #clock2outMin temp1 = undelayedOut;
  wire [n-1:0] #clock2outMax temp2 = undelayedOut;
  assign out = (temp1 == temp2) ? temp1 : 'hx;
  
endmodule

`endif
