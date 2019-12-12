`timescale 1ns / 1ps
module SD_Read_Div
(
	input [4095:0]data_in,
	input [6:0]addr,
	output [31:0]data_out
);
	assign data_out[31] = data_in[{addr, 5'd0}];
	assign data_out[30] = data_in[{addr, 5'd1}];
	assign data_out[29] = data_in[{addr, 5'd2}];
	assign data_out[28] = data_in[{addr, 5'd3}];
	assign data_out[27] = data_in[{addr, 5'd4}];
	assign data_out[26] = data_in[{addr, 5'd5}];
	assign data_out[25] = data_in[{addr, 5'd6}];
	assign data_out[24] = data_in[{addr, 5'd7}];
	assign data_out[23] = data_in[{addr, 5'd8}];
	assign data_out[22] = data_in[{addr, 5'd9}];
	assign data_out[21] = data_in[{addr, 5'd10}];
	assign data_out[20] = data_in[{addr, 5'd11}];
	assign data_out[19] = data_in[{addr, 5'd12}];
	assign data_out[18] = data_in[{addr, 5'd13}];
	assign data_out[17] = data_in[{addr, 5'd14}];
	assign data_out[16] = data_in[{addr, 5'd15}];
	assign data_out[15] = data_in[{addr, 5'd16}];
	assign data_out[14] = data_in[{addr, 5'd17}];
	assign data_out[13] = data_in[{addr, 5'd18}];
	assign data_out[12] = data_in[{addr, 5'd19}];
	assign data_out[11] = data_in[{addr, 5'd20}];
	assign data_out[10] = data_in[{addr, 5'd21}];
	assign data_out[9] = data_in[{addr, 5'd22}];
	assign data_out[8] = data_in[{addr, 5'd23}];
	assign data_out[7] = data_in[{addr, 5'd24}];
	assign data_out[6] = data_in[{addr, 5'd25}];
	assign data_out[5] = data_in[{addr, 5'd26}];
	assign data_out[4] = data_in[{addr, 5'd27}];
	assign data_out[3] = data_in[{addr, 5'd28}];
	assign data_out[2] = data_in[{addr, 5'd29}];
	assign data_out[1] = data_in[{addr, 5'd30}];
	assign data_out[0] = data_in[{addr, 5'd31}];
endmodule
