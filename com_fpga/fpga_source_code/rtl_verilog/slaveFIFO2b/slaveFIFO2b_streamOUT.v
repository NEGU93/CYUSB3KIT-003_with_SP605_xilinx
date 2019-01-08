module slaveFIFO2b_streamOUT(
	input  reset_,
	input  clk_100,
	input  stream_out_mode_selected,
	input  flagc_d,
	input  flagd_d,
	input  [31:0]stream_out_data_from_fx3,
	output slrd_streamOUT_,
	output sloe_streamOUT_
);


reg [2:0]current_stream_out_state;
reg [2:0]next_stream_out_state;

//parameters for StreamOUT mode state machine
parameter [2:0] stream_out_idle                   = 3'd0;
parameter [2:0] stream_out_flagc_rcvd             = 3'd1;
parameter [2:0] stream_out_wait_flagd             = 3'd2;
parameter [2:0] stream_out_read                   = 3'd3;
parameter [2:0] stream_out_read_rd_and_oe_delay   = 3'd4;
parameter [2:0] stream_out_read_oe_delay          = 3'd5;

reg [1:0] oe_delay_cnt;	
reg rd_oe_delay_cnt; 


assign slrd_streamOUT_ = ((current_stream_out_state == stream_out_read) | (current_stream_out_state == stream_out_read_rd_and_oe_delay)) ? 1'b0 : 1'b1;
assign sloe_streamOUT_ = ((current_stream_out_state == stream_out_read) | (current_stream_out_state == stream_out_read_rd_and_oe_delay) | (current_stream_out_state == stream_out_read_oe_delay)) ? 1'b0 : 1'b1;

//counter to delay the read and output enable signal
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		rd_oe_delay_cnt <= 1'b0;
	end else if(current_stream_out_state == stream_out_read) begin
		rd_oe_delay_cnt <= 1'b1;
        end else if((current_stream_out_state == stream_out_read_rd_and_oe_delay) & (rd_oe_delay_cnt > 1'b0))begin
		rd_oe_delay_cnt <= rd_oe_delay_cnt - 1'b1;
	end else begin
		rd_oe_delay_cnt <= rd_oe_delay_cnt;
	end	
end

//Counter to delay the OUTPUT Enable(oe) signal
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		oe_delay_cnt <= 2'd0;
	end else if(current_stream_out_state == stream_out_read_rd_and_oe_delay) begin
		oe_delay_cnt <= 2'd2;
        end else if((current_stream_out_state == stream_out_read_oe_delay) & (oe_delay_cnt > 1'b0))begin
		oe_delay_cnt <= oe_delay_cnt - 1'b1;
	end else begin
		oe_delay_cnt <= oe_delay_cnt;
	end	
end

//streamOUT mode state machine
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		current_stream_out_state <= stream_out_idle;
	end else begin
		current_stream_out_state <= next_stream_out_state;
	end	
end

//steamOUT mode state machine combo
always @(*)begin
	next_stream_out_state = current_stream_out_state;
	case(current_stream_out_state)
	stream_out_idle:begin
		if((stream_out_mode_selected) & (flagc_d == 1'b1))begin
			next_stream_out_state = stream_out_flagc_rcvd;
		end else begin
			next_stream_out_state = stream_out_idle;
		end
	end	
        stream_out_flagc_rcvd:begin
		next_stream_out_state = stream_out_wait_flagd;
	end	
	stream_out_wait_flagd:begin
		if(flagd_d == 1'b1)begin
			next_stream_out_state = stream_out_read;
		end else begin
			next_stream_out_state = stream_out_wait_flagd;
		end
	end	
        stream_out_read :begin
                if(flagd_d == 1'b0)begin
			next_stream_out_state = stream_out_read_rd_and_oe_delay;
		end else begin
			next_stream_out_state = stream_out_read;
		end
	end
	stream_out_read_rd_and_oe_delay : begin
		if(rd_oe_delay_cnt == 0)begin
			next_stream_out_state = stream_out_read_oe_delay;
		end else begin
			next_stream_out_state = stream_out_read_rd_and_oe_delay;
		end
	end
        stream_out_read_oe_delay : begin
		if(oe_delay_cnt == 0)begin
			next_stream_out_state = stream_out_idle;
		end else begin
			next_stream_out_state = stream_out_read_oe_delay;
		end
	end
	endcase
end

endmodule
