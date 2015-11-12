module fifo(
	clk,
	reset,
	wr_en,
	rd_en,
	wr_data,
	rd_data, 
	not_full,
	not_empty,
	error
);

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 4;
localparam FIFO_SIZE = {1'b1, {(ADDR_WIDTH){1'b0}}};

input clk;
input reset;
input wr_en;
input rd_en;
input [DATA_WIDTH-1:0] wr_data;
output [DATA_WIDTH-1:0] rd_data;
output not_full;
output not_empty;
output error;

reg [DATA_WIDTH-1:0] queue[0:FIFO_SIZE-1];
reg [ADDR_WIDTH-1:0] rd_index;
reg [ADDR_WIDTH-1:0] wr_index;
reg [ADDR_WIDTH:0] count;

// Precompute several reused things

wire [ADDR_WIDTH-1:0] next_rd_index = rd_index + 1'b1;
wire [ADDR_WIDTH-1:0] next_wr_index = wr_index + 1'b1;

wire [ADDR_WIDTH:0] increase_count = count + 1'b1;
wire [ADDR_WIDTH:0] decrease_count = count - 1'b1;

`ifdef USE_SEQUENTIAL
reg rd_buffer;
reg not_empty_buffer;
reg not_full_buffer;

always @(posedge clk)
begin
	rd_buffer <= queue[rd_index];
	not_empty_buffer <= |count;
	not_full_buffer <= ~count[ADDR_WIDTH];
end
assign not_full = not_full_buffer;
assign not_empty = not_empty_buffer;
assign rd_data = rd_buffer;
`else
assign not_full = ~count[ADDR_WIDTH];
assign not_empty = |count;
assign rd_data = queue[rd_index];
`endif

always @(posedge clk or posedge reset)
begin
	if (reset)
	begin
		wr_index <= 1'b0;
		rd_index <= 1'b0;
		count <= 1'b0;
	end
	else if (rd_en & wr_en)
	begin
		// Read and write at the same time
		queue[wr_index] <= wr_data;
		rd_index <= next_rd_index;
		wr_index <= next_wr_index;
	end
	else if (wr_en)
	begin
		// Only write
		queue[wr_index] <= wr_data;
		wr_index <= next_wr_index;
		count <= increase_count;
	end
	else if (rd_en)
	begin
		// Only read
		rd_index <= next_rd_index;
		count <= decrease_count;
	end
end

endmodule
