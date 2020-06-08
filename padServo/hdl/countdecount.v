`timescale 1ns/1ps

module CountDeCount #(
    parameter OUT_REG_SIZE = 8,
    parameter INT_REG_SIZE = 64
)(
    input clk_i,
    input rst_i,
    //increment/decrement driver
    input inc_i,
    input dec_i,
    // position output
    output reg [OUT_REG_SIZE-1:0] pos_o
);

reg [INT_REG_SIZE-1:0] counter;
assign pos_o = counter[INT_REG_SIZE-1:INT_REG_SIZE-OUT_REG_SIZE];

always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        counter = {INT_REG_SIZE{1'b0}};
    end
    else begin
        if(inc_i & !dec_i & (counter < {INT_REG_SIZE{1'b1}}))
            counter <= counter + 1'b1;
        else if(!inc_i & dec_i & (counter > {INT_REG_SIZE{1'b0}}))
            counter <= counter - 1'b1;
    end
end

endmodule
