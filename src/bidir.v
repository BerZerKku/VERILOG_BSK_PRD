module bidir (oe, bidir);

// Port Declaration

input   oe;
inout   [7:0] bidir;

reg     [7:0] a;

assign bidir = oe ? a : 8'bZ ;

// Always Construct

initial begin
	a = '0;
end

always @ (negedge oe) begin
    a <= bidir;
end

endmodule