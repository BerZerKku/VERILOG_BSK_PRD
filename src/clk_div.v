module clk_div #( 
	parameter FREQ_CLK = 2_000_000, 
	parameter FREQ_OUT =   250_000
) ( 
	input  wire	clk_in, 
	input  wire	aclr, 
	output reg  clk_out
);

localparam CNT_MAX = (FREQ_CLK / FREQ_OUT / 2);
localparam WIDTH   = $clog2(CNT_MAX); 	

reg [WIDTH - 1:0] counter = 0;

initial begin
	clk_out <= 1'b0;
end
 
always @ (posedge clk_in or posedge aclr) begin : clk_out_generate
	if (aclr) begin
		counter <= 0;
		clk_out <= 1'b0;
	end
	else if (counter == 0) begin
		counter <= CNT_MAX - 1;
		clk_out <= ~clk_out;
	end
	else begin
		counter <= counter - 1'b1;
	end
end

endmodule