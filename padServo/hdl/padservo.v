`timescale 1ns/1ps

`define RIGHTARROW 8 
`define LEFTARROW 9

module PadServo #(
`ifdef COCOTB_SIM
    parameter CLK_PER_NS = 5000
`else
    parameter CLK_PER_NS = 40
`endif
)(
    input clk_i,
    // snes pad
    output dclock_o,
    output dlatch_o,
    input sdata_i,
    // servo out
    output srv_o,
    // debug led
    //output led_o
);

// Generate reset
reg reset;
rst_gen rst_inst (.clk_i(clk_i), .rst_i(1'b0), .rst_o(reset));
`define RST_EXT

wire [15:0] snes_reg;

//assign led_o = snes_reg[0];

// Super NES pad controller
SNesPad #(
    .CLK_PER_NS(CLK_PER_NS),
    .REG_SIZE(16)
) snespad (
    .clk_i(clk_i),
    .rst_i(reset),
    .dclock_o(dclock_o),
    .dlatch_o(dlatch_o),
    .sdata_i(sdata_i),
    .vdata_o(snes_reg)
);

wire [7:0] position;

// CountDeCount
CountDeCount #(
    .OUT_REG_SIZE(8),
    .INT_REG_SIZE(24),
) cdct (
    .clk_i(clk_i),
    .rst_i(reset),
    .inc_i(snes_reg[`RIGHTARROW]),
    .dec_i(snes_reg[`LEFTARROW]),
    .pos_o(position)
);

//servo
SimpleServo sso (
    .clk_i(clk_i),
    .rst_i(reset),
    .en_i(1'b1),
    .position_i(position),
    .srv_o(srv_o)
);

endmodule
