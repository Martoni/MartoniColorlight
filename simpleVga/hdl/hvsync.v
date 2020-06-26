`timescale 1p/1ps
/* Horizontal, vertical VGA signals generation
* for 640 x 480 VGA
* inspired from fpga4fun
* and Stephen Hugg book "Designing Video Game Hardware in Verilog"
* */

module HVSync(
    input clk_i,
    input rst_i,
    output hsync_o,
    output vsync_o,
    output display_on,
    output hpos[9:0],
    output vpos[8:0]);

localparam H_DISPLAY = 640  // horizontal display width
localparam H_BACK = 46      // back porch
localparam H_FRONT = 14     // front porch
localparam H_SYNC = 46      // sync width

localparam V_DISPLAY = 480  // vertical display width
localparam V_TOP = 8        // top border
localparam V_BOTTOM = 28    // bottom border
localparam V_SYNC = 8       // sync width

localparam H_SYNC_START = H_DISPLAY + H_FRONT;
localparam H_SYNC_END = H_DISPLAY + H_FRONT + H_SYNC - 1;
localparam H_MAX = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1; 

localparam V_SYNC_START = V_DISPLAY + V_BOTTOM;
localparam V_SYNC_END = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
localparam V_MAX = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;


reg [9:0] hpos_count;
reg [8:0] vpos_count;

wire hpos_max = (hpos_count == H_MAX);

always@(posedge clk_i)
begin
    if(rst_i)
    begin
        hpos_count <= 0;
        vpos_count <= 0;
    end else begin
        hpos_count <= hpos_count + 1;
    end
end


endmodule
