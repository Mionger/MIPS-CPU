module WriteSelect
(
	addr,
	we,
	DMEM_we
);
    input [31:0]addr;
	input we;
	output DMEM_we;
	
	assign DMEM_we = we;
endmodule