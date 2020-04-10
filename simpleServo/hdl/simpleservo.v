`timescale 1ps/1ps

module SimpleServo #(
    parameter CLK_PER_NS = 40,
    parameter N = 8
)
(
    input clk_i,
    input rst_i,
    input en_i,
    input [N-1:0] position_i,
    output srv_o
);

`define MS 1_000_000

/************/
/* Counters */
/************/
/* ms counter : one pulse each milisecond*/
`define MS_COUNTER_SIZE ($clog2(1 + (`MS/CLK_PER_NS)))
reg [`MS_COUNTER_SIZE-1:0] mscounter;
reg ms_pulse;
always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        mscounter <= 0;
        ms_pulse <= 1'b0;
    end
    else
        begin
            ms_pulse <= 1'b0;
            if(!en_i)
                mscounter <= 0;
            /* verilator lint_off WIDTH */
            else if(mscounter >= (`MS/CLK_PER_NS))
            /* verilator lint_on WIDTH */
            begin
                mscounter <= 0;
                ms_pulse <= 1'b1;
            end
            else 
            begin
                mscounter <= mscounter + 1'b1;
            end
                
        end
end

/* 18 ms counter */
reg [7:0] counter18ms;
always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
        counter18ms <= 0;
    else if(state_reg == s_low18ms)
        begin
            if(ms_pulse)
                counter18ms <= counter18ms + 1'b1;
        end
    else
        counter18ms <= 0;
end

/* pulse period counter */
`define PULSE_COUNTER_SIZE ($clog2(1 + ((`MS/CLK_PER_NS)/2**N)))
reg [`PULSE_COUNTER_SIZE-1:0] pulsecounter;
reg [N-1: 0] pulsecount;
always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i)
    begin
        pulsecount <= 0;
        pulsecounter <= 0;
    end
    else
        if (state_reg == s_pulseon || state_reg == s_pulseoff)
           begin
               /* verilator lint_off WIDTH */
               if(pulsecounter >= ((`MS/CLK_PER_NS)/(2**N)))
               /* verilator lint_on WIDTH */
               begin
                   pulsecounter <= 0;
                   pulsecount <= pulsecount + 1;
               end
               else
                   pulsecounter <= pulsecounter + 1;
           end
        else
        begin
            pulsecounter <= 0;
            pulsecount <= 0;
        end
end




/*****************/
/* State machine */
/*****************/
localparam [2:0] s_init     = 3'h0,
                 s_pulse1ms = 3'h1,
                 s_pulseon  = 3'h2,
                 s_pulseoff = 3'h3,
                 s_low18ms  = 3'h4;

reg [2:0] state_reg, state_next;

always @(posedge clk_i or posedge rst_i)
    if(rst_i)
        state_reg <= s_init;
    else
        state_reg <= state_next;

always @*
begin
    case(state_reg)
        s_init: if(ms_pulse)
            state_next = s_pulse1ms;
        s_pulse1ms:
            if(!en_i)
                state_next = s_init;
            else if(ms_pulse)
                state_next = s_pulseon;
        s_pulseon :
            if(!en_i)
                state_next = s_init;
            else if(pulsecount >= position_i)
                state_next = s_pulseoff;
        s_pulseoff:
            if(!en_i)
                state_next = s_init;
            else if(ms_pulse)
                state_next = s_low18ms;
        s_low18ms :
            if(!en_i)
                state_next = s_init;
            else if(counter18ms >= 20 - 3)
                state_next = s_init;
        default:
            state_next = s_init;
    endcase;
end
/***********/
/* Outputs */
/***********/

assign srv_o = en_i && ((state_reg == s_pulse1ms) || (state_reg == s_pulseon));


`ifdef FORMAL
/***********/
/* Formal  */
/***********/

always @(posedge clk_i)
    if(!en_i)
        assert(srv_o == 1'b0);

`endif //FORMAL

`ifdef COCOTB_SIM
initial begin
  $dumpfile ("SimpleServo.vcd");
  $dumpvars (0, SimpleServo);
`ifdef ICARUS_SIM
  #1;
`endif
end
`endif

endmodule
