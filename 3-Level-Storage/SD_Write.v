`timescale 1ns / 1ps
module SD_Write
(
    sdclk,
    reset,
    addr,
    wdata,
    we,
    dout,
    cs,
    din,
    wend,
    werr
);

    input sdclk;
	input reset;
	input [31:0]addr;
	input [4095:0]wdata;
	input we;
	input dout;
	output reg cs;
	output din;
	output reg wend;
	output reg werr;

    parameter CMD24_HEAD = 8'h58;
	parameter CMD24_CRC = 8'hFF;
	parameter CMD24_RSPS = 8'h00;

	reg din_cs = 1'b0; // 由状态机控制
	reg c_din = 1'b1; // command
	reg d_din = 1'b1; // data
	assign din = din_cs? d_din: c_din;

	reg [47:0]cmd_reg; // = {CMD24_HEAD, addr, CMD24_CRC};
	reg cmd_update = 1'b0;  // 由状态机控制
	reg cmd_send_ena = 1'b0;  // 由状态机控制
	reg [5:0]cmd_cnt = 6'b0;

	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			cmd_cnt <= 6'b0;
		end else begin
			if(cmd_send_ena) begin
				cmd_cnt <= cmd_cnt + 1'b1;
			end else begin
				cmd_cnt <= 6'b0;
			end
		end
	end
	
	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			cmd_reg <= 48'HFF_FF_FF_FF_FF_FF;
			c_din <= 1'b1;
		end else begin
			if(cmd_update) begin
				cmd_reg <= {CMD24_HEAD, addr, CMD24_CRC};
				c_din <= 1'b1;
			end else begin
				if(cmd_send_ena) begin
					if(cmd_cnt >= 6'd1 && cmd_cnt <= 6'd48) begin
						cmd_reg <= {cmd_reg[46:0], 1'b1};
						c_din <= cmd_reg[47];
					end else begin
						cmd_reg <= cmd_reg;
						c_din <= 1'b1;
					end
				end else begin
					cmd_reg <= cmd_reg;
					c_din <= 1'b1;
				end
			end
		end
	end

	reg [7:0]rsps_reg = 8'hFF;
	reg rsps_read_ena = 1'b0; // 由状态机控制

	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			rsps_reg <= 8'hFF;
		end else begin
			if(rsps_read_ena) begin
				if(rsps_reg[7]) begin
					rsps_reg <= {rsps_reg[6:0], dout};
				end else begin
					rsps_reg <= rsps_reg; // 首位为 0 说明接收结束
				end
			end else begin
				rsps_reg <= 8'hFF;
			end
		end
	end

	reg [4:0]empty_clk_cnt = 5'b0;
	reg empty_clk_ena = 1'b0; // 由状态机控制

	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			empty_clk_cnt <= 5'b0;
		end else begin
			if(empty_clk_ena) begin
				empty_clk_cnt <= empty_clk_cnt + 1'b1;
			end else begin
				empty_clk_cnt <= 5'b0;
			end
		end
	end

	reg [4097:0]w_reg = {4098{1'b1}};
	reg write_data_save = 1'b0; // 由状态机提供
	reg write_data_en = 1'b0; // 由状态机提供

	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			w_reg <= {4098{1'b1}};
			d_din <= 1'b1;
		end else begin
			if(write_data_save) begin
				w_reg <= {wdata, 1'b0, 1'b1};
				d_din <= 1'b1;
			end else begin
				if(write_data_en) begin
					d_din <= w_reg[0];
					w_reg <= {1'b1, w_reg[4097:1]};
				end else begin
					d_din <= 1'b1;
					w_reg <= w_reg;
				end
			end
		end
	end

	reg [12:0]w_cnt = 13'b0;
	reg w_cnt_ena = 1'b0; // 由状态机提供

	always @(posedge sdclk) begin
		if(w_cnt_ena) begin
			w_cnt <= w_cnt + 1'b1;
		end else begin
			w_cnt <= 13'b0;
		end
	end

	reg [7:0]dout_reg = 8'b0;
	always @(negedge sdclk) begin
		dout_reg <= {dout_reg[6:0], dout};
	end



	parameter IDLE = 11'd1;
	parameter WCMD_PRE = 11'd2;
	parameter WCMD_SEND = 11'd4;
	parameter WCMD_RSPS = 11'd8;
	parameter SEND_EMPTY_CLOCK = 11'd16;
	parameter WRITE = 11'd32;
	parameter WAIT_0x05 = 11'd64;
	parameter WAIT_0XFF = 11'd128;
	parameter PAUSE = 11'd256;
	parameter END = 11'd512;
	parameter ERROR = 11'd1024;

	reg [10:0]current_state = IDLE;
	reg [10:0]next_state = IDLE;

	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	always @(*) begin
		case(current_state)
			IDLE: begin
				if(we) begin
					next_state = WCMD_PRE;
				end else begin
					next_state = IDLE;
				end
			end
			WCMD_PRE: begin
				next_state = WCMD_SEND;
			end
			WCMD_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = WCMD_RSPS;
				end else begin
					next_state = WCMD_SEND;
				end
			end
			WCMD_RSPS: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == CMD24_RSPS) begin
						next_state = SEND_EMPTY_CLOCK;
					end else begin
						next_state = ERROR;
					end
				end else begin
					next_state = WCMD_RSPS;
				end
			end
			SEND_EMPTY_CLOCK: begin
				if(empty_clk_cnt[4]) begin
					next_state = WRITE;
				end else begin
					next_state = SEND_EMPTY_CLOCK;
				end
			end
			WRITE: begin
				if(w_cnt == 13'd4099) begin
					next_state = WAIT_0x05;
				end else begin
					next_state = WRITE;
				end
			end
			WAIT_0x05: begin
				if(dout_reg != 8'hFF) begin
					next_state = WAIT_0XFF;
				end else begin
					next_state = WAIT_0x05;
				end
			end
			WAIT_0XFF: begin
				if(dout_reg == 8'hFF) begin
					next_state = PAUSE;
				end else begin
					next_state = WAIT_0XFF;
				end
			end
			PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = END;
				end else begin
					next_state = PAUSE;
				end
			end
			END: begin
				if(we) begin
					next_state = END;
				end else begin
					next_state = IDLE;
				end
			end
			ERROR: begin
				next_state = ERROR;
			end
			default: begin
				next_state = IDLE;
			end
		endcase
	end

	always @(*) begin
		case(current_state)
			WCMD_PRE: begin
				cmd_update = 1'b1;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
			end
			WCMD_SEND: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b1;
				rsps_read_ena = 1'b0;
			end
			WCMD_RSPS: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b1;
			end
			default: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
			end
		endcase
	end

	always @(*) begin
		case(current_state)
			SEND_EMPTY_CLOCK: begin
				empty_clk_ena = 1'b1;
			end
			PAUSE: begin
				empty_clk_ena = 1'b1;
			end
			default: begin
				empty_clk_ena = 1'b0;
			end
		endcase
	end

	always @(*) begin
		case(current_state)
			SEND_EMPTY_CLOCK: begin
				write_data_save = 1'b1;
				write_data_en = 1'b0;
				w_cnt_ena = 1'b0;
			end
			WRITE: begin
				write_data_save = 1'b0;
				write_data_en = 1'b1;
				w_cnt_ena = 1'b1;
			end
			default: begin
				write_data_save = 1'b0;
				write_data_en = 1'b0;
				w_cnt_ena = 1'b0;
			end
		endcase
	end

	always @(*) begin
		case(current_state)
			WCMD_PRE: begin
				cs = 1'b0;
			end
			WCMD_SEND: begin
				cs = 1'b0;
			end
			WCMD_RSPS: begin
				cs = 1'b0;
			end
			SEND_EMPTY_CLOCK: begin
				cs = 1'b0;
			end
			WRITE: begin
				cs = 1'b0;
			end
			WAIT_0x05: begin
				cs = 1'b0;
			end
			WAIT_0XFF: begin
				cs = 1'b0;
			end
			default: begin
				cs = 1'b1;
			end
		endcase
	end

	always @(*) begin
		case(current_state)
			END: begin
				wend = 1'b1;
				werr = 1'b0;
			end
			ERROR: begin
				wend = 1'b0;
				werr = 1'b1;
			end
			default: begin
				wend = 1'b0;
				werr = 1'b0;
			end
		endcase
	end

	always @(*) begin
		case(current_state)
			WRITE: begin
				din_cs = 1'b1;
			end
			default: begin
				din_cs = 1'b0;
			end
		endcase
	end
endmodule
