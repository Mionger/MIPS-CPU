`timescale 1ns / 1ps
module SD_Read_Div
(
	input [4095:0]data_in,
	input [7:0]addr,
	output [15:0]data_out
);
	assign data_out[15] = data_in[{addr, 4'd0}];
	assign data_out[14] = data_in[{addr, 4'd1}];
	assign data_out[13] = data_in[{addr, 4'd2}];
	assign data_out[12] = data_in[{addr, 4'd3}];
	assign data_out[11] = data_in[{addr, 4'd4}];
	assign data_out[10] = data_in[{addr, 4'd5}];
	assign data_out[9] = data_in[{addr, 4'd6}];
	assign data_out[8] = data_in[{addr, 4'd7}];
	assign data_out[7] = data_in[{addr, 4'd8}];
	assign data_out[6] = data_in[{addr, 4'd9}];
	assign data_out[5] = data_in[{addr, 4'd10}];
	assign data_out[4] = data_in[{addr, 4'd11}];
	assign data_out[3] = data_in[{addr, 4'd12}];
	assign data_out[2] = data_in[{addr, 4'd13}];
	assign data_out[1] = data_in[{addr, 4'd14}];
	assign data_out[0] = data_in[{addr, 4'd15}];
endmodule
