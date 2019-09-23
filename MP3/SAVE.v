`timescale 1ns / 1ps
module SAVE
(
	CLK,
    ENA,
    SAVE_IN,
    SAVE_OUT
);
    input CLK;
	input ENA;
	input [31:0]SAVE_IN;
	output [31:0]SAVE_OUT;

	reg [31:0]save = 32'b0;
	always @(negedge CLK) begin
		if(ENA) begin
			save <= SAVE_IN;
		end else begin
			save <= save;
		end
	end

	assign SAVE_OUT = save;
endmodule