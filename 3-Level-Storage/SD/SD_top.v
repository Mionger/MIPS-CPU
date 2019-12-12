`timescale 1ns / 1ps
module SD_top
(
	clk,
	reset,
	sdclk,
	dout,
	din,
	cs,
	led,
	switch,
	up,
	down,
	right
);
	input clk;
	input reset;
	input dout;
	input [15:0]switch;
	input up;
	input down;
	input right;

	output sdclk;
	output din;
	output cs;
	output [15:0]led;

	wire [31:0]sd_addr_read;
	wire [31:0]sd_addr_write;
	wire [4095:0]data_to_sd;
	wire [4095:0]data_from_sd;
	wire sd_we;
	wire sd_re;
	wire [3:0]buffer_state;
	wire [3:0]controller_state;
	assign sd_addr_read = 32'd0;
	assign sd_addr_write = 32'd0;

	SD_Buffer sd_buffer
	(
		.clk(clk),
		.reset(reset),
		.addr(sd_addr_write),
		.sd_buffer_we(right),
		.sd_buffer_data_in({16'd0,switch}),
		.sd_buffer_data_out(data_to_sd),
		.sd_buffer_write_end(sd_we),
		.state(buffer_state)
	);

	SD_Controller sd_controller
	(
		.clk(clk),
		.reset(reset),
		.sd_clk(sdclk),
		.sd_dout(dout),
		.sd_din(din),
    	.sd_cs(cs),
    	.sd_ctrl_addr_read(sd_addr_read),
    	.sd_ctrl_addr_write(sd_addr_write),
    	.sd_ctrl_re(up),
    	.sd_ctrl_we(down),
    	.sd_ctrl_data_read(data_from_sd),
    	.sd_ctrl_data_write(data_to_sd),
    	.state(controller_state)
	);

	wire [31:0]div_out;
	SD_Read_Div sd_read_div(data_from_sd,7'b0,div_out);
	assign led = switch[15]?div_out[15:0]:{8'd0,controller_state,buffer_state};

endmodule