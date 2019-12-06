`timescale 1ns / 1ps
module SD_Write_Buffer
(
    clk,
    reset,
    data,
    addr,
    we,
    buffer
);
    input clk;
	input reset;
	input [15:0]data;
	input [7:0]addr;
	input we;
	output reg [4095:0]buffer;

    always @(negedge clk or posedge reset) begin
		if(reset) begin
			buffer <= 4096'd0;
		end else begin
			if(we) begin
				buffer[{addr, 4'd15}] <= data[0];
				buffer[{addr, 4'd14}] <= data[1];
				buffer[{addr, 4'd13}] <= data[2];
				buffer[{addr, 4'd12}] <= data[3];
				buffer[{addr, 4'd11}] <= data[4];
				buffer[{addr, 4'd10}] <= data[5];
				buffer[{addr, 4'd9}] <= data[6];
				buffer[{addr, 4'd8}] <= data[7];
				buffer[{addr, 4'd7}] <= data[8];
				buffer[{addr, 4'd6}] <= data[9];
				buffer[{addr, 4'd5}] <= data[10];
				buffer[{addr, 4'd4}] <= data[11];
				buffer[{addr, 4'd3}] <= data[12];
				buffer[{addr, 4'd2}] <= data[13];
				buffer[{addr, 4'd1}] <= data[14];
				buffer[{addr, 4'd0}] <= data[15];
			end	
		end
	end
endmodule
