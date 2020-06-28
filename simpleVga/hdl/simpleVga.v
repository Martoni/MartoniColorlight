`timescale 1ps/1ps
/* SimpleVga generator
* 640 x 480 with 25Mhz clock
* Widely inspired by fpga4fun :
* https://www.fpga4fun.com/PongGame.html
*/

module SimpleVga #(
    parameter CLK_PER_NS = 40
)
(
    input clk_i,
//    input rst_i,
    // VGA output
    output red_o,
    output green_o,
    output blue_o,
    output vsync_o,
    output hsync_o
);


/* autogenerate reset */
reg reset;
rst_gen rst_inst (.clk_i(clk_i), .rst_i(1'b0), .rst_o(reset));

wire display_on;
wire [9:0] hpos;
wire [8:0] vpos;

/* hvsync */
HVSync hvs(
    .clk_i(clk_i),
    .rst_i(reset),
    .hsync_o(hsync_o),
    .vsync_o(vsync_o),
    .display_on,
    .hpos(hpos),
    .vpos(vpos)
);

localparam SQWIDTH = 2;
localparam HWIDTH = 640;
localparam VWIDTH = 480;

wire square =    ((hpos >= 0) && (hpos <= SQWIDTH))
              || ((hpos <= (HWIDTH - 1)) && (hpos >= (HWIDTH - SQWIDTH - 1)))
              || ((vpos >= 0) && (vpos <= SQWIDTH))
			  || ((vpos <= VWIDTH - 1) && (vpos >= VWIDTH - SQWIDTH - 1));


assign red_o = display_on & ((hpos % 3 == 0) | square);
assign green_o = display_on & ((hpos % 3 == 1) | square);
assign blue_o = display_on & ((hpos % 3 == 2) | square);

/* 640 x 480 : X * Y */

endmodule
