//拼接器
module Concatenater
(
	pc,
	index,
	out_j
);
	input [31:28]pc;
	input [25:0]index;
	output [31:0]out_j;

	assign out_j = {pc[31:28], index[25:0], 2'b0};
endmodule