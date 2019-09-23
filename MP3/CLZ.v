`timescale 1ns / 1ps
module CLZ
(
	DATA_IN,
    RESULT
);
    input [31:0]DATA_IN;
    
	output [31:0]RESULT;

    reg [31:0] RESULT;
    always @(*) begin
	 	if(DATA_IN[31:0] == 32'b0)       RESULT = 32'd32;
	 	else if(DATA_IN[31:0] == 32'b1)  RESULT = 32'd31;
	 	else if(DATA_IN[31:1] == 31'b1)  RESULT = 32'd30;
	 	else if(DATA_IN[31:2] == 30'b1)  RESULT = 32'd29;
	 	else if(DATA_IN[31:3] == 29'b1)  RESULT = 32'd28;
	 	else if(DATA_IN[31:4] == 28'b1)  RESULT = 32'd27;
	 	else if(DATA_IN[31:5] == 27'b1)  RESULT = 32'd26;
	 	else if(DATA_IN[31:6] == 26'b1)  RESULT = 32'd25;
	 	else if(DATA_IN[31:7] == 25'b1)  RESULT = 32'd24;
	 	else if(DATA_IN[31:8] == 24'b1)  RESULT = 32'd23;
	 	else if(DATA_IN[31:9] == 23'b1)  RESULT = 32'd22;
	 	else if(DATA_IN[31:10] == 22'b1) RESULT = 32'd21;
	 	else if(DATA_IN[31:11] == 21'b1) RESULT = 32'd20;
	 	else if(DATA_IN[31:12] == 20'b1) RESULT = 32'd19;
	 	else if(DATA_IN[31:13] == 19'b1) RESULT = 32'd18;
	 	else if(DATA_IN[31:14] == 18'b1) RESULT = 32'd17;
	 	else if(DATA_IN[31:15] == 17'b1) RESULT = 32'd16;
	 	else if(DATA_IN[31:16] == 16'b1) RESULT = 32'd15;
	 	else if(DATA_IN[31:17] == 15'b1) RESULT = 32'd14;
	 	else if(DATA_IN[31:18] == 14'b1) RESULT = 32'd13;
	 	else if(DATA_IN[31:19] == 13'b1) RESULT = 32'd12;
	 	else if(DATA_IN[31:20] == 12'b1) RESULT = 32'd11;
	 	else if(DATA_IN[31:21] == 11'b1) RESULT = 32'd10;
	 	else if(DATA_IN[31:22] == 10'b1) RESULT = 32'd9;
	 	else if(DATA_IN[31:23] == 9'b1)  RESULT = 32'd8;
	 	else if(DATA_IN[31:24] == 8'b1)  RESULT = 32'd7;
	 	else if(DATA_IN[31:25] == 7'b1)  RESULT = 32'd6;
	 	else if(DATA_IN[31:26] == 6'b1)  RESULT = 32'd5;
	 	else if(DATA_IN[31:27] == 5'b1)  RESULT = 32'd4;
	 	else if(DATA_IN[31:28] == 4'b1)  RESULT = 32'd3;
	 	else if(DATA_IN[31:29] == 3'b1)  RESULT = 32'd2;
	 	else if(DATA_IN[31:30] == 2'b1)  RESULT = 32'd1;
	 	else                             RESULT = 32'd0;
	end
endmodule