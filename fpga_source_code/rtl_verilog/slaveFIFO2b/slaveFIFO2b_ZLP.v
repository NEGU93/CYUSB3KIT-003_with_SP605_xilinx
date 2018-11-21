module slaveFIFO2b_ZLP(
	input  reset_,
        input  clk_100,
        input  zlp_mode_selected,
        input  flaga_d,
        input  flagb_d,
        output slwr_zlp_,
	output pktend_zlp_,
        output [31:0] data_out_zlp
);

reg [2:0]current_zlp_state;
reg [2:0]next_zlp_state;

//parameters for ZLP mode state machine
parameter [2:0] zlp_idle                          = 3'd0;
parameter [2:0] zlp_wait_flagb              	  = 3'd1;
parameter [2:0] zlp_write                   	  = 3'd2;
parameter [2:0] zlp_write_wr_delay          	  = 3'd3;
parameter [2:0] zlp_wait		          = 3'd4;

reg [3:0]strob_cnt;
reg      strob;
reg [31:0]data_gen_zlp;
reg      pktend_;  


assign slwr_zlp_ = ((current_zlp_state == zlp_write) && (flagb_d == 1'b1)) ? 1'b0 : 1'b1;


//counter to generate the strob for ZLP data pkts
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		strob_cnt <= 4'd0;
	end else if(current_zlp_state == zlp_idle)begin
		strob_cnt <= 4'd0;
	end else if(current_zlp_state == zlp_wait)begin
		strob_cnt <= strob_cnt + 1'b1;
	end	
end

//Strob logic
always@(posedge clk_100, negedge reset_)begin
	if(!reset_)begin
		strob <= 1'b0;
	end else if((current_zlp_state == zlp_wait) && (strob_cnt == 4'b0111)) begin
		strob <= !strob;
	end
end

always@(*)begin
	if(zlp_mode_selected & (strob_cnt == 4'b0011) & (strob == 1'b1))begin
		pktend_ = 1'b0;
	end else begin
		pktend_ = 1'b1;
	end
end

assign pktend_zlp_ = pktend_;


//ZLP mode state machine
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		current_zlp_state <= zlp_idle;
	end else begin
		current_zlp_state <= next_zlp_state;
	end	
end

//ZLP mode state machine combo
always@(*)begin
	next_zlp_state = current_zlp_state;
	case(current_zlp_state)
	zlp_idle:begin
		if((zlp_mode_selected) & (flaga_d == 1'b1))begin
			next_zlp_state = zlp_wait_flagb; 
		end else begin
			next_zlp_state = zlp_idle;
		end	
	end
	zlp_wait_flagb :begin
		if((strob == 1'b1) & (flagb_d == 1'b1))begin
			next_zlp_state = zlp_wait;
		end else if ((flagb_d == 1'b1) && (strob == 1'b0))begin
			next_zlp_state = zlp_write; 
		end else begin
			next_zlp_state = zlp_wait_flagb; 
		end
	end
	zlp_write:begin
		if(flagb_d == 1'b0)begin
			next_zlp_state = zlp_write_wr_delay;
		end else begin
		 	next_zlp_state = zlp_write;
		end
	end
        zlp_write_wr_delay:begin
		next_zlp_state = zlp_wait;
	end
	zlp_wait:begin
		if(strob_cnt == 4'b1111)begin
			next_zlp_state = zlp_idle;
		end else begin
			next_zlp_state = zlp_wait;
		end
	end	
	endcase
end

//data generator counter for zlp mode
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		data_gen_zlp <= 32'd0;
	end else if((slwr_zlp_ == 1'b0) & (zlp_mode_selected)) begin
		data_gen_zlp <= data_gen_zlp + 1;
	end else if (!zlp_mode_selected) begin
		data_gen_zlp <= 32'd0;
	end	
end

assign data_out_zlp = data_gen_zlp;

endmodule
