`timescale 1ns / 1ps
module ID
(
    ID_IN, 
    OP, 
    RSC, 
    RTC, 
    RDC, 
    SA, 
    FUNC, 
    IMME, 
    INDEX
);
	input [31:0]ID_IN;

	output [5:0]OP;
	output [4:0]RSC;
	output [4:0]RTC;
	output [4:0]RDC;
	output [4:0]SA;
	output [5:0]FUNC;
	output [15:0]IMME;
	output [25:0]INDEX;

	assign OP    = ID_IN[31:26];
	assign RSC   = ID_IN[25:21];
	assign RTC   = ID_IN[20:16];
	assign RDC   = ID_IN[15:11];
	assign SA    = ID_IN[10:6];
	assign FUNC  = ID_IN[5:0];
	assign IMME  = ID_IN[15:0];
	assign INDEX = ID_IN[25:0];
endmodule