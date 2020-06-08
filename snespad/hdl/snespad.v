`timescale 1ns/1ps

`ifdef COCOTB_SIM
    `define RST_EXT
`endif

module SNesPad #(
`ifdef COCOTB_SIM
    parameter CLK_PER_NS = 5000,
`else
    parameter CLK_PER_NS = 40,
`endif
    parameter REG_SIZE = 16
)(
    input clk_i,
`ifdef RST_EXT
    input rst_i,
`endif
    // snes pad
    output dclock_o,
    output dlatch_o,
    input sdata_i,
    // data output
    output reg [REG_SIZE-1:0] vdata_o
);

`ifndef RST_EXT 
/* autogenerate reset in synthesis*/
reg rst_i;
rst_gen rst_inst (.clk_i(clk_i), .rst_i(1'b0), .rst_o(rst_i));
`endif


`define HMS 500_000

reg [15:0] tmpdata;
reg [4:0] indexcnt;

/***********/
/* Counter */
/***********/
/* half_ms counter : one pulse each half milisecond */
`define HMS_COUNTER_SIZE ($clog2(1 + (`HMS/CLK_PER_NS)))
reg [`HMS_COUNTER_SIZE-1:0] hmscounter;
reg hms_pulse;

always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        hmscounter <= 0;
        hms_pulse <= 1'b1;
    end else begin
        hms_pulse <= 1'b0;
        /* verilator lint_off WIDTH */
        if(hmscounter >= (`HMS/CLK_PER_NS))
        /* verilator lint_on WIDTH */
        begin
            hmscounter <= 0;
            hms_pulse <= 1'b1;
        end else begin
            hmscounter <= hmscounter + 1'b1;
        end
    end
end

/* external input synchronization */
reg sdata_tmp, sdata_s;
always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        sdata_tmp <= 1'b0;
        sdata_s <= 1'b0;
    end
    else begin
        sdata_tmp <= sdata_i;
        sdata_s <= sdata_tmp;
    end
end


/*****************/
/* State machine */
/*****************/
localparam [2:0] s_init   = 3'b000,
                 s_latch  = 3'b001,
                 s_schigh = 3'b010,
                 s_sclow  = 3'b011,
                 s_valid  = 3'b100;

reg [2:0] state_reg, state_next;

always @(posedge clk_i or posedge rst_i)
    if(rst_i)
        state_reg <= s_init;
    else
        state_reg <= state_next;

always @*
begin
    case(state_reg)
        s_init:
            if(hms_pulse)
                state_next = s_latch;
            else
                state_next = state_reg;
        s_latch:
            if(hms_pulse)
                state_next = s_sclow;
            else
                state_next = state_reg;
        s_sclow:
            if(hms_pulse)
            begin
                if(indexcnt == (REG_SIZE - 1))
                    state_next = s_valid;
                else
                    state_next = s_schigh;
            end else
                state_next = state_reg;
        s_schigh:
            if(hms_pulse)
                state_next = s_sclow;
            else
                state_next = state_reg;

        s_valid:
            if(hms_pulse)
                state_next = s_init;
            else
                state_next = state_reg;
        default:
            state_next = s_init;
    endcase;
end

/* update tmp register */
always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i) begin
        tmpdata <= 0;
        indexcnt <= 0;
    end else begin
        if(hms_pulse) begin
            if(state_reg == s_latch) begin
                tmpdata <= {tmpdata[14:0], sdata_s};
            end
            else if(state_reg == s_schigh) begin
                indexcnt <= indexcnt + 1'b1;
                tmpdata <= {tmpdata[14:0], sdata_s};
            end
            else if(state_reg == s_init)
            begin
                indexcnt <= 0;
                tmpdata <= 0;
            end
            else if(state_reg == s_valid)
            begin
                vdata_o <= tmpdata;
            end
        end
    end
end

assign dclock_o = (state_reg == s_schigh);
assign dlatch_o = (state_reg == s_init || state_reg == s_latch);


`ifdef COCOTB_SIM
initial begin
  $dumpfile ("SNesPad.vcd");
  $dumpvars (0, SNesPad);
`ifdef ICARUS_SIM
  #1;
`endif
end
`endif

endmodule
