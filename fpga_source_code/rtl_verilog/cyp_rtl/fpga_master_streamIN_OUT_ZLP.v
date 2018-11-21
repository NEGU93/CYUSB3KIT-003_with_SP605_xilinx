


module fpga_master(sync, fdata, faddr, slrd, slwr, flagb, flaga,flagc,flagd ,clk, sloe,clk_out,slcs,pktend,mode_p,PMODE,RESET,int_n,tri_state,PMODE_2); //module fpga_master(fdata, faddr, slrd, slwr, clk, sloe,clk_out,slcs);  //
   

   inout [31:0]    fdata; 
   output [1:0]    faddr; 
   output          slrd;  
   output          slwr;  
   input 				sync;
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
   reg [31:0] rd_data = 32'b00000000000000000000000000000000;	
   reg [2:0] cnt = 2'b000;	
   reg [1:0]       faddr_i;   
   reg             slrd_i;
   reg             slcs_i;
   reg             slwr_i;
   reg             first_entry=1'b0;   
   reg [3:0]       MasterState = 4'b0000;//Counter to sequence the FIFO signals   
   reg [3:0]       late_count = 4'b0000;
   reg             sloe_i;
   reg             pktend_i;
   reg             strob = 1'b0; 
   reg             data_modify = 1'b0; 
   wire             clk_100 ;//= 1'b0;	
	reg[2:0]			 mode = 3'b001;
	reg[7:0] conter; 		
	reg[2:0] data_modify_cnt = 3'b000; 		
	wire clk_out_temp;	
	
	reg[4:0] latcount;
 //  reg[2:0] cnt;
	reg first_time;
	   reg[15:0] index ;
	   reg[15:0] DataCount_i ;
		
	reg             slrd_2i = 1'b0 ;
   reg             slrd_3i = 1'b0 ;
   reg             slrd_4i = 1'b0 ;
   reg             slrd_5i = 1'b0 ;
	
	parameter [2:0] Partial = 3'b000;
	parameter [2:0] ZLP = 3'b001;   
	parameter [2:0] Stream_in = 3'b010;   
	parameter [2:0] Stream_out= 3'b011;   
	
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
	assign fdata = fdata_i;// = 31'h0000000;   //
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
   begin: mode_t 	
		if (first_entry == 1'b1)
		begin
			mode <= mode_p;
		end
	end
   
   
   always @(posedge clk_100)
   begin: test_proc 	
	
	if (sync == 1'b1)
	begin
	
		case (mode[2:0])
				
		Partial :
		begin
	
         case (MasterState[3:0])
			
            A :
               begin
                  data_modify <= 1'b1;
						data_modify_cnt = 3'b000;  
						slcs_i <=  1'b0;
                  sloe_i <= 1'b1;
                  faddr_i <= 2'b00;  
                  slrd_i <= 1'b1;
                  slwr_i <= 1'b1;
						pktend_i <= 1'b1;					
						cnt = 3'b000;						
						conter <= 8'b00000000;							
						late_count = 0;
				  
                  if (flaga == 1'b1)
						begin
							MasterState <= E; 
						end
						
						else
						begin
							MasterState <= A; 
						end				
						
						first_entry = 1'b1;
						
               end
            
            E :
               begin
                  
						first_entry = 1'b0;
						
						
						
						if (data_modify_cnt == 1)
						begin
							data_modify <= 1'b0;
						end
						
						data_modify_cnt = data_modify_cnt + 1; 
						
                  
                  slrd_i <= 1'b1;
                  sloe_i <= 1'b1;
						slcs_i <=  1'b0;
						
                  if (flagb == 1'b1)		//if partial full flag is in a deasserted state 
                  begin							//assert slave write control signal
                     slwr_i <= 1'b0;
							late_count = 1;							
                     MasterState <= E;		//stay in state E 
                  end
						
						else
						begin
						
							if (late_count == 0 ) 
							begin
								slwr_i <= 1'b1;
								MasterState <= F;		 						
							end
						
							else
							begin					 
								slwr_i <= 1'b0;
								MasterState <= E;	
								late_count = late_count - 1;
							end	
						
						end
												
						if ((conter == 8'b00001111) && (strob == 1'b1))
						begin							
							
							pktend_i <= 1'b0;							
							MasterState <= F;
						
						end
						
						//first_entry = 1'b1;				

						conter <= conter + 1;
						
               end
					
				F: 
				begin 
				
					
					if ((pktend_i == 1'b0) && (cnt==3'b000))
					begin
						slwr_i <= 1'b0;						
						pktend_i <= 1'b0;		
					end					
					
					else
					begin					
						slwr_i <= 1'b1;
						pktend_i <= 1'b1;	
						slcs_i <=  1'b0;
					end
					
					//if (cnt==3'b110)
					//begin
					
					//	first_entry = 1'b0;	
					
					//end
					
					if (cnt==3'b111)
					begin					
						MasterState <= A;		
						strob <= ~strob;
						
					end
					
					else
					begin
						MasterState <= F;		
						cnt = cnt + 1'b1;
					end							
				
				end
            
				default :
               begin
                  
                  faddr_i <= 2'b00;
						late_count = 0;
						conter <= 8'b00000000;
                  slcs_i <=  1'b1;
                  slrd_i <= 1'b1;			
                  sloe_i <= 1'b1;
                  slwr_i <= 1'b1;
                  MasterState <= A;			
						strob					<=  1'b0;	
               end
				endcase
			
			end
			
	ZLP:
	begin
	
	         case (MasterState[3:0])
			
            A :
               begin
                  
						data_modify <= 1'b1;
						data_modify_cnt = 3'b000; 
                  sloe_i <= 1'b1;
                  faddr_i <= 2'b00;   
                  slrd_i <= 1'b1;
                  slwr_i <= 1'b1;
						pktend_i <= 1'b1;
						late_count = 0;
						cnt = 3'b000;
						conter <= 8'b00000000;						
				  
                  if (flaga == 1'b1)
						begin
								MasterState <= E; 
						end
						
						else
						begin
							MasterState <= A; 
						end
											
						first_entry = 1'b1;
						
               end
            
					E :
               begin
					
						first_entry = 1'b0;

						if (data_modify_cnt == 1)
						begin
							data_modify <= 1'b0;
						end
						
						data_modify_cnt = data_modify_cnt + 1; 					
					
					
					
					
                  
                  
                  slrd_i <= 1'b1;
                  sloe_i <= 1'b1;
						
						
                  if (flagb == 1'b1)		
                  begin							
                     slwr_i <= 1'b0;
							late_count = 1;							
                     MasterState <= E;		
                  end
						
						else
						begin
						
							if ( late_count == 0)
							begin
								slwr_i <= 1'b1;
								MasterState <= F;							
							end
						
							else
							begin					 
								slwr_i <= 1'b0;
								MasterState <= E;		
								late_count = late_count -1;
							end
						
						end
						
						
						if (strob == 1'b1)
						begin							
							
							slwr_i <= 1'b1;
							pktend_i <= 1'b0;							
							MasterState <= F;
						
						end			
						
						//first_entry = 1'b1;			
						conter <= conter + 1;
						
					end
					
					F: 
					begin 					
						
						if ((pktend_i == 1'b0) && (cnt==3'b000))
						begin
							pktend_i <= 1'b0;	
						end
						
						else
						begin
							pktend_i <= 1'b1;
						end
						
						//if (cnt==3'b110)
						//begin					
						//	first_entry = 1'b0;						
						//end
						
						if (cnt==3'b111)
						begin					
							MasterState <= A;		
							strob <= ~strob;
							
						end
					
						else
						begin
							MasterState <= F;		
							cnt = cnt + 1'b1;
						end							
				
					end
            
					default :
               begin
                  
                  faddr_i <= 2'b00;
						late_count = 0;
						conter <= 8'b00000000;
                  strob					<=  1'b0;	
                  slrd_i <= 1'b1;			
                  sloe_i <= 1'b1;
                  slwr_i <= 1'b1;
                  MasterState <= A;		
               end
					
         endcase
			
		end	
		
		
	Stream_in:
		begin
		
	         case (MasterState[3:0])
			
            A :
               begin
                  
						data_modify <= 1'b1;
						data_modify_cnt = 3'b000;                   sloe_i <= 1'b1;
                  faddr_i <= 2'b00;   //	IDLE STATE
                  slrd_i <= 1'b1;
                  slwr_i <= 1'b1;
						pktend_i <= 1'b1;
						late_count = 0;
						cnt = 3'b000;
						conter <= 8'b00000000;
				  
                  if (flaga == 1'b1)
						begin
								MasterState <= E; //full flag not asserted, start transfer
						end
						
						else
						begin
							MasterState <= A; //full flag is asserted, remain in idle.
						end						
						first_entry = 1'b1;
						
               end
            
					E :
               begin
                  
						first_entry = 1'b0;
 
						if (data_modify_cnt == 1)
						begin
							data_modify <= 1'b0;
						end
						
						data_modify_cnt = data_modify_cnt + 1; 


 
                  slrd_i <= 1'b1;
                  sloe_i <= 1'b1;
						
						
                  if (flagb == 1'b1)		//if partial full flag is in a deasserted state 
                  begin							//assert slave write control signal
                     slwr_i <= 1'b0;
							late_count = 1;						// late_count was 1, modified in 100MHz						
                     MasterState <= E;		//stay in state E 
                  end
						
						else
						begin
						
							if ( late_count == 0)
							begin
								slwr_i <= 1'b1;
								MasterState <= F;		//when Full flag gets asserted, move to state A 						
							end
						
							else
							begin					 
								slwr_i <= 1'b0;
								MasterState <= E;		//when Full flag gets asserted, move to state A 
								late_count = late_count -1;
							end
						
						end				

						
						//first_entry = 1'b1;			
						conter <= conter + 1;
						
					end
					
					F: 
					begin 					
						
						pktend_i <= 1'b1;
						
						//if (cnt==3'b110)
					//	begin					
					//		first_entry = 1'b0;						
					//	end
						
						if (cnt==3'b111)
						begin					
							MasterState <= A;		
							strob <= ~strob;
							
						end
					
						else
						begin
							MasterState <= F;		
							cnt = cnt + 1'b1;
						end							
				
					end
            
					default :
               begin
                  
                  faddr_i <= 2'b00;
						late_count = 0;
						conter <= 8'b00000000;
                  strob					<=  1'b0;	
                  slrd_i <= 1'b1;			
                  sloe_i <= 1'b1;
                  slwr_i <= 1'b1;
                  MasterState <= A;			//if an undefined state move to IDLE
               end
					
				
				endcase
					end	
	

	Stream_out:
	begin

			case (MasterState[3:0])           
			G :
				begin
					first_entry = 1'b1;
					sloe_i <= 1'b1;
					slcs_i <= 1'b0;
					slwr_i <= 1'b1;
					first_time <= 1'b1;
					slrd_i <= 1'b1; 
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
					first_entry = 1'b0;
					faddr_i <= 2'b11;			
					slrd_i <= 1'b1; 
					sloe_i <= 1'b1;
					slwr_i <= 1'b1;
					slcs_i <= 1'b0;
					MasterState <= B; 					
					DataCount_i <= 0;	
					first_time <= 1'b1;
					
				end			
            
            B :
               begin                  
               faddr_i <= 2'b11;
						//first_entry = 1'b1;
						first_time <= 1'b0;		
				
					   if (flagd == 1'b1) 
						begin
						
							slrd_i <= 1'b0;		
							sloe_i <= 1'b0;
							//fdata_i <= 16'bz; ///   need to addd @@@@@@@@@@@@@@@@@@@@@@@@@@@#$####@#@$#$@
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
								MasterState <= B ;								
								cnt = 3;								
							end
							
							else
							begin
							
								MasterState <= B ;
								cnt = cnt - 1;
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
						
						
						if ((slrd_4i == 0))	  // slrd_3i	
						begin										
							rd_data <= fdata;	
						end	
						
					end
				F :
				begin
				
						DataCount_i <= 0;				
						faddr_i <= 2'b11;								
						
						if (cnt==3'b011)
						begin
							MasterState <= G; 
						end
						
						else
						begin
							cnt = cnt + 1;
							MasterState <= F; 
						end
						
						//if (cnt==3'b010)
						//begin
						//	first_entry = 1'b0;
						//end


						
						
		
				end				
					
					
					
           default :
				begin
               first_entry = 1'b1;   
              faddr_i <= 2'b10;
              slrd_i <= 1'b1;
              sloe_i <= 1'b1;
              slwr_i <= 1'b1;
				  slcs_i <= 1'b0;
              MasterState <= G;		 

				
				end					
				
         endcase
	end


			default :
          begin
					 first_entry = 1'b1;   
              slrd_i <= 1'b1;
              sloe_i <= 1'b1;
              slwr_i <= 1'b1;
				  slcs_i <= 1'b1;			 
			 end	
		
		
	endcase
	
	end
	end
	
	
	
	always @(negedge clk_100)
   begin: data_y	


	
		if ((mode[2:0] == Stream_in) )
		begin	
			if ((slwr_i == 1'b0) )    //&& (first_data == 1) 
			begin		
				fdata_i <= fdata_i + 8'b00000001 ;			
			end
		end
		
	if ( data_modify == 0 || strob == 1)
	begin		
		if ((mode[2:0] == Partial) || (mode[2:0] == Stream_in) )
		begin	
			if ((slwr_i == 1'b0) )    //&& (first_data == 1) 
			begin		
				fdata_i <= fdata_i + 8'b00000001 ;			
			end
		end
	end
				

		if (mode[2:0] == ZLP)
		begin
			if ((slwr_i == 1'b0) && (strob == 1'b0) ) 
			begin		
				fdata_i <= fdata_i + 8'b00000001 ;			
			end
		end
		
		/*
		if (mode[2:0] == Stream_out)
		begin		
			if (MasterState == B )
			begin
				fdata_i <= 32'bZ ;			
			end			
		end		
		*/
		
	//end	
	end	
	

   
endmodule
