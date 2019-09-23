`timescale 1ns / 1ps
module HI
(
	CLK,
    ENA,
    HI_IN,
    HI_OUT
);
    input CLK;
	input ENA;
	input [31:0]HI_IN;
	output [31:0]HI_OUT;

	reg [31:0]hi = 32'b0;
	always @(negedge CLK) begin
		if(ENA) begin
			hi <= HI_IN;
		end else begin
			hi <= hi;
		end
	end

	assign HI_OUT = hi;
endmodule