`timescale 1ns / 1ps
module R
(
	CLK,
    ENA,
    R_IN,
    R_OUT
);
    input CLK;
	input ENA;
	input [31:0]R_IN;
	output [31:0]R_OUT;

	reg [31:0]r;
	always @(negedge CLK) begin
		if(ENA) begin
			r <= R_IN;
		end else begin
			r <= r;
		end
	end

	assign R_OUT = r;
endmodule