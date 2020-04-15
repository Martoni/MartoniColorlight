`timescale 1ps/1ps

module SNesPad #(
    parameter CLK_PER_NS = 40
)
(
    input clk_i,
//    input rst_i,
    // snes pad
    output dclock_o,
    output dlatch_o,
    input sdata,
    // data output
    output [15:0] vdata_o,
);

/* autogenerate reset */
reg rst_i;
rst_gen rst_inst (.clk_i(clk_i), .rst_i(1'b0), .rst_o(rst_i));

//XXX
assign dclock_o = 1'b0;
assign dlatch_o = 1'b0;
assign vdata_o = 16'h0000;

endmodule
