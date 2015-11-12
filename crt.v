`include "crt_address_decoder.v"	
`include "crt_register.v"
module crt(
	input clk,
	input reset,
	input cs,
	input we,
	input [3:0] addr,
	inout [15:0] data,
	output irq,
	output vs,
	output hs,
	output ven,
	output [2:0] clksel,
	output [31:0] pixaddr
);

// One-hot chip select bus for registers
wire addr_cr, addr_ia, addr_ir, addr_ic;
wire addr_sh, addr_sl, addr_fh, addr_fl; 
wire addr_ve, addr_vf, addr_vv, addr_vb;
wire addr_he, addr_hf, addr_hv, addr_hb;

// Standard 1920*1080@60Hz
localparam [15:0] T_HS = 16'd44;		// horizontal sync
localparam [15:0] T_HB = 16'd148;		// horizontal back porch
localparam [15:0] T_HV = 16'd1920;	// horizontal video
localparam [15:0] T_HF = 16'd88;		// horizontal front porch
localparam [15:0] T_VS = 16'd5;		// vertical sync
localparam [15:0] T_VB = 16'd36;		// vertical back porch
localparam [15:0] T_VV = 16'd540;	// vertical video
localparam [15:0] T_VF = 16'd4;		// vertical front porch

// Positions are relative to 
localparam [15:0] INIT_HB = (T_HS);
localparam [15:0] INIT_HV = (T_HS + T_HB);
localparam [15:0] INIT_HF = (T_HS + T_HB + T_HV);
localparam [15:0] INIT_HE = (T_HS + T_HB + T_HV + T_HF - 16'd1);

localparam [15:0] INIT_VB = (T_VS);
localparam [15:0] INIT_VV = (T_VS + T_VB);
localparam [15:0] INIT_VF = (T_VS + T_VB + T_VV);
localparam [15:0] INIT_VE = (T_VS + T_VB + T_VV + T_VF - 16'd1);

localparam [15:0] INIT_IC = 16'd0;
localparam [15:0] INIT_IR = 16'd0;

localparam [15:0] INIT_CR = 16'h0002;

localparam [15:0] INIT_SL = 16'h0080;
localparam [15:0] INIT_SH = 16'h0000;
localparam [15:0] INIT_FL = 16'h0000;
localparam [15:0] INIT_FH = 16'h0001;

localparam [15:0] INIT_IRQ = 16'h0000;

wire [15:0] address_decode;

crt_address_decoder addr_decode(
	.addr(addr),
	.cs(cs),
	.q(address_decode)
);

assign {
	addr_cr, addr_ia, addr_ir, addr_ic,
	addr_sh, addr_sl, addr_fh, addr_fl,
	addr_ve, addr_vf, addr_vv, addr_vb,
	addr_he, addr_hf, addr_hv, addr_hb
} = address_decode;

// DFFs

reg [15:0] currentrow;
reg [15:0] currentcol;
reg [31:0] currentaddr;
reg currentfield;

wire [15:0] hbporch, hvideo, hfporch, hend;
wire [15:0] vbporch, vvideo, vfporch, vend;
wire [15:0] irqc, irqr;
wire [15:0] control;
wire [31:0] startaddr;
wire [31:0] stride;

// Determine how far it is in addresses from the start
// of one scanline to the start of the next
wire [31:0] row2row = (hend - hvideo) + stride;

// The start address of the second field
wire [31:0] startaddr2 = startaddr + row2row;

wire [31:0] nextstartaddr = currentfield ? startaddr2 : startaddr;

// The last scanline is half length when interlaced
wire [15:0] hend2 = {1'b0, hend[15:1]};
wire [15:0] hendv = video_interlaced ? hend2 : hend;

crt_register #(.WIDTH(16)) reg_hb(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_HB),
	.cs(addr_hb),
	.we(we),
	.value(hbporch),
	.data(data)
);

// hvideo
crt_register #(.WIDTH(16)) reg_hv(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_HV),
	.cs(addr_hv),
	.we(we),
	.value(hvideo),
	.data(data)
);

// hfporch
crt_register #(.WIDTH(16)) reg_hf(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_HF),
	.cs(addr_hf),
	.we(we),
	.value(hfporch),
	.data(data)
);

// hend
crt_register #(.WIDTH(16)) reg_he(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_HE),
	.cs(addr_he),
	.we(we),
	.value(hend),
	.data(data)
);

// vbporch
crt_register #(.WIDTH(16)) reg_vb(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_VB),
	.cs(addr_vb),
	.we(we),
	.value(vbporch),
	.data(data)
);

// vvideo
crt_register #(.WIDTH(16)) reg_vv(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_VV),
	.cs(addr_vv),
	.we(we),
	.value(vvideo),
	.data(data)
);

// vfporch
crt_register #(.WIDTH(16)) reg_vf(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_VF),
	.cs(addr_vf),
	.we(we),
	.value(vfporch),
	.data(data)
);

// vend
crt_register #(.WIDTH(16)) reg_ve(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_VE),
	.cs(addr_ve),
	.we(we),
	.value(vend),
	.data(data)
);

// irqc
crt_register #(.WIDTH(16)) reg_ic(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_IC),
	.cs(addr_ic),
	.we(we),
	.value(irqc),
	.data(data)
);

// irqr
crt_register #(.WIDTH(16)) reg_ir(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_IR),
	.cs(addr_ir),
	.we(we),
	.value(irqr),
	.data(data)
);

// control
crt_register #(.WIDTH(16)) reg_cr(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_CR),
	.cs(addr_cr),
	.we(we),
	.value(control),
	.data(data)
);

// stride low
crt_register #(.WIDTH(16)) reg_sl(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_SL),
	.cs(addr_sl),
	.we(we),
	.value(stride[15:0]),
	.data(data)
);

// stride high
crt_register #(.WIDTH(16)) reg_sh(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_SH),
	.cs(addr_sh),
	.we(we),
	.value(stride[31:16]),
	.data(data)
);

// frame low
crt_register #(.WIDTH(16)) reg_fl(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_FL),
	.cs(addr_fl),
	.we(we),
	.value(startaddr[15:0]),
	.data(data)
);

// frame high
crt_register #(.WIDTH(16)) reg_fh(
	.clk(clk),
	.reset(reset),
	.resetvalue(INIT_FH),
	.cs(addr_fh),
	.we(we),
	.value(startaddr[31:16]),
	.data(data)
);

// irq
crt_register #(.WIDTH(16)) reg_ia(
	.clk(clk),
	.reset(reset | (we & addr_ia)),
	.resetvalue(INIT_IRQ),
	.cs(irq_set),
	.we(irq_set),
	.value(irqout),
	.data(irq_set_data)
);

// Combinatorial examination of current state

// Phases of horizontal and vertical trace:
//  Sync
//  back porch
//  video
//  front porch

wire irq_enabled = control[15];
wire hsync_invert = control[14];
wire vsync_invert = control[13];
wire video_interlaced = control[1];
wire video_enabled = ~control[0];
wire [2:0] clk_select = control[7:5];

wire is_currentcol_0 = (currentcol == 1'b0);
wire is_currentcol_ge_hvideo = (currentcol >= hvideo);
wire is_currentcol_lt_hbporch = (currentcol < hbporch);
wire is_currentcol_lt_hfporch = (currentcol < hfporch);
wire is_currentcol_hfporch = (currentcol == hfporch);
wire is_currentcol_hendv = (currentcol == hendv);
wire is_currentcol_hend = (currentcol == hend);

wire is_currentrow_0 = (currentrow == 1'b0);
wire is_currentrow_ge_vvideo = (currentrow >= vvideo);
wire is_currentrow_lt_vbporch = (currentrow < vbporch);
wire is_currentrow_lt_vfporch = (currentrow < vfporch);
wire is_currentrow_vfporch = (currentrow == vfporch);
wire is_currentrow_vend = (currentrow == vend);

wire in_start = is_currentrow_0 & is_currentcol_0;
wire in_end = is_currentrow_vfporch & is_currentcol_hfporch;
wire in_restart_addr = (in_start | in_end);

wire in_hsync = is_currentcol_lt_hbporch;
//wire in_hbporch = currentcol >= hbporch && currentcol < hvideo;
wire in_hvideo = is_currentcol_ge_hvideo & is_currentcol_lt_hfporch;
//wire in_hfporch = currentcol >= hfporch && currentcol < hend;

// The last scanline is half-length when interlaced
wire in_hend = (video_interlaced & is_currentrow_vend &
	is_currentcol_hendv) | is_currentcol_hend;

wire in_vsync = is_currentrow_lt_vbporch;
//wire in_vbporch = currentrow >= vbporch && currentrow < vvideo;
wire in_vvideo = is_currentrow_ge_vvideo && is_currentrow_lt_vfporch;
//wire in_vfporch = currentrow >= vfporch && currentrow < vend;
wire in_vend = is_currentcol_hendv & is_currentrow_vend;

wire irq_rowmatch = (currentrow == irqr);
wire irq_colmatch = (currentcol == irqc);
wire irq_match = irq_rowmatch & irq_colmatch;
wire irq_set = irq_match & irq_enabled;
wire [15:0] irq_set_data = 16'b1;

wire in_video = in_hvideo & in_vvideo;

wire [15:0] nextcol = currentcol + 1'b1;
wire [15:0] nextrow = currentrow + 1'b1;

wire [31:0] nextpixeladdr = currentaddr + 1'b1;
wire [31:0] nextrowaddr = currentaddr + stride;

wire [15:0] irqout;
wire [15:0] dataout;
wire dataout_en;

// Drive outputs

assign hs = in_hsync ^ hsync_invert;
assign vs = in_vsync ^ vsync_invert;
assign ven = in_video & video_enabled;
assign clksel = clk_select;
assign pixaddr = currentaddr;
assign irq = irqout[0];

always @(posedge clk)
begin
	currentfield <= (reset | ~in_vend) ? (currentfield & ~reset)
		: ((currentfield & video_interlaced) ^ video_interlaced);
	
	// Address jumps to start of next row at horizontal end
	// Address jumps to beginning of frame at vertical end
	// Address steps forward one pixel if in video
	// Otherwise stays at same address
	currentaddr <= (reset | in_restart_addr) ? nextstartaddr :
		(in_hend & in_vvideo) ? nextrowaddr :
		in_video ? nextpixeladdr :
		currentaddr;

	// Current row resets if at vertical end,
	// Advances to the next line if at horizontal end
	// Otherwise stays on the same row
	currentrow <= (reset | in_vend) ? 1'b0 : 
		in_hend ? nextrow :
		currentrow;

	// Update currentcol
	// The next column, or reset at horizontal end
	// Never stops, only resets at max value
	currentcol <= (reset | in_hend) ? 1'b0 :
		nextcol;
end

endmodule
