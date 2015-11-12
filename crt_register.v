module crt_register(clk, reset, resetvalue, cs, we, value, data);

parameter WIDTH = 16;

input wire clk;
input wire reset;
input wire [WIDTH-1:0] resetvalue;
input wire cs;
input wire we;
output reg [WIDTH-1:0] value;
inout wire [WIDTH-1:0] data;

wire cs_wr = cs & we;
wire cs_rd = cs & ~we;

assign data = cs_rd ? value : {WIDTH{1'bz}};

wire [WIDTH-1:0] write_mux = cs_wr ? data : value;
wire [WIDTH-1:0] value_mux = reset ? resetvalue : write_mux;

always @(posedge clk)
begin	
	value <= value_mux;
end

endmodule
