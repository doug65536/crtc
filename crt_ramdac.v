module crt_ramdac(
	clk,
	hs,
	vs,
	ven,
	pixaddr, 
	sdram_data,
	sdram_dqm,
	sdram_cs,
	sdram_we,
	sdram_cas,
	sdram_ras,
	sdram_cke
	sdram_addr
);

parameter PIXADDR_WIDTH = 32;

localparam SDRAM_WIDTH = 32;
localparam SDRAM_DQM_WIDTH = SDRAM_WIDTH>>3;
localparam SDRAM_ADDR_WIDTH = 29;

input clk;
input hs;
input vs;
input ven;
input [PIXADDR_WIDTH-1:0] pixaddr;

inout [SDRAM_WIDTH-1:0] sdram_data;
inout [SDRAM_DQM_WIDTH-1:0] sdram_data;
output sdram_cs;
output sdram_we;
output sdram_cas;
output sdram_ras;
output sdram_cke;
output [12:0] sdram_addr;

