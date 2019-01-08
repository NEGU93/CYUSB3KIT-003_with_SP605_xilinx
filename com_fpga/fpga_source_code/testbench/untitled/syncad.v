// TestBencher Pro file -- syncad.v
// Used by Verilog template files isotbench.v and tbench.v

`define TB_ABORT   3'b000
`define TB_ONCE    3'b001
`define TB_DONE    3'b010
`define TB_LOOPING 3'b011
`define TB_RESTART 3'b100
`define TB_END     3'b101

`define TB_FALSE   1'b0
`define TB_TRUE    1'b1


`define DOWAIT	1'b1
`define DONTWAIT  1'b0
// end syncad.v
