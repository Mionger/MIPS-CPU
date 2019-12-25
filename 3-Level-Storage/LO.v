`timescale 1ns / 1ps
module LO
(
	CLK,
    ENA,
    LO_IN,
    LO_OUT
);
    input CLK;
	input ENA;
	input [31:0]LO_IN;
	output [31:0]LO_OUT;

	reg [31:0]lo = 32'b0;
	always @(negedge CLK) begin
		if(ENA) begin
			lo <= LO_IN;
		end else begin
			lo <= lo;
		end
	end

	assign LO_OUT = lo;
endmodule