`timescale 1ns/1ns
`include "crt.v"

module crt_test;

reg clk;
initial clk = 0;
always #1 clk <= ~clk;

reg reset;

reg cs, we;
wire [15:0] data;
wire [3:0] addr;
reg [3:0] outaddr;
reg [15:0] outdata;
wire irq;
wire hs, vs;
wire ven;
wire [31:0] pixaddr;
assign data = we ? outdata : 16'bz;
assign addr = cs ? outaddr : 4'bz;

crt uut(
	.clk(clk),
	.reset(reset),
	.cs(cs),
	.we(we),
	.addr(addr),
	.data(data),
	.irq(irq),
	.vs(vs),
	.hs(hs),
	.ven(ven),
	.pixaddr(pixaddr)
);

initial
begin
	$dumpfile("crt_test.vcd");
	$dumpvars(0, crt_test);
	
	reset <= 1;
	cs <= 0;
	we <= 0;
	
	#2;
	reset <= 0;
	
	// IRQ at column 200
	#2;
	cs <= 1'b1;
	we <= 1'b1;
	outaddr <= 4'hC;
	outdata <= 16'd200;
	
	// IRQ at row 300
	#2;
	cs <= 1'b1;
	we <= 1'b1;
	outaddr <= 4'hD;
	outdata <= 16'd300;
	
	// Enable IRQ
	#2;
	cs <= 1'b1;
	we <= 1'b1;
	outaddr <= 4'hF;
	outdata <= 16'b1000000000000010;
	
	#2;
	cs <= 1'b0;
	we <= 1'b0;
	outaddr <= 4'h0;
	outdata <= 16'bz;
	
	// Read all the registers
	#2;
	cs <= 1'b1;
	we <= 1'b0;
	outaddr <= 4'h0;
	#2 outaddr <= 4'h1;
	#2 outaddr <= 4'h2;
	#2 outaddr <= 4'h3;
	#2 outaddr <= 4'h4;
	#2 outaddr <= 4'h5;
	#2 outaddr <= 4'h6;
	#2 outaddr <= 4'h7;
	#2 outaddr <= 4'h8;
	#2 outaddr <= 4'h9;
	#2 outaddr <= 4'hA;
	#2 outaddr <= 4'hB;
	#2 outaddr <= 4'hC;
	#2 outaddr <= 4'hD;
	#2 outaddr <= 4'hE;
	#2 outaddr <= 4'hF;
	#2;
	cs <= 1'b0;
	outaddr <= 4'h1;
	
	#1320402;
	cs <= 1'b1;
	we <= 1'b1;
	outaddr <= 4'hE;
	outdata <= 16'b0;

	#2;
	cs <= 1'b0;
	we <= 1'b0;
	outaddr <= 4'h0;
	outdata <= 16'b0;

	//9900030
	#(2201*1125*2*2+30) $finish;
end

endmodule

module crt_ramdac(clk, pixaddr, ven, qpixel, breq, back);

parameter ADDR_SIZE = 32;
localparam PIXEL_SIZE = 32;

input clk;
input [ADDR_SIZE-1:0] pixaddr;
input ven;
output [PIXEL_SIZE-1:0] qpixel;
output breq;
input back;

always @(posedge clk)
begin
	
end

endmodule
