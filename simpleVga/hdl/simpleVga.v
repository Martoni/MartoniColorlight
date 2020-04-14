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

/* 640 x 480 : X * Y */
reg [9:0] CounterX;
reg [8:0] CounterY;
wire CounterXmaxed = (CounterX==767);

always @(posedge clk_i)
if(CounterXmaxed)
  CounterX <= 0;
else
  CounterX <= CounterX + 1;

always @(posedge clk_i)
if(CounterXmaxed)
    CounterY <= CounterY + 1;

reg vga_HS, vga_VS;
always @(posedge clk_i)
begin
  vga_HS <= (CounterX[9:4]==0);   // active for 16 clocks
  vga_VS <= (CounterY==0);   // active for 768 clocks
end

assign hsync_o = ~vga_HS;
assign vsync_o = ~vga_VS;

/* draw something simple */
assign red_o = CounterY[3] | (CounterX==256);
assign green_o = (CounterX[5] ^ CounterX[6]) | (CounterX==256);
assign blue_o = CounterX[4] | (CounterX==256);

`ifdef FORMAL
/***********/
/* Formal  */
/***********/

`endif //FORMAL

`ifdef COCOTB_SIM
initial begin
  $dumpfile ("SimpleVga.vcd");
  $dumpvars (0, SimpleVga);
`ifdef ICARUS_SIM
  #1;
`endif
end
`endif

endmodule
