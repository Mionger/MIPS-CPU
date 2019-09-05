`timescale 1ns / 1ps
module RegFile
(
    CLK, 
    RST, 
    RF_W, 
    RSC, 
    RTC, 
    RDC, 
    RD, 
    RS, 
    RT
);

	input CLK;
	input RST;
	input RF_W;//高电平：写；低电平：读
	input [4:0]RSC;
	input [4:0]RTC;
	input [4:0]RDC;
	input [31:0]RD;
	output [31:0]RS;
	output [31:0]RT;

	reg [31:0]array_reg[31:0];

	always @(negedge CLK or posedge RST) begin
		if(RST) begin
			array_reg[0] <= 32'b0;
			array_reg[1] <= 32'b0;
			array_reg[2] <= 32'b0;
			array_reg[3] <= 32'b0;
			array_reg[4] <= 32'b0;
			array_reg[5] <= 32'b0;
			array_reg[6] <= 32'b0;
			array_reg[7] <= 32'b0;
			array_reg[8] <= 32'b0;
			array_reg[9] <= 32'b0;
			array_reg[10] <= 32'b0;
			array_reg[11] <= 32'b0;
			array_reg[12] <= 32'b0;
			array_reg[13] <= 32'b0;
			array_reg[14] <= 32'b0;
			array_reg[15] <= 32'b0;
			array_reg[16] <= 32'b0;
			array_reg[17] <= 32'b0;
			array_reg[18] <= 32'b0;
			array_reg[19] <= 32'b0;
			array_reg[20] <= 32'b0;
			array_reg[21] <= 32'b0;
			array_reg[22] <= 32'b0;
			array_reg[23] <= 32'b0;
			array_reg[24] <= 32'b0;
			array_reg[25] <= 32'b0;
			array_reg[26] <= 32'b0;
			array_reg[27] <= 32'b0;
			array_reg[28] <= 32'b0;
			array_reg[29] <= 32'b0;
			array_reg[30] <= 32'b0;
			array_reg[31] <= 32'b0;
		end else begin
			if(RF_W && (RDC != 5'b0)) begin
				array_reg[RDC] <= RD;
			end else begin
				array_reg[RDC] <= array_reg[RDC];
			end
		end
	end

	assign RS = array_reg[RSC];
	assign RT = array_reg[RTC];
endmodule