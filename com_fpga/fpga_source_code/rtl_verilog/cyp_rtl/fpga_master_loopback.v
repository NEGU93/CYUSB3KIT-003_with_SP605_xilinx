
/*

Fill the USB buffer first then enable the sync switch

*/

module fpga_master(sync,fdata, faddr, slrd, slwr, flagb, flaga,flagc,flagd ,clk, sloe,clk_out,slcs,pktend,mode_p,PMODE,RESET,int_n,tri_state,PMODE_2); //module fpga_master(fdata, faddr, slrd, slwr, clk, sloe,clk_out,slcs);  //
   
   inout [31:0]    fdata; 
   output [1:0]    faddr; 
   output          slrd;  
   output          slwr;  
   
   input           sync; 
   input           flagb; 
	input           flaga; 
	input           flagc; 
	input           flagd; 
	input [2:0]     mode_p; 
   input           clk;   
   output          clk_out;   
   output          sloe; 
   output          slcs; 
   output          pktend;  
	
   output[1:0]     PMODE; 
   input           PMODE_2; 
	
   output          RESET; 
   input           int_n;  
   input[12:0]     tri_state;  
   
   reg [31:0] fdata_i = 32'b00000000000000000000000000000000;	
   reg [2:0] cnt = 2'b000;	
   reg [1:0]       faddr_i;   
   reg             slrd_i = 1'b1 ;
   reg             slcs_i= 1'b1 ;
   reg             slwr_i= 1'b1 ;
   reg             first_entry=1'b0;   
   reg [3:0]       MasterState = 4'b0110;
   reg [3:0]       late_count = 4'b0000;
   reg             sloe_i= 1'b1 ;
   reg             pktend_i= 1'b1 ;
   reg             strob = 1'b0; 
   wire             clk_100 ;
	reg[2:0]			 mode = 3'b001;
	reg[7:0] conter; 		
	wire clk_out_temp;	
	reg[4:0] latcount; 
	reg first_time;
	reg[15:0] index ;
	reg[15:0] DataCount_i ;
	reg             slrd_2i = 1'b1 ;
   reg             slrd_3i = 1'b1 ;
   reg             slrd_4i = 1'b1 ;
   reg             slrd_5i = 1'b1 ;
	reg[31:0]        fdata_temp;
	reg [31:0] ram[0:255]; 	
		
		
	parameter [3:0] Partial = 4'b0000;
	parameter [3:0] ZLP = 4'b0001;   
	parameter [3:0] Stream_in = 4'b0010;   
	parameter [3:0] Stream_out= 4'b0011;   
	
   parameter [3:0] A = 4'b0000;
   parameter [3:0] B = 4'b0001;
   parameter [3:0] C = 4'b0010;
   parameter [3:0] D = 4'b0011;
   parameter [3:0] E = 4'b0100;
   parameter [3:0] F = 4'b0101;
   parameter [3:0] G = 4'b0110;
   parameter [3:0] H = 4'b0111;
   
   assign slrd = slrd_i;
   assign slwr = slwr_i;   
   assign faddr = faddr_i;
   assign sloe = sloe_i;
	assign fdata = fdata_i;
	assign pktend = pktend_i;	
	assign PMODE = 2'b11;		
	assign RESET = 1'b1;	
	assign slcs = slcs_i;
	


	
		clk_wiz_v3_6 clk_gen
		(
			.CLK_IN1(clk),  
			.CLK_OUT1(clk_100),  
			.LOCKED(lock)
		);
	
	
	
		ODDR2 oddr_y
		(
			.D0(1'b1),
			.D1(1'b0),
			.C0 (clk_100),
			.C1(~clk_100),
			.Q(clk_out)
		);   
	
	always @(posedge clk_100)   
	begin: delay  
	
		slrd_2i <= slrd_i;
		slrd_3i <= slrd_2i;   
		slrd_4i <= slrd_3i;   
		slrd_5i <= slrd_4i;   
			
	end
	

   

   always @(posedge clk_100)   
	begin: test_proc       



	if (sync == 1'b1)								// Synchronization signal 
	begin   
	
			case (MasterState[3:0])           
			G :
				begin
					
					pktend_i <= 1'b1;
					sloe_i <= 1'b1;
					slcs_i <= 1'b0;
					slwr_i <= 1'b1;
					first_time <= 1'b1;
					latcount = 0;
					index = 0;
					
					if (flagc == 1'b1) 
					begin					
						MasterState <= A; 								
					end
						
					else                 
					begin										
						MasterState <= G;  								
					end				
					
					faddr_i <= 2'b11;					
					
				end
				
			A:
				begin
				
					faddr_i <= 2'b11;		
					slrd_i <= 1'b1; 
					sloe_i <= 1'b1;
					slwr_i <= 1'b1;
					slcs_i <= 1'b0;
					MasterState <= B; 
					pktend_i <= 1'b1;				
					DataCount_i <= 0;	
					first_time <= 1'b1;
					
				end			
            
            B :
               begin
                  
						faddr_i <= 2'b11;
						pktend_i <= 1'b1;				
				
					   if (flagd == 1'b1) 
						begin						
							slrd_i <= 1'b0;		
							sloe_i <= 1'b0;
							fdata_i <= 32'bz;								
							latcount = 2;	
							MasterState <= B;		
						end
						
					   else 
					   begin
							if (latcount > 0)		
							begin
								latcount = latcount - 1;
								slrd_i <= 1'b0;		
								sloe_i <= 1'b0;
								fdata_i <= 32'bz;								
								MasterState <= B ;
								cnt <= 3;
							end
							
							else
							begin
								MasterState <= B ;
								cnt <= cnt - 1;
								sloe_i <= 1'b0;
								slrd_i <= 1'b1;
								if ( cnt == 0 )
								begin
									slrd_i <= 1'b1;
									sloe_i <= 1'b1;
									slwr_i <= 1'b1;
									MasterState <= F;		
									DataCount_i <= 0;
								end
							end
						end	
						
						if ((slrd_4i == 0))	 
						begin										
							ram[DataCount_i] <= fdata;	
							
							if (DataCount_i < 255)
							begin							
								DataCount_i <= DataCount_i + 1;	
							end
							
						end
						
            end
				
			F :
				begin
				
						DataCount_i <= 0;
						pktend_i <= 1'b1;
						faddr_i <= 2'b00;
				
                  if (flaga == 1'b1)
						begin
							MasterState <= C; 
						end
						
						else
						begin
							MasterState <= F; 
						end		
				end

			C :
				begin			
				
						faddr_i <= 2'b00;
						pktend_i <= 1'b1;
						slrd_i <= 1'b1;
                  sloe_i <= 1'b1;  

                 if (flagb == 1'b1)		
                  begin							
                     slwr_i <= 1'b0;		
							fdata_i <= ram[DataCount_i] ;	
                     MasterState <= C;									
							DataCount_i <= DataCount_i + 1;			
							late_count = 1;
                  end
						
						else
						begin 						
							if (late_count==0)
							begin
								slwr_i <= 1'b1;
								MasterState <= H;		
							end						
							else
							begin					 
								slwr_i <= 1'b0;
								late_count = late_count - 1;	
								MasterState <= C;	
							end							
						end						
				end
				
			H:
			begin			
				pktend_i <= 1'b1;				
				ram[index] <= 32'h00000000;				
				if (index == 256)
				begin				
					MasterState <= G;	
					index = 0;
				end				
				else
				begin				
					MasterState <= H;	
					index = index + 1;					
				end 				
			end
					
           default :
				begin
              pktend_i <= 1'b1;    
              faddr_i <= 2'b00;
              slrd_i <= 1'b1;
              sloe_i <= 1'b1;
              slwr_i <= 1'b1;
				  slcs_i <= 1'b0;
              MasterState <= G;					
				end					
				
         endcase
			end
			
   end
	
	
	
	
	

	
	
	
   
endmodule
