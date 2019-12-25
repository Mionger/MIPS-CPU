`timescale 1ns / 1ps
module IR
(
	CLK,
    ENA,
    IR_IN,
    IR_OUT
);
    input CLK;
	input ENA;
	input [31:0]IR_IN;
	output [31:0]IR_OUT;

	reg [31:0]ir = 32'b0;
	always @(negedge CLK) begin
		if(ENA) begin
			ir <= IR_IN;
		end else begin
			ir <= ir;
		end
	end

	assign IR_OUT = ir;
endmodule