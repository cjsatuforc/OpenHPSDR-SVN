//  26 Aug 2009  Cyclops Interface 
//
// Copyright 2009, Phil Harman VK6APH
//
// Based on Ozy_Janus V1.6 Copyright 2009 Kirk Weedman KD7IRS

//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//

// The format for data TO the PC is:-
//
//  <0x7F7F><0x7F,C0><C1,C2><C3,C4><I><I LSB,Q MSB><Q LSW><Mic data >... etc
//
// where Cn is a control byte - see protocol design document for full description.
//

                                                 

// Sync and control bytes are sent as follows:
//   <0x7F7F> <0x7F,C0> <C1,C2> <C3,C4>


// The format for data FROM the PC is the same sync & control sequence followed by 48k/16 bit data:-
//
//   <0x7F7F><0x7F,C0><C1,C2><C3,C4>< 0 >< 0 >< First LO Frequency  >< 0 > etc...
//
// A/D data is in 2's complement format.

/*  

Analog Devices ADF4112

External Reference Clock = 10 MHz from Atlas C16

Nomenclature:
The AFD4112 has four control latches, which are addressed
by the two least significant bits in the 24 bit SPI control word.

That is, the register address is implicit in the SPI control word.

RLC: "Reference Counter Latch"
NCL: "N Counter Latch", also interchangably referred to as "A B Counter Latch"
FNL: "Function Latch"    (Same control bit map as INL, but does not reset chip.)
INL: "Initialization Latch" (Same control bit map as FNL, but also resets chip.)

==

Initialization Sequence: (Three 24 bit SPI control words)
Write to INL, then RCL, then NCL.

The write to INL puts the chip into reset; 
writing to NCL releases it to run.

Once it is running and you want to change something in the INL/FNL
address control space, you address it as the FNL, not the INL.

=============================================================================


	
	Change log
	22 July 2009  - Port previous LMX2326 code to run ADF4112 
				  - Test program for ADF4112 PLL chips on Cyclops PCB, 1st LO = 1030MHz, 2nd LO = 1126MHz
    22 Aug  2009  - 2nd LO = 1126MHz, 1st LO ref = 1MHz and frequency set by data from PC via FX2
    26 Aug  2009  - First release as V1.0
    29 Aug  2009  - Start removing unwanted code. Penny S# & ALC, 48MHz to Janus, dot, dash, PTT and 
				  - debounce, Mercury S# and ADC overload, J_IQPWM, P_IQPWM, J_LRAudio, J_IQ
	30 Aug  2009  - Removed remaining unused code.
	31 Aug  2009  - Set C15 and C17 to outputs at 0V to protect 10MHz on C16
  
*/


//////////////////////////////////////////////////////////////
//
//              Quartus V9.0 Notes
//
//////////////////////////////////////////////////////////////

/*
	Quartus V9.0 -  use the following settings:
	
	- Analysis and Synthesis Settings\
		Power Up Dont Care [not checked]
	- Analysis and Synthesis Settings\More Settings
		Synthesis options for State Machine Processing  = User Encoded
	
*/


//////////////////////////////////////////////////////////////
//
//                      Pin Assignments
//
/////////////////////////////////////////////////////////////
//
//    AK5394A and LTV320AIC23B connections to OZY FPGA pins
//
//    AK_reset      - Atlas C2  - pin 149 - AK5394A reset
//    J_LR_data     - Atlas C4  - pin 151 - L/R audio to Janus in I2S format 
//    C5            - Atlas C5  - pin 152 - 12.288MHz clock from Janus
//    C6            - Atlas C6  - pin 160 - BCLK to Janus
//    C7            - Atlas C7  - pin 161 - LRCLK to Janus
//    C8            - Atlas C8  - pin 162 - CBCLK to Janus
//    C9            - Atlas C9  - pin 163 - CLRCLK to Janus
//    DOUT          - Atlas C10 - pin 164 - AK5394A
//    CDOUT         - Atlas C11 - pin 165 - Mic from TLV320 on Janus 
//    J_IQ_data     - Atlas C12 - pin 168 - I/Q audio (TLV320) to Janus in I2S format 
//    DFS0          - Atlas C13 - pin 169 - AK5394A speed setting
//    DFS1          - Atlas C14 - pin 170 - AK5394A speed setting
//    PTT_in        - Atlas C15 - pin 171 - PTT input from Janus
//                  - Atlas C16 - pin 173 - 10MHz reference 
//                  - Altas C17 - pin 175 - Master clock to Atlas for Janus etc 
//    P_IQ_data     - Atlas C19 - pin 179 - P_IQ_data (TLV320) to Penelope
//    P_IQ_sync     - Atlas C22 - pin 182 - P_IQ_sync from Penelope
//    M_LR_sync     - Atlas C23 - pin 185 - M_LR_sync from Mercury
//    M_LR_data     - Atlas C24 - pin 151 - M_LR_data to Mercury
//
//    A5            - Atlas A5  - pin 144 - Penelope NWire serial number, etc
//    A6            - Atlas A6	- pin 143 - Mercury NWire serial number, etc 
//    MDOUT	        - Atlas A10 - pin 138 - IQ from Mercury 
//    CDOUT_P       - Atlas A11 - pin 137 - Mic for TLV320 on Penelope
//    A12           = Atlas A12 - pin 135 - NWire spectrum data from Mercury 

/*
	
	Atlas 	FPGA  	
             24     IFCLK from FX2 at 48MHz 
	A13	  	134		ADF4112_2_SPI_clock
	A14    	133		ADF4112_SPI_data
	A15    	128		LE2					// Second LO
	A16		127		MUX2				// Second LO
	A17		118		LE1					// First LO
	A19		116		MUX1				// First LO	

*/



//
//
//    FX2 pin    to   FPGA pin connections
//
//    IF_clk        - pin 24
//    FX2_CLK       - pin 23
//    FX2_FD[0]     - pin 56
//    FX2_FD[1]     - pin 57
//    FX2_FD[2]     - pin 58
//    FX2_FD[3]     - pin 59
//    FX2_FD[4]     - pin 60
//    FX2_FD[5]     - pin 61
//    FX2_FD[6]     - pin 63
//    FX2_FD[7]     - pin 64
//    FX2_FD[8]     - pin 208
//    FX2_FD[9]     - pin 207
//    FX2_FD[10]    - pin 206
//    FX2_FD[11]    - pin 205
//    FX2_FD[12]    - pin 203
//    FX2_FD[13]    - pin 201
//    FX2_FD[14]    - pin 200
//    FX2_FD[15]    - pin 199
//    FLAGA         - pin 198
//    FLAGB         - pin 197
//    FLAGC         - pin 5
//    SLOE          - pin 13
//    FIFO_ADR[0]   - pin 11
//    FIFO_ADR[1]   - pin 10
//    PKEND         - pin 8
//    SLRD          - pin 30
//    SLWR          - pin 31
//
//
//   General FPGA pins
//
//    DEBUG_LED0    - pin 4
//    DEBUG_LED1    - pin 33
//    DEBUG_LED2    - pin 34
//    DEBUG_LED3    - pin 108
//
////////////////////////////////////////////////////////////////////////////////////
`timescale 1 ns/100 ps

module Cyclops(
        IF_clk, FX2_FD, FLAGA, FLAGB, FLAGC, SLWR, SLRD, SLOE, PKEND, FIFO_ADR, DOUT,
         A12, C15, C17, C21,  C23, C24,
        DEBUG_LED0,
        DEBUG_LED1, DEBUG_LED2,DEBUG_LED3, CC, MDOUT, 
        ADF4112_SPI_clock, ADF4112_SPI_data, LE1, LE2,					
        /*FX2_PE0,*/ FX2_PE1, /*FX2_PE2, FX2_PE3,*/ SDOBACK /*, TDO, TCK, TMS */ );

parameter M_TPD   = 4;
parameter IF_TPD  = 2;

localparam Ozy_serialno = 8'd11;	// Serial number of this version

localparam RX_FIFO_SZ  = 2048; // 16 by 2048 deep RX FIFO
localparam TX_FIFO_SZ  = 4096; // 16 by 4096 deep TX FIFO
localparam SP_FIFO_SZ  = 1024; // 16 by 1024 deep SP FIFO

input  wire         IF_clk;         // FX2 IF clock - 48MHz
input  wire         DOUT;           // Data from AK5394A
input  wire         MDOUT;          // I&Q data from Mercury 
inout  wire  [15:0] FX2_FD;         // bidirectional FIFO data to/from the FX2

input  wire         FLAGA;
input  wire         FLAGB;
input  wire         FLAGC;
output wire         SLWR;           // FX2 write - active low
output wire         SLRD;           // FX2 read - active low
output wire         SLOE;           // FX2 data bus enable - active low

output wire         PKEND;
output wire   [1:0] FIFO_ADR;       // FX2 register address
output wire         DEBUG_LED0;     // LEDs on OZY board
output wire         DEBUG_LED1;
output wire         DEBUG_LED2;
output wire         DEBUG_LED3;
input  wire         A12;            // NWire spectrum data from Mercury
output wire 		C15;
output wire 		C17;
output wire         C21;            // Spectrum data Trigger signal to Mercury
input  wire         C23;            // M_LR_sync from Mercury
output wire         C24;            // M_LR_data - Left & Right audio data in NWire format to Mercury

output wire         CC;             // Command and Control data to Atlas bus 

// interface pins for JTAG programming via Atlas bus
//input  wire         FX2_PE0;        // Port E on FX2
output wire         FX2_PE1;
//input  wire         FX2_PE2;
//input  wire         FX2_PE3;
input  wire         SDOBACK;        // A25 on Atlas
//output wire         TDO;            // A27 on Atlas 
//output wire         TCK;            // A24 on Atlas
//output wire         TMS;            // A23 on Atlas

// connections to Cyclops
output  ADF4112_SPI_clock;	    // SPI clock to ADF4112s
output  ADF4112_SPI_data;		// SPI data to ADF4112s
output  LE1;					// Data latch, First LO
output  LE2;


// link JTAG pins through
//assign TMS = FX2_PE3;
//assign TCK = FX2_PE2;
//assign TDO = FX2_PE0;  // TDO on our slot ties to TDI on next slot  
assign FX2_PE1 = SDOBACK;

// ground adjacent pins to C16

assign C15 = 1'b0;
assign C17 = 1'b0;


///////////////////////////////////////////////////////////////
//
//              3X clock multiplier  48MHz -> 144Mhz
//
///////////////////////////////////////////////////////////////
wire C144_clk;
wire C144_clk_locked;
reg  IF_rst, cmult_rst;

clkmult3 cm3 (.areset(cmult_rst), .inclk0(IF_clk),.c0(C144_clk), .locked(C144_clk_locked));


//////////////////////////////////////////////////////////////
//
// cmult_rst, C144_rst, IF_rst, AK_reset, C12_rst
//
/////////////////////////////////////////////////////////////

/*
        Reset AL5394A at power on and force into 48kHz sampling rate.
        Hold the A/D chip in reset until 2^28 CLK_MCLK have passed - about 3 seconds. This
        is to allow the AK4593A to calibrate correctly.
*/

reg [28:0] IF_count;
wire       C144_rst;

always @ (posedge IF_clk)
begin: IF_RESET
  reg i0;
  
  if (!IF_count[28])
    IF_count <= IF_count + 1'b1; // count up from 0 (powerup reset value) till IF_count[28] is set

  cmult_rst <= (IF_count[28:10] == 0) ? 1'b1 : 1'b0; // This will be a global power up reset for the IF_clk domain

  {IF_rst, i0} <= {i0, !C144_clk_locked}; // clock multiplier needs to be locked before any code runs
end

reg   C12_rst;
wire  C12_clk;  // 12.288 Mhz from Janus

always @ (posedge C12_clk)
begin: C12_RESET
  reg c0;
  
  {C12_rst, c0} <= {c0, !C144_clk_locked}; // clock multiplier needs to be locked before any code runs
end

assign C144_rst  = !C144_clk_locked;


reg   [1:0] IF_conf;


///////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Recieve MDOUT/DOUT and CDOUT/CDOUT_P data to put in TX FIFO
//
///////////////////////////////////////////////////////////////////////////////////////////////////////
wire [15:0] IF_P_mic_Data;
wire        IF_P_mic_Data_rdy;
wire [15:0] IF_J_mic_Data;
wire        IF_J_mic_Data_rdy;
wire [47:0] IF_M_IQ_Data;
wire        IF_M_IQ_Data_rdy;
wire [47:0] IF_J_IQ_Data;
wire        IF_J_IQ_Data_rdy;
reg   [3:0] IF_clock_s;
wire [63:0] IF_tx_IQ_mic_data;
reg         IF_tx_IQ_mic_rdy;
wire        IF_tx_IQ_mic_ack;
wire [47:0] IF_IQ_Data;
wire [15:0] IF_mic_Data;

always @*
begin
  if (IF_rst)
    IF_tx_IQ_mic_rdy = 1'b0;
  else if (IF_conf[1])
    IF_tx_IQ_mic_rdy = IF_M_IQ_Data_rdy;
end

assign IF_IQ_Data    = IF_M_IQ_Data;


// ***** this needs to be left - find out why later *****
assign IF_tx_IQ_mic_data = {IF_IQ_Data, IF_mic_Data};




NWire_rcv #(.DATA_BITS(48), .ICLK_FREQ(144000000), .XCLK_FREQ(48000000), .SLOWEST_FREQ(20000))
    M_IQ (.irst(C144_rst), .iclk(C144_clk), .xrst(IF_rst), .xclk(IF_clk),
           .xrcv_rdy(IF_M_IQ_Data_rdy), .xrcv_ack(IF_tx_IQ_mic_ack),
           .xrcv_data(IF_M_IQ_Data), .din(MDOUT) );


///////////////////////////////////////////////////////////////
//
//     Tx_fifo Control - creates IF_tx_fifo_wdata and IF_tx_fifo_wreq signals
//
//////////////////////////////////////////////////////////////
localparam RFSZ = clogb2(RX_FIFO_SZ-1);  // number of bits needed to hold 0 - (RX_FIFO_SZ-1)
localparam TFSZ = clogb2(TX_FIFO_SZ-1);  // number of bits needed to hold 0 - (TX_FIFO_SZ-1)
localparam SFSZ = clogb2(SP_FIFO_SZ-1);  // number of bits needed to hold 0 - (SP_FIFO_SZ-1)

wire     [15:0] IF_tx_fifo_wdata;   // AK5394A A/D uses this to send its data to Tx FIFO
wire            IF_tx_fifo_wreq;    // set when we want to send data to the Tx FIFO
wire            IF_tx_fifo_full;
wire [TFSZ-1:0] IF_tx_fifo_used;
wire     [15:0] IF_tx_fifo_rdata;
wire            IF_tx_fifo_rreq;
wire            IF_tx_fifo_empty;

wire [RFSZ-1:0] IF_Rx_fifo_used;    // read side count
wire            IF_Rx_fifo_full;

wire   [RFSZ:0] RX_USED;
wire            IF_tx_fifo_clr;

assign RX_USED = {IF_Rx_fifo_full,IF_Rx_fifo_used};

Tx_fifo_ctrl #(RX_FIFO_SZ, TX_FIFO_SZ) TXFC 
           (IF_rst, IF_clk, IF_tx_fifo_wdata, IF_tx_fifo_wreq, IF_tx_fifo_full, IF_tx_fifo_used,
            IF_tx_fifo_clr, IF_tx_IQ_mic_rdy, IF_tx_IQ_mic_ack,
            IF_tx_IQ_mic_data, 1'b0, 1'b0, 1'b0, 1'b0,
            8'b0, 8'b0, 8'b0, 12'b0);

///////////////////////////////////////////////////////////////
//
//     Tx_fifo (4096 words) single clock FIFO  - Altera Megafunction
//
//////////////////////////////////////////////////////////////


// NOTE: Reset Tx_fifo when {IF_DFS1,IF_DFS0} changes!!!???
Tx_fifo TXF (.sclr(IF_rst || IF_tx_fifo_clr), .clock (IF_clk), .full(IF_tx_fifo_full), 
             .empty(IF_tx_fifo_empty), .usedw(IF_tx_fifo_used),
             .wrreq (IF_tx_fifo_wreq), .data (IF_tx_fifo_wdata),
             .rdreq (IF_tx_fifo_rreq), .q    (IF_tx_fifo_rdata) );


/////////////////////////////////////////////////////////////
//
//   Rx_fifo  (2048 words) single clock FIFO - Altera Megafunction
//
/////////////////////////////////////////////////////////////

/*
        The FIFO is 2048 words long.
        NB: The output flags are only valid after a read/write clock has taken place
*/

wire [15:0] IF_Rx_fifo_rdata;
reg         IF_Rx_fifo_rreq;    // controls reading of fifo

wire [15:0] IF_Rx_fifo_wdata;
reg         IF_Rx_fifo_wreq;

// NOTE: Reset Rx_fifo when {IF_DFS1,IF_DFS0} changes!!!???
RFIFO RXF (.rst(IF_rst), .clk (IF_clk), .full(IF_Rx_fifo_full), .usedw(IF_Rx_fifo_used),
             .wrreq (IF_Rx_fifo_wreq), .data (IF_Rx_fifo_wdata), 
             .rdreq (IF_Rx_fifo_rreq), .q    (IF_Rx_fifo_rdata) );

/////////////////////////////////////////////////////////////
//
//   SP_fifo  (1024 words) single clock FIFO - Altera Megafunction
//
/////////////////////////////////////////////////////////////

/*
        The spectrum data FIFO is 16 by 1024 words long.
        NB: The output flags are only valid after a read/write clock has taken place
*/

wire     [15:0] sp_fifo_rdata;
wire            sp_fifo_rreq;    // controls reading of fifo

wire     [15:0] sp_fifo_wdata;
reg             sp_fifo_wreq;

wire            sp_fifo_full;
wire            sp_fifo_empty;
wire [SFSZ-1:0] sp_fifo_used;    // read side count

SP_fifo SPF (.sclr(IF_rst), .clock (IF_clk), .full(sp_fifo_full), .usedw(sp_fifo_used),
             .wrreq (sp_fifo_wreq), .data (sp_fifo_wdata), .rdreq (sp_fifo_rreq),
             .q(sp_fifo_rdata) );

///////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Receive Spectrum Data from Mercury
//
///////////////////////////////////////////////////////////////////////////////////////////////////////
wire spd_rdy;
reg  spd_ack;
wire trigger;

always @(posedge IF_clk)
begin
  if (IF_rst)
    spd_ack <= #IF_TPD 1'b0;
  else
    spd_ack <= spd_rdy; // one IF_clk delay

  if (IF_rst)
    sp_fifo_wreq <= #IF_TPD 1'b0;
  else
    sp_fifo_wreq <= spd_rdy & !spd_ack;
end

NWire_rcv #(.DATA_BITS(16), .ICLK_FREQ(144000000), .XCLK_FREQ(48000000), .SLOWEST_FREQ(80000))
       SPD (.irst(C144_rst), .iclk(C144_clk), .xrst(IF_rst), .xclk(IF_clk),
            .xrcv_rdy(spd_rdy), .xrcv_ack(spd_ack), .xrcv_data(sp_fifo_wdata), .din(A12) );

assign C21 = trigger;

sp_rcv_ctrl SPC (.rst(IF_rst), .clk(IF_clk), .trigger(trigger), .fifo_wreq(sp_fifo_wreq),
                 .flag(FLAGB));

//////////////////////////////////////////////////////////////
//
//   Interface to FX2 USB interface and FIFOs
//
//////////////////////////////////////////////////////////////
wire IF_Rx_fifo_drdy;

async_usb #(3, RX_FIFO_SZ, 64, TX_FIFO_SZ, 256, SP_FIFO_SZ, 64)
          usb1 (IF_clk, IF_rst, FX2_FD, FLAGA, FLAGB, FLAGC, SLWR, SLRD, SLOE, PKEND, FIFO_ADR,
          IF_Rx_fifo_drdy, IF_Rx_fifo_wdata, IF_Rx_fifo_used, IF_Rx_fifo_full,
          IF_tx_fifo_rreq, IF_tx_fifo_rdata, IF_tx_fifo_used, IF_tx_fifo_full,
          sp_fifo_rreq, sp_fifo_rdata, sp_fifo_used, sp_fifo_full);

//////////////////////////////////////////////////////////////
//
//   Sync and  C&C  Detector
//
//////////////////////////////////////////////////////////////

/*

  Read the value of IF_Rx_fifo_wdata whenever IF_Rx_fifo_wreq is set.
  Look for sync and if found decode the C&C data.
  Then send subsequent data to Rx FIF0 until end of frame.
	
*/

reg   [2:0] IF_SYNC_state;
reg   [2:0] IF_SYNC_state_next;
reg   [7:0] IF_SYNC_frame_cnt; // 256-4 words = 252 words
reg   [7:0] IF_Rx_ctrl_0;   // control C0 from PC
reg   [7:0] IF_Rx_ctrl_1;   // control C1 from PC
reg   [7:0] IF_Rx_ctrl_2;   // control C2 from PC
reg   [7:0] IF_Rx_ctrl_3;   // control C3 from PC
reg   [7:0] IF_Rx_ctrl_4;   // control C4 from PC

localparam SYNC_IDLE   = 1'd0,
           SYNC_START  = 1'd1,
           SYNC_RX_1_2 = 2'd2,
           SYNC_RX_3_4 = 2'd3,
           SYNC_RX     = 3'd4,
           SYNC_FINISH = 3'd5;

always @ (posedge IF_clk)
begin
  if (IF_rst)
    IF_SYNC_state <= #IF_TPD SYNC_IDLE;
  else
    IF_SYNC_state <= #IF_TPD IF_SYNC_state_next;

  if (IF_Rx_fifo_drdy && (IF_SYNC_state == SYNC_START) && (IF_Rx_fifo_wdata[15:8] == 8'h7F))
    IF_Rx_ctrl_0  <= #IF_TPD IF_Rx_fifo_wdata[7:0];

  if (IF_Rx_fifo_drdy && (IF_SYNC_state == SYNC_RX_1_2))
  begin
    IF_Rx_ctrl_1  <= #IF_TPD IF_Rx_fifo_wdata[15:8];
    IF_Rx_ctrl_2  <= #IF_TPD IF_Rx_fifo_wdata[7:0];
  end

  if (IF_Rx_fifo_drdy && (IF_SYNC_state == SYNC_RX_3_4))
  begin
    IF_Rx_ctrl_3  <= #IF_TPD IF_Rx_fifo_wdata[15:8];
    IF_Rx_ctrl_4  <= #IF_TPD IF_Rx_fifo_wdata[7:0];
  end

  if (IF_SYNC_state == SYNC_START)
    IF_SYNC_frame_cnt <= 0;					    // reset sync counter
  else if (IF_Rx_fifo_drdy && (IF_SYNC_state == SYNC_FINISH))
    IF_SYNC_frame_cnt <= IF_SYNC_frame_cnt + 1'b1;
end

always @*
begin
  case (IF_SYNC_state)
    // state SYNC_IDLE  - loop until we find start of sync sequence
    SYNC_IDLE:
    begin
      IF_Rx_fifo_wreq  = 1'b0;             // Note: Sync bytes not saved in Rx_fifo

      if (IF_rst || !IF_Rx_fifo_drdy)              
        IF_SYNC_state_next = SYNC_IDLE;    // wait till we get data from PC
      else if (IF_Rx_fifo_wdata == 16'h7F7F)
        IF_SYNC_state_next = SYNC_START;   // possible start of sync
      else
        IF_SYNC_state_next = SYNC_IDLE;
    end	

    // check for 0x7F  sync character & get Rx control_0 
    SYNC_START:
    begin
      IF_Rx_fifo_wreq  = 1'b0;             // Note: Sync bytes not saved in Rx_fifo

      if (!IF_Rx_fifo_drdy)              
        IF_SYNC_state_next = SYNC_START;   // wait till we get data from PC
      else if (IF_Rx_fifo_wdata[15:8] == 8'h7F)
        IF_SYNC_state_next = SYNC_RX_1_2;  // have sync so continue
      else
        IF_SYNC_state_next = SYNC_IDLE;    // start searching for sync sequence again
    end

    
    SYNC_RX_1_2:                        // save Rx control 1 & 2
    begin
      IF_Rx_fifo_wreq  = 1'b0;             // Note: Rx control 1 & 2 not saved in Rx_fifo

      if (!IF_Rx_fifo_drdy)              
        IF_SYNC_state_next = SYNC_RX_1_2;  // wait till we get data from PC
      else
        IF_SYNC_state_next = SYNC_RX_3_4;
    end

    SYNC_RX_3_4:                        // save Rx control 3 & 4
    begin
      IF_Rx_fifo_wreq  = 1'b0;             // Note: Rx control 3 & 4 not saved in Rx_fifo

      if (!IF_Rx_fifo_drdy)              
        IF_SYNC_state_next = SYNC_RX_3_4;  // wait till we get data from PC
      else
        IF_SYNC_state_next = SYNC_RX;
    end

    SYNC_RX:                            // save Rx control bytes during this state
    begin
      IF_Rx_fifo_wreq  = 1'b0;

      IF_SYNC_state_next = SYNC_FINISH;
    end

    // Remainder of data goes to Rx_fifo, re-start looking
    // for a new SYNC at end of this frame.
    SYNC_FINISH:
    begin
      IF_Rx_fifo_wreq  = IF_Rx_fifo_drdy;

      if (IF_SYNC_frame_cnt == ((512-8)/2)) // frame ended, go get sync again
        IF_SYNC_state_next = SYNC_IDLE;
      else
        IF_SYNC_state_next = SYNC_FINISH;
    end

    default:
    begin
      IF_Rx_fifo_wreq  = 1'b0;

      IF_SYNC_state_next = SYNC_IDLE;
    end
	endcase
end

//////////////////////////////////////////////////////////////
//
//              Decode Command & Control data
//
//////////////////////////////////////////////////////////////

/*
	Decode IF_Rx_ctrl_0....IF_Rx_ctrl_4.

	Decode frequency (for Mercury and Penelope), PTT and Speed 

	The current frequency is set by the PC by decoding 
	IF_Rx_ctrl_1... IF_Rx_ctrl_4 when IF_Rx_ctrl_0[7:1] = 7'b0000_001
		
      The speed the AK5394A runs at, either 192k, 96k or 48k is set by
      the PC by decoding IF_Rx_ctrl_1 when IF_Rx_ctrl_0[7:1] are all zero. IF_Rx_ctrl_1
      decodes as follows:

      IF_Rx_ctrl_1 = 8'bxxxx_xx00  - 48kHz
      IF_Rx_ctrl_1 = 8'bxxxx_xx01  - 96kHz
      IF_Rx_ctrl_1 = 8'bxxxx_xx10  - 192kHz

	Decode PTT from PowerSDR. Held in IF_Rx_ctrl_0[0] as follows
	
	0 = PTT inactive
	1 = PTT active
	
	Decode clock sources, when IF_Rx_ctrl_0[7:1] = 0,  IF_Rx_ctrl_1[4:2] indicates the following
	
	x00  = 10MHz reference from Atlas bus ie Gibraltar
	x01  = 10MHz reference from Penelope
	x10  = 10MHz reference from Mercury
	0xx  = 12.288MHz source from Penelope 
	1xx  = 12.288MHz source from Mercury 
	
	Decode configuration, when IF_Rx_ctrl_0[7:1] = 0, IF_Rx_ctrl_1[6:5] indicates the following
	
	00 = No Tx Rx boards
	01 = Penelope fitted
	10 = Mercury fitted
	11 = Both Penelope and Mercury fitted
	
	Decode microphone source, when IF_Rx_ctrl_0[7:1] = 0, IF_Rx_ctrl_1[7] indicates the following
	
	0 = microphone source is Janus
	1 = microphone source is Penelope
	
	Decode Attenuator settings on Alex, when IF_Rx_ctrl_0[7:1] = 0, IF_Rx_ctrl_3[1:0] indicates the following 
	
	00 = 0dB
	01 = 10dB
	10 = 20dB
	11 = 30dB
	
	Decode ADC settings on Mercury, when IF_Rx_ctrl_0[7:1] = 0, IF_Rx_ctrl_3[4:2] indicates the following
	
	000 = Random, Dither, gain off
	1xx = Random ON
	x1x = Dither ON
	xx1 = Gain ON 
	
	Decode Rx relay settigs on Alex, when IF_Rx_ctrl_0[7:1] = 0, IF_Rx_ctrl_3[6:5] indicates the following
	
	00 = None
	01 = Rx 1
	10 = Rx 2
	11 = Transverter
	
	Decode Tx relay settigs on Alex, when IF_Rx_ctrl_0[7:1] = 0, IF_Rx_ctrl_4[1:0] indicates the following
	
	00 = Tx 1
	01 = Tx 2
	10 = Tx 3
	
	Decode Rx_1_out relay settigs on Alex, when IF_Rx_ctrl_0[7:1] = 0, IF_Rx_ctrl_3[7] indicates the following

	1 = Rx_1_out on 
	
*/

wire        PTT_out;
reg   [6:0] IF_OC;       // open collectors on Penelope
reg         IF_mode;     // normal or Class E PA operation 
reg         IF_RAND;     // when set randomizer in ADC on Mercury on
reg         IF_DITHER;   // when set dither in ADC on Mercury on
reg         IF_PGA;      // when set gain in ADC on Mercury set to 3dB else 0dB
reg   [1:0] IF_ATTEN;    // decode attenuator setting on Alex
reg   [1:0] IF_TX_relay; // Tx relay setting on Alex
reg         IF_Rout;     // Rx1 out on Alex
reg   [1:0] IF_RX_relay; // Rx relay setting on Alex 
reg  [31:0] IF_frequency [0:8]; // Penny, Merc1, Merc2, Merc3....Merc8
reg         IF_duplex;

always @ (posedge IF_clk)
begin 
  if (IF_rst)
  begin // set up default values - 0 for now
    // RX_CONTROL_1
    IF_clock_s         <= 4'b0100; // decode clock source - default Mercury
    IF_conf            <= 2'b00;   // decode configuration
    // RX_CONTROL_2
    IF_mode            <= 1'b0;    // decode mode, normal or Class E PA
    IF_OC              <= 7'b0;    // decode open collectors on Penelope
    // RX_CONTROL_3
    IF_ATTEN           <= 2'b0;    // decode Alex attenuator setting 
    IF_PGA             <= 1'b0;    // decode ADC gain high or low
    IF_DITHER          <= 1'b0;    // decode dither on or off
    IF_RAND            <= 1'b0;    // decode randomizer on or off
    IF_RX_relay        <= 2'b0;    // decode Alex Rx relays
    IF_Rout            <= 1'b0;    // decode Alex Rx_1_out relay
    // RX_CONTROL_4
    IF_TX_relay        <= 2'b0;    // decode Alex Tx Relays
    IF_duplex          <= 1'b0;    // not in duplex mode
  end
  else if (IF_SYNC_state == SYNC_RX) // all Rx_control bytes are ready to be saved
  begin 								// Need to ensure that C&C data is stable 
    if (IF_Rx_ctrl_0[7:1] == 7'b0000_000)
    begin
      // RX_CONTROL_1
      IF_clock_s[2:0]     <= IF_Rx_ctrl_1[4:2]; // decode clock source
      IF_conf             <= IF_Rx_ctrl_1[6:5]; // decode configuration
      // RX_CONTROL_2
      IF_mode             <= IF_Rx_ctrl_2[0];   // decode mode, normal or Class E PA
      IF_OC               <= IF_Rx_ctrl_2[7:1]; // decode open collectors on Penelope
      // RX_CONTROL_3
      IF_ATTEN            <= IF_Rx_ctrl_3[1:0]; // decode Alex attenuator setting 
      IF_PGA              <= IF_Rx_ctrl_3[2];   // decode ADC gain high or low
      IF_DITHER           <= IF_Rx_ctrl_3[3];   // decode dither on or off
      IF_RAND             <= IF_Rx_ctrl_3[4];   // decode randomizer on or off
      IF_RX_relay         <= IF_Rx_ctrl_3[6:5]; // decode Alex Rx relays
      IF_Rout             <= IF_Rx_ctrl_3[7];   // decode Alex Rx_1_out relay
      // RX_CONTROL_4
      IF_TX_relay         <= IF_Rx_ctrl_4[1:0]; // decode Alex Tx Relays
      IF_duplex           <= IF_Rx_ctrl_4[2];   // save duplex mode
    end
  end
end	

always @ (posedge IF_clk)
begin 
  if (IF_rst)
  begin // set up default values - 0 for now
    IF_frequency[0]    <= 32'd0;
    IF_frequency[1]    <= 32'd0;
    IF_frequency[2]    <= 32'd0;
    IF_frequency[3]    <= 32'd0;
    IF_frequency[4]    <= 32'd0;
    IF_frequency[5]    <= 32'd0;
    IF_frequency[6]    <= 32'd0;
    IF_frequency[7]    <= 32'd0;
    IF_frequency[8]    <= 32'd0;
  end
  else if (IF_SYNC_state == SYNC_RX)
  begin
    if (IF_Rx_ctrl_0[7:1] == 7'b0000_001)   // decode IF_frequency
    begin
      IF_frequency[0]   <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Penny frequency
      if (!IF_duplex)
      begin
        IF_frequency[1] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #1 frequency
        IF_frequency[2] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #2 frequency
        IF_frequency[3] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #3 frequency
        IF_frequency[4] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #4 frequency
        IF_frequency[5] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #5 frequency
        IF_frequency[6] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #6 frequency
        IF_frequency[7] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #7 frequency
        IF_frequency[8] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4}; // Mercury #8 frequency
      end
    end
    else if (IF_duplex)
    begin
      if ((IF_Rx_ctrl_0[7:1] >= 2'd2) && (IF_Rx_ctrl_0[7:1] <= 4'd9))
        IF_frequency[IF_Rx_ctrl_0[4:1] - 1'b1] <= {IF_Rx_ctrl_1, IF_Rx_ctrl_2, IF_Rx_ctrl_3, IF_Rx_ctrl_4};
    end
  end
end

assign PTT_out = IF_Rx_ctrl_0[0]; // IF_Rx_ctrl_0 only updated when we get correct sync sequence


//////////////////////////////////////////////////////////////
//
//   State Machine to manage PWM interface
//
//////////////////////////////////////////////////////////////
/*

    The code loops until there are at least 4 words in the Rx_FIFO.

    The first word is the Left audio followed by the Right audio
    which is followed by I data and finally the Q data.
    	
    The words sent to the D/A converters must be sent at the sample rate
    of the A/D converters (48kHz) so is synced on the negative edge of the CLRCLK.
*/

reg   [2:0] IF_PWM_state;      // state for PWM
reg   [2:0] IF_PWM_state_next; // next state for PWM
reg  [15:0] IF_Left_Data;      // Left 16 bit PWM data for D/A converter
reg  [15:0] IF_Right_Data;     // Right 16 bit PWM data for D/A converter
reg  [15:0] PLL_freq;		// frequency for First LO

// reg  [15:0] IF_Q_PWM;          // Q 16 bit PWM data for D/A conveter
wire         IF_get_samples;
wire        IF_get_rx_data;
wire        IF_bleed;
reg  [12:0] IF_bleed_cnt;
reg         IF_xmit_req;
wire         IF_xack, IF_xrdy;

// Bleed the RX FIFO if no data is being sent to Mercury/Janus or Penelope/Janus so that
// new RX Control data keeps coming in. Otherwise everything will come to a halt.  Have
// to keep getting RX Control data so we have new C & C data - specifically clock_s[].
// Bleed time is set to occur if the dead time is greater than one 24Khz period since
// CLRCLK is normally 48KHz.  Dead time can be different than one 24Khz period so long
// as it longer than one 48Khz period.  This problem occurs when switching 122.88Mhz clock
// sources
assign IF_get_rx_data = IF_get_samples || IF_bleed;

assign IF_bleed  = (IF_bleed_cnt == (48000000/12000));

localparam PWM_IDLE     = 0,
           PWM_START    = 1,
           PWM_LEFT     = 2,
           PWM_RIGHT    = 3,
           PWM_I_AUDIO  = 4,
           PWM_Q_AUDIO  = 5,
           PWM_WAIT     = 6,
           PWM_REQ      = 7;

always @ (posedge IF_clk) 
begin
  if (IF_rst)
    IF_PWM_state   <= #IF_TPD PWM_IDLE;
  else
    IF_PWM_state   <= #IF_TPD IF_PWM_state_next;

  if (IF_rst)
    IF_bleed_cnt   <= #IF_TPD 1'b0;
  else if (IF_get_rx_data)
    IF_bleed_cnt   <= #IF_TPD 1'b0; // keep clearing IF_bleed count any time we get data from RX FIFO
  else
    IF_bleed_cnt   <= #IF_TPD IF_bleed_cnt + 1'b1;

  // get Left audio
  if (IF_PWM_state == PWM_LEFT)
    IF_Left_Data   <= #IF_TPD IF_Rx_fifo_rdata;

  // get Right audio
  if (IF_PWM_state == PWM_RIGHT)
    IF_Right_Data  <= #IF_TPD IF_Rx_fifo_rdata;

//  // get I audio
//  if (IF_PWM_state == PWM_I_AUDIO)
//    IF_I_PWM       <= #IF_TPD IF_Rx_fifo_rdata;
    
      // get First LO Frequency 
  if (IF_PWM_state == PWM_I_AUDIO)
    PLL_freq 	<= #IF_TPD IF_Rx_fifo_rdata;

  // get Q audio
//  if (IF_PWM_state == PWM_Q_AUDIO)
//    IF_Q_PWM       <= #IF_TPD IF_Rx_fifo_rdata;

  if (IF_rst)
    IF_xmit_req    <= #IF_TPD 1'b0;
  else
    IF_xmit_req    <= #IF_TPD (IF_PWM_state == PWM_REQ) ? 1'b1 : 1'b0; // all data ready to be sent now

end

always @*
begin
  case (IF_PWM_state)
    PWM_IDLE:
    begin
      IF_Rx_fifo_rreq = 1'b0;

      if (!IF_get_rx_data)
        IF_PWM_state_next = PWM_IDLE;    // wait until time to get the donuts every 48/96/192Khz from oven (RX_FIFO)
      else if (RX_USED[RFSZ:2] == 1'b0)  // RX_USED < 4
        IF_PWM_state_next = PWM_WAIT;    // no new donuts so go empty handed = error
      else
        IF_PWM_state_next = PWM_START;   // ah! now it's time to get the donuts
    end

    // Start packaging the donuts
    PWM_START:
    begin
      IF_Rx_fifo_rreq    = 1'b1;
      IF_PWM_state_next  = PWM_LEFT;
    end

    // get Left audio
    PWM_LEFT:
    begin
      IF_Rx_fifo_rreq    = 1'b1;
      IF_PWM_state_next  = PWM_RIGHT;
    end

    // get Right audio
    PWM_RIGHT:
    begin
      IF_Rx_fifo_rreq    = 1'b1;
      IF_PWM_state_next  = PWM_I_AUDIO;
    end

    // get I audio
    PWM_I_AUDIO:
    begin
      IF_Rx_fifo_rreq    = 1'b1;
      IF_PWM_state_next  = PWM_Q_AUDIO;
    end

    // get Q audio
    PWM_Q_AUDIO:
    begin
      IF_Rx_fifo_rreq    = 1'b0;
      IF_PWM_state_next  = PWM_WAIT;
    end

    PWM_WAIT: // got donuts from oven and pack them.
    begin     // Now wait for shipping truck (NWire_xmit) ready to load them
      IF_Rx_fifo_rreq      = 1'b0;
      if (!IF_xrdy)
        IF_PWM_state_next  = PWM_WAIT;
      else
        IF_PWM_state_next  = PWM_REQ;
    end

    PWM_REQ: // load donuts and wait for shipping truck to leave
    begin
      IF_Rx_fifo_rreq      = 1'b0;
      if (!IF_xack)
        IF_PWM_state_next  = PWM_REQ;
      else
        IF_PWM_state_next  = PWM_IDLE; // truck has left the shipping dock
    end

    default:
    begin
      IF_Rx_fifo_rreq    = 1'b0;
      IF_PWM_state_next  = PWM_IDLE;
    end
  endcase
end

///////////////////////////////////////////////////////////////////////////////
//
// Left/Right Audio data transfers to Mercury(C24)/Janus(C4)
// I/Q Audio data transfer to Penelope(C19)/Janus(C12)
//
///////////////////////////////////////////////////////////////////////////////
wire       IF_m_rdy, IF_m_ack, IF_p_rdy, IF_p_ack, IF_j_rdy;

wire IF_C23, IF_C22, IF_CLRCLK;
wire IF_m_pulse, IF_p_pulse, IF_j_pulse;

cdc_sync cdc_c23 (.siga(C23), .rstb(IF_rst), .clkb(IF_clk), .sigb(IF_C23)); // C23 = M_LR_sync
pulsegen cdc_m   (.sig(IF_C23), .rst(IF_rst), .clk(IF_clk), .pulse(IF_m_pulse));

// IF_get_samples produces a single pulse telling when its time (48/96/192Khz) to get
// new data from RX_FIFO and send it to Mercury

assign IF_get_samples = IF_m_pulse;  // Mercury installed so use rising edge of C23 (M_LR_sync)

assign IF_xack = IF_m_ack;
assign IF_xrdy = IF_m_rdy;


// **** need the following code in order to get data from Mercury - check exactly what is needed later ****

// 16 bits, two channels for PWM DAC on Mercury or Janus
NWire_xmit #(.SEND_FREQ(50000),.DATA_BITS(32), .ICLK_FREQ(144000000), .XCLK_FREQ(48000000))
  M_LRAudio (.irst(C144_rst), .iclk(C144_clk), .xrst(IF_rst), .xclk(IF_clk),
             .xdata({IF_Left_Data,IF_Right_Data}), .xreq(IF_xmit_req), .xrdy(IF_m_rdy),
             .xack(IF_m_ack), .dout(C24));


///////////////////////////////////////////////////////////////
//
//              Implements Command & Control  encoder 
//
///////////////////////////////////////////////////////////////
/*
	The C&C encoder broadcasts data over the Atlas bus C20 for
	use by other cards e.g. Mercury and Penelope.
	
	The data fomat is as follows:
	
	<[60:59]DFS1,DFS0><[58]PTT><[57:54]address><[53:22]frequency><[21:18]clock_select><[17:11]OC>
	<[10]Mode><[9]PGA><[8]DITHER><[7]RAND><[6:5]ATTEN><[4:3]TX_relay><[2]Rout><[1:0]RX_relay> 
	
	Total of 61 bits. Frequency is in Hz and OC is the open collector data on Penelope.
	The clock source decodes as follows:
	
	0x00  = 10MHz reference from Atlas bus ie Gibraltar
	0x01  = 10MHz reference from Penelope
	0x10  = 10MHz reference from Mercury
	00xx  = 122.88MHz source from Penelope 
	01xx  = 122.88MHz source from Mercury

		
	For future expansion the four bit address enables specific C&C data to be send to individual boards.
	For the present for use with Mercury and Penelope the address is ignored. 

*/
wire [60:0] IF_xmit_data;
reg   [3:0] CC_address;     // C&C address  0 - 8 
wire        IF_CC_rdy, IF_CC_pulse;

pulsegen CC_p   (.sig(IF_CC_rdy), .rst(IF_rst), .clk(IF_clk), .pulse(IF_CC_pulse));
// change address each data transmission 
always @ (posedge IF_clk)
begin
  if (IF_rst)
    CC_address <= #IF_TPD 1'b0;
  else if (IF_CC_pulse) // occurs at each rising edge of IF_CC_rdy
  begin
    if (CC_address == 4'd8)
      CC_address <= 1'b0; // Penny = 0
    else
      CC_address <= #IF_TPD CC_address + 1'b1; // 1 <= Mercury <= 8
  end
end

// speed is always 192k for now 

assign IF_xmit_data = {1'b1,1'b0,PTT_out,CC_address,IF_frequency[CC_address],IF_clock_s,IF_OC,IF_mode,IF_PGA,
                       IF_DITHER, IF_RAND, IF_ATTEN, IF_TX_relay, IF_Rout, IF_RX_relay};

NWire_xmit  #(.DATA_BITS(61), .ICLK_FREQ(48000000), .XCLK_FREQ(48000000), .SEND_FREQ(10000)) 
      CCxmit (.irst(IF_rst), .iclk(IF_clk), .xrst(IF_rst), .xclk(IF_clk),
              .xdata(IF_xmit_data), .xreq(1'b1), .xrdy(IF_CC_rdy), .xack(), .dout(CC));

wire led0_off;
wire led3_off;

// Flash the LEDs to show something is working! - LEDs are active low

assign DEBUG_LED0 = led0_off; //D1 LED
assign DEBUG_LED1 = ~IF_conf[1];	// test config setting  
assign DEBUG_LED2 = ~PTT_out; // lights with PTT active
assign DEBUG_LED3 = led3_off; // D4 LED 
//assign DEBUG_LED1 = (IF_Rx_ctrl_0[7:1] == 0) ?  IF_Rx_ctrl_3[0] : DEBUG_LED1;
//assign DEBUG_LED2 = (IF_Rx_ctrl_0[7:1] == 0) ?  IF_Rx_ctrl_3[1] : DEBUG_LED2;

wire [3:0] err_sigs;
wire [1:0] sync_err;

reg [23:0] LRcnt;  // just for debuggin purposes to see how long a particular signal is high or low
always @(posedge IF_clk)
begin
  if (IF_rst)
    LRcnt <= 0;
  else if (IF_tx_IQ_mic_rdy)
    LRcnt <= 0;
  else
    LRcnt <= LRcnt + 1'b1;    // how long the signal is low  
end

assign err_sigs = {(RX_USED[RFSZ:2] == 1'b0), (LRcnt > 24'h60000), IF_Rx_fifo_full, IF_tx_fifo_full & IF_tx_fifo_wreq};
assign sync_err[0] = (IF_SYNC_state == SYNC_START) && IF_Rx_fifo_drdy && (IF_Rx_fifo_wdata[15:8] != 8'h7F);
assign sync_err[1] = (IF_SYNC_state == SYNC_IDLE) && IF_Rx_fifo_drdy && (IF_Rx_fifo_wdata != 16'h7F7F); // sync error


led_blinker #(3, 48000000) BLINK_D1 (IF_clk, err_sigs, led0_off);
led_blinker #(2, 48000000) BLINK_D4 (IF_clk, sync_err, led3_off);

function integer clogb2;
input [31:0] depth;
begin
  for(clogb2=0; depth>0; clogb2=clogb2+1)
  depth = depth >> 1;
end
endfunction

//////////////////////////////////////////////////////
//
//	Interface to Cyclops board
//
//////////////////////////////////////////////////////
				
/*

////////////////////////////////////////////////////////////////////////
//
//	ADF4112 configuration	
//
////////////////////////////////////////////////////////////////////////



Initialization Latch 

INL:    Normal operation
        Digital lock detect on MUXOUT
        Positive CP polarity
        No "fast lock"
        CP current = 2.5 mA.
        Prescaler P=64
*/

parameter P2	= 1'b0;		
parameter P1 	= 1'b1;		// prescaler 16/17
parameter PD2	= 1'b0;
parameter CP16 	= 1'b1;		// Increase current for "fast lock"
//
parameter CP15 	= 1'b1;     // Fast lock not currently implemented
parameter CP14 	= 1'b1;		// Icp = 2.5mA
parameter CP13 	= 1'b0;
parameter CP12 	= 1'b1;
//
parameter CP11 	= 1'b1;		// R = 4.7k
parameter TC4 	= 1'b1;
parameter TC3 	= 1'b0;
parameter TC2 	= 1'b0;
//
parameter TC1 	= 1'b0;		// TIMEOUT PFD = 31 cycles
parameter F5 	= 1'b0;
parameter F4 	= 1'b0;		// fast lock disabled
parameter F3 	= 1'b0;		// outout normal
//
parameter F2_VCO1   = 1'b0;     // Charge Pump VCO1 = negative
parameter F2_VCO2   = 1'b1;     // Charge Pump VCO2 = positive
parameter M3 	= 1'b0;
parameter M2 	= 1'b0;
parameter M1 	= 1'b1;		// Digital lock detect on MUXOUT
//
parameter PD1 	= 1'b0;		// normal operation
parameter F1 	= 1'b0;		// Counter operation - normal
parameter C2 	= 1'b1;
parameter C1 	= 1'b1;

parameter Second_LO_INL = {P2,P1,PD2,CP16,CP15,CP14,CP13,CP12,CP11,TC4,TC3,TC2,TC1,F5,F4,F3,F2_VCO2,M3,M2,M1,PD1,F1,C2,C1}; // 24'h5DC093
// Note:  F2 is 0 for first local oscillator since loop amplifier inverts 
parameter First_LO_INL  = {P2,P1,PD2,CP16,CP15,CP14,CP13,CP12,CP11,TC4,TC3,TC2,TC1,F5,F4,F3,F2_VCO1,M3,M2,M1,PD1,F1,C2,C1};  // 24'h5DC013 

/* 

Local Oscillator 2 Reference Counter Latch

RCL:    Reference divisor = 10 (Internal ref = 1.0 MHz.)
        Anti Backlash pulse = 3 ns. (I picked the middle value)
        Lock detect precision = High
        Delay Sync = Normal
        
*/

parameter LO2_BD23	 = 1'b0;  		//don't care
parameter LO2_DLY	 = 1'b0;		
parameter LO2_SYNC	 = 1'b0;		// normal operation
parameter LO2_LDP	 = 1'b1;		// Lock detect precision = High
parameter LO2_T1	 = 1'b0;		
parameter LO2_T2	 = 1'b0;		// test mode = normal
parameter LO2_ABP2	 = 1'b0;
parameter LO2_ABP1	 = 1'b0;		// Anti Backlash pulse = 3 ns
parameter [13:0]LO2_R = 14'b00_0000_0001_0100;  // divide by 20
 
parameter Second_LO_RCL = {LO2_DB23,LO2_DLY,LO2_SYNC,LO2_LDP,LO2_T1,LO2_T2,LO2_ABP2,LO2_ABP1,LO2_R,2'b00}; 	//24'h100050;

/* *****************************************************************************
 *  Local Oscillator 2 -- N Counter Latch
 *
 *  Internal divider range ( N = B*P+A ) where B >= A
 *
 *      N = 2251  for fixed 1125.5 MHz.
 *
 *  If P = 16, and the upper two bits of A are held at 00,
 *  then B concatenated with the lower four bits of A can be considered
 *  a single binary 17 bit "N" register.
 *
 *  where:
 *  B13 B12 B11 | B10 B09 B08 B07 | B06 B05 B04 B03 | B02 B01 A6 A5 | A4 A3 A2 A1
 *   ----------- Upper bits of N control word -------------- | 0  0 | lower nybble
 *
 *  N = 2251 which converts to 000_0010_0011_0000_1011
 *
 */

parameter LO2_DB23    = 1'b0;       // don't care
parameter LO2_DB22    = 1'b0;       // don't care
parameter LO2_G1      = 1'b0;       // setting 1 is used
parameter [18:0]LO2_BA = 19'b000_0010_0011_0000_1011;  // 2251, P=16

parameter Second_LO_NCL = {LO2_DB23, LO2_DB22, LO2_G1, LO2_BA, 2'b01}; // For fixed frequency of 1125.5 MHz
                               


/* 

Local Oscillator 1 Reference Counter Latch

RCL:    Reference divisor = 10 (Internal ref = 1 MHz.)
        Anti Backlash pulse = 3 ns. (I picked the middle value)
        Lock detect precision = High
        Delay Sync = Normal
        
*/

parameter LO1_BD23	 = 1'b0;  		//don't care
parameter LO1_DLY	 = 1'b0;		
parameter LO1_SYNC	 = 1'b0;		// normal operation
parameter LO1_LDP	 = 1'b1;		// Lock detect precision = High
parameter LO1_T1	 = 1'b0;		
parameter LO1_T2	 = 1'b0;		// test mode = normal
parameter LO1_ABP2	 = 1'b0;
parameter LO1_ABP1	 = 1'b0;		// Anti Backlash pulse = 3 ns
parameter [13:0]LO1_R = 14'b00_0000_0000_1010;  // divide by 10
 
parameter First_LO_RCL = {LO1_DB23,LO1_DLY,LO1_SYNC,LO1_LDP,LO1_T1,LO1_T2,LO1_ABP2,LO1_ABP1,LO1_R,2'b00}; 	

/*

Local Oscillator 1 N Counter Latch 

Desired output: Comes from PLL_freq

Internal Reference = 1 MHz.
Reference counter = divide by 10  (R = 10)

Internal divider range ( N = B*P+A )  B>= A 

If P = 16, and the upper two bits of A are held at 00,
then B concatenated with the lower four bits of A can be considered
a single binary 17 bit "N" register.

where
  B13 B12 B11 | B10 B09 B08 B07 | B06 B05 B04 B03 | B02 B01 A6 A5 | A4 A3 A2 A1
   ----------------- Upper bits of N control word -------- | 0  0 | lower nybble

*/

parameter LO1_DB23	  = 1'b0;	// don't care
parameter LO1_DB22	  = 1'b0;  // don't care
parameter LO1_G1	  = 1'b0;  // setting 1 is used


//////////////////////////////////////////////////
//
//	Clocks
//
//////////////////////////////////////////////////


// SPI Clock - 48/10  = 4.8MHZ

reg clock;
reg [2:0]spi_clock;

always @ (posedge IF_clk)
begin
	if (spi_clock == 4)begin
		spi_clock <= 0;
		clock <= ~clock;
	end
	else spi_clock <= spi_clock + 1'b1;
end

///////////////////////////////////////////////////////////////////
//
// Set 2nd Local Oscillator ADF4112 to 1126MHz using SPI interface
//
///////////////////////////////////////////////////////////////////

wire [23:0]SPI_DATA;  // 24 bit wide data and address register to ADF4112
reg [23:0]Second_LO_data;

wire  LE; 

reg [3:0]SPI_state;
reg start1, start2;

always @ (posedge clock)
begin 
case (SPI_state)

// Write to INL register
0:	begin
	if (ready) begin			// send ADSF4113 data 
		start2 <= 1'b1; 
		Second_LO_data  <= Second_LO_INL; 
		SPI_state <= SPI_state + 1'b1;
		end
	else SPI_state <= 0; 		// loop until SPI module ready 
	end
// delay so that SPI module see the start signal
2:	begin
	start2 <= 1'b0;				// stop sending data 
	SPI_state <= SPI_state + 1'b1;
	end 
	
// Write to RCL register
3:	begin
	if (ready) begin
		start2 <= 1;
		Second_LO_data <= Second_LO_RCL;
		SPI_state <= SPI_state + 1'b1;
		end
	else SPI_state <= 3; 		// loop until SPI module ready 
	end
// delay 
5:	begin
	start2 <= 1'b0;
	SPI_state <= SPI_state + 1'b1;
	end
// Write to NCL register
6: 	begin 
	if (ready) begin
		start2 <= 1;
		Second_LO_data <= Second_LO_NCL;
		SPI_state <= SPI_state + 1'b1;
		end
	else SPI_state <= 6;
	end 
//delay
8: begin
	start2 <= 1'b0;
	SPI_state <= SPI_state + 1'b1;
	end
// wait for data to be sent
9: 	begin
	if (ready) SPI_state <= SPI_state + 1'b1;
	else SPI_state <= 9;
	end
// all data sent so loop here
10: SPI_state <= 10;
default: SPI_state <= SPI_state + 1'b1;
endcase
end

////////////////////////////////////////////////////////////
//
// set 1st LO  ADF4112 to PC sent frequency  using SPI interface
//
///////////////////////////////////////////////////////////

/*

 The frequency to set the First LO to comes from the PC
 and is in 16 bit register PLL_freq.  Need to extend this to 
 19 bits and send to LMX2326

*/

// need to convert the 16 bit frequecy from the PC to the 19 bit N control word 
//  B13 B12 B11 | B10 B09 B08 B07 | B06 B05 B04 B03 | B02 B01 A6 A5 | A4 A3 A2 A1
//   ----------------- Upper bits of N control word -------- | 0  0 | lower nybble

wire [18:0]N_control_word = {1'b0,PLL_freq[15:4],2'b00,PLL_freq[3:0]};

reg [23:0]First_LO_data;
reg [3:0]SPI2_state;
reg [15:0] Previous_PLL_freq;

wire [23:0] First_LO_NCL = {LO1_DB23, LO1_DB22, LO1_G1, N_control_word, 2'b01}; 

always @ (posedge clock)
begin 
case (SPI2_state)

// Write to INL register, don't run until LO 2 has been setup
0:	begin
	if (ready && SPI_state == 10) begin			// send ADF4112  data 
		start1 <= 1'b1; 
		First_LO_data <= First_LO_INL;
		SPI2_state <= SPI2_state + 1'b1;
		end
	else SPI2_state <= 0; 		// loop until SPI module ready 
	end
// delay so SPI module can see the ready flag

// Write to RCL register
2:	begin
	start1 <= 1'b0;				// stop sending data 
	SPI2_state <= SPI2_state + 1'b1;
	end 
	
// send data
3:	begin
	if (ready) begin
		start1 <= 1;
		First_LO_data <= First_LO_RCL;
		SPI2_state <= SPI2_state + 1'b1;
		end
	else SPI2_state <= 3; 		// loop until SPI module ready 
	end
// delay
// Write to NCL register
5:	begin
	start1 <= 1'b0;
	SPI2_state <= SPI2_state + 1'b1;
	end
	
// send data
6: 	begin 
	if (ready) begin
		start1 <= 1;
		First_LO_data <= First_LO_NCL;
		SPI2_state <= SPI2_state + 1'b1;
		end
	else SPI2_state <= 6;
	Previous_PLL_freq <= PLL_freq;  // save the current frequecy
	end 
// delay
// loop until next 1st LO frequency available 
8: 	begin
	start1 <= 1'b0;
	if (Previous_PLL_freq == PLL_freq)
		SPI2_state <= 8;  // loop here until we have a new 1st LO frequency
	else SPI2_state <= 5;       // else set PLL to new frequency 
	end
default: SPI2_state <= SPI2_state + 1'b1;
endcase
end

// assign data and latch enable depending on which ADF4112 we are addressing 
assign SPI_DATA = (SPI_state < 10) ? Second_LO_data : First_LO_data;
assign LE1 = (SPI_state == 10) ? LE : 1'b1;
assign LE2 = (SPI_state < 10)  ? LE : 1'b1;

wire ready;
// SPI interface to ADF4112s	
ADF4112_SPI ADF4112(.clock(clock),.start(start1 || start2),.ready(ready),.data(SPI_DATA),
					.SPI_clock(ADF4112_SPI_clock),.SPI_LE(LE),.SPI_data(ADF4112_SPI_data));

endmodule
