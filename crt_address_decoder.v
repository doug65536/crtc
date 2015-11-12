// Convert address to simple one-hot bus
module crt_address_decoder(addr, cs, q);

localparam WIDTH = 4;
localparam OUTPUT_WIDTH = {1'b1, {WIDTH{1'b0}}};

input [WIDTH-1:0] addr;
input cs;
output [OUTPUT_WIDTH-1:0] q;

reg [OUTPUT_WIDTH-1:0] m;
assign q = m & {OUTPUT_WIDTH{cs}};

always @(addr)
begin
	case(addr)
	default: m = 16'b0;
	4'h0: m = 16'b0000000000000001;
	4'h1: m = 16'b0000000000000010;
	4'h2: m = 16'b0000000000000100;
	4'h3: m = 16'b0000000000001000;
	4'h4: m = 16'b0000000000010000;
	4'h5: m = 16'b0000000000100000;
	4'h6: m = 16'b0000000001000000;
	4'h7: m = 16'b0000000010000000;
	4'h8: m = 16'b0000000100000000;
	4'h9: m = 16'b0000001000000000;
	4'hA: m = 16'b0000010000000000;
	4'hB: m = 16'b0000100000000000;
	4'hC: m = 16'b0001000000000000;
	4'hD: m = 16'b0010000000000000;
	4'hE: m = 16'b0100000000000000;
	4'hF: m = 16'b1000000000000000;
	endcase
end

endmodule
