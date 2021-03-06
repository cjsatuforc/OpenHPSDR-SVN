/*
  This module is used to check the data flow in and out of the RX FIFO in Ozy_Janus.v
  to see that it matches the defined FPGA Test Mode data stream.  If not it generates
  an error called tmc_err which can then be used to flash a code on an LED
*/

`timescale 1 ns/100 ps

module TestModeCheck (rst, clk, sync_state, data_in, wrreq, data_out, rdreq, used, xrdy, C23, tmc_err);
input  wire        rst;
input  wire        clk;
input  wire  [2:0] sync_state;
input  wire [15:0] data_in;
input  wire        wrreq;
input  wire [15:0] data_out;
input  wire        rdreq;
input  wire [12:0] used;
input  wire        xrdy;  // should occur once every 48Khz - M_LR_Sync
input  wire        C23;   // M_LR_Sync
output wire        tmc_err;

localparam SYNC_IDLE   = 0,  // these need to be the same as in Ozy_janus.v
           SYNC_START  = 1,
           SYNC_RX_1_2 = 2,
           SYNC_RX_3_4 = 3,
           SYNC_RX     = 4,
           SYNC_FINISH = 5;

localparam TMC_IDLE   = 0,
           TMC_GO     = 1;



reg   [2:0] tmc_state;
reg   [2:0] tmc_state_next;
reg  [15:0] seq_in_cnt, seq_out_cnt;
reg         seq_err;
reg         rdreq_dly;
reg  [15:0] c23_cnt, xrdy_cnt;
reg         c23_dly, xrdy_dly;

assign tmc_err = seq_err || xrdy_cnt[15] || c23_cnt[15];

always @(posedge clk)
begin
  c23_dly <= C23;

  if (rst)
    c23_cnt <= 1'b0;
  else if (C23 & !c23_dly)
    c23_cnt <= 1'b0; // clear for half the cycle
  else
    c23_cnt <= c23_cnt + 1'b1;  // should only count up to 48Mhz/48Khz = 1000/2 ('h3E8/2)

  xrdy_dly <= xrdy;

  if (rst)
    xrdy_cnt <= 1'b0;
  else if (xrdy & !xrdy_dly)
    xrdy_cnt <= 1'b0;
  else
    xrdy_cnt <= xrdy_cnt + 1'b1;  // should only count up to 48Mhz/48Khz = 1000 ('h3E8)

  if (rst)
    tmc_state <= TMC_IDLE;
  else
    tmc_state <= tmc_state_next;
  
  rdreq_dly <= rdreq; // data comes out AFTER rdreq

  if (rst)
    seq_out_cnt <= 1;
  else if (rdreq_dly)
  begin
    if (seq_out_cnt == 9'h0FC)
      seq_out_cnt <= 1;
    else
      seq_out_cnt <= seq_out_cnt + 1'b1;
  end

  if (rst)
    seq_in_cnt <= 1'b1;
  else if (tmc_state == TMC_GO)
  begin
    if (wrreq)
    begin
      if (seq_in_cnt == 9'h0FC)  // data in sequence count goes from 0 to FC
        seq_in_cnt <= 1'b1;
      else
        seq_in_cnt <= seq_in_cnt + 1'b1;
    end
  end
  else // some error occured so wait for resync and start again
    seq_in_cnt <= 1'b1;

  if (rst)
    seq_err <= 1'b0;
  else if (tmc_state == TMC_GO)
  begin
    if (wrreq && (seq_in_cnt != data_in))   // data out sequence count goes from 4 to FF
       seq_err <= 1'b1;
    else if (rdreq_dly && (seq_out_cnt != data_out))
       seq_err <= 1'b1;
    else
       seq_err <= 1'b0;
  end
  else
    seq_err <= 1'b0;
end

always @*
begin
  case(tmc_state)
    TMC_IDLE: // wait until sync_state is in the SYNC_RX_1_2 state
    begin
      if (sync_state != SYNC_RX_1_2)
        tmc_state_next = TMC_IDLE;
      else
        tmc_state_next = TMC_GO;
    end

    TMC_GO: // continue to check data sequence
    begin
      if (seq_err || (sync_state == SYNC_IDLE))
        tmc_state_next = TMC_IDLE;
      else
        tmc_state_next = TMC_GO;
    end

    default:
      tmc_state_next = TMC_IDLE;
  endcase
end

endmodule