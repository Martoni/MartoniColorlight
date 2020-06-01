module topServo (
    input clk_i,
    output reg srv_o
);

reg reset;
rst_gen rst_inst (.clk_i(clk_i), .rst_i(1'b0), .rst_o(reset));

SimpleServo sso (
    .clk_i(clk_i),
    .rst_i(reset),
    .en_i(1'b1),
    .position_i(8'hFF),
    .srv_o(srv_o));


endmodule
