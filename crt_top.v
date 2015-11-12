`ifdef N
module crt_top(
	clk, cs, we, addr, data,
	red, green, blue, hs, vs, ven, irq);

crt crtc(
.clk(clk),
.reset(reset),
.cs(cs),
.we(we),
.addr(addr),
.data(data),
.irq(irq),
.vs(vs_in),
.hs(hs_in),
.ven(ven_in),
.clksel(),
.pixaddr()
);
	
endmodule;

`include "crt.v"
`include "crt_register.v"
`include "crt_address_decoder.v"
`include "crt_register.v"
`endif
