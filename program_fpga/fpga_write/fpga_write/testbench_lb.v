
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:49:14 06/27/2012
// Design Name:   fpga_master
// Module Name:   C:/Users/Hridya/Documents/Cypress Contract/AN_001-61345/test_lb/testbench_lb.v
// Project Name:  test_lb
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fpga_master
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench_lb;

	// Inputs
	
	reg flagc; //partial flag for IN EP
	reg flagd; //full flag
	reg clk;

	// Outputs
	wire [1:0] faddr;
	wire slrd;
	wire slwr;
	wire sloe;

	// Bidirs
	wire [7:0] fdata;

	// Instantiate the Unit Under Test (UUT)
	fpga_master uut (
		.fdata(fdata), 
		.faddr(faddr), 
		.slrd(slrd), 
		.slwr(slwr), 
		.flagc(flagc), 
		.flagd(flagd), 
		.clk(clk), 
		.sloe(sloe)
	);

    initial // Clock generator
  begin
    clk = 0;
    forever #10 clk = !clk;
  end
	initial begin
		// Initialize Inputs
		flagc = 1;
		flagd = 1;
		//clk = 0;

		//Wait 100 ns for global reset to finish
		 #200;
         flagc = 0;
		// flaga = 1;
		// #500
		// flaga = 0;
		//Add stimulus here

	end
      
endmodule

