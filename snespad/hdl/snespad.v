`timescale 1ps/1ps

module SNesPad #(
    parameter CLK_PER_NS = 40
)
(
    input clk_i,
    input rst_i,
    // snes pad
    output dclock_o,
    output dlatch_o,
    input sdata_i,
    // data output
    output reg [15:0] vdata_o
);

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

/*****************/
/* State machine */
/*****************/
localparam [1:0] s_init   = 2'b00,
                 s_schigh = 2'b01,
                 s_sclow  = 2'b10,
                 s_valid  = 2'b11;

reg [1:0] state_reg, state_next;

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
                state_next = s_schigh;
            else
                state_next = state_reg;
        s_schigh:
            if(hms_pulse)
                state_next = s_sclow;
            else
                state_next = state_reg;
        s_sclow:
            if(hms_pulse)
            begin
                if(indexcnt == 16)
                    state_next = s_valid;
                else
                    state_next = s_schigh;
            end else
                state_next = state_reg;
        s_valid:
            state_next = s_init;
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
            if(state_reg == s_schigh) begin
                indexcnt <= indexcnt + 1'b1;
                tmpdata <= {tmpdata[14:0], sdata_i};
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
assign dlatch_o = (state_reg == s_init);


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
