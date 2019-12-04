module ReadSelect
(
	addr,
	dmem,
	rdata
);
	input [31:0]addr;
	input [31:0]dmem;
	output [31:0]rdata;

    assign rdata = dmem;
endmodule