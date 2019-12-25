`timescale 1ns / 1ps
module SD_Read
(
    sdclk,
    reset,
    addr,
    re,
    dout,
    cs,
    din,
    rdata,
    rend,
    rerr
);

    input sdclk;
	input reset;
	input [31:0]addr;
	input re;
	input dout;
	output reg cs;
	output reg din;
	output [4095:0]rdata;
	output reg rend;
	output reg rerr;

	parameter CMD17_HEAD = 8'h51;
	parameter CMD17_CRC = 8'hFF;
	parameter CMD17_RSPS = 8'h00;

	reg [47:0]cmd_reg; // = {CMD17_HEAD, addr, CMD17_CRC};
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
			din <= 1'b1;
		end else begin
			if(cmd_update) begin
				cmd_reg <= {CMD17_HEAD, addr, CMD17_CRC};
				din <= 1'b1;
			end else begin
				if(cmd_send_ena) begin
					if(cmd_cnt >= 6'd1 && cmd_cnt <= 6'd48) begin
						cmd_reg <= {cmd_reg[46:0], 1'b1};
						din <= cmd_reg[47];
					end else begin
						cmd_reg <= cmd_reg;
						din <= 1'b1;
					end
				end else begin
					cmd_reg <= cmd_reg;
					din <= 1'b1;
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

	reg r_reg_clear = 1'b0; // 由状态机控制
	reg r_reg_ena = 1'b0; // 由状态机控制
	reg [4096:0]r_reg = {4097{1'b1}};
	assign rdata = r_reg[4096:1];

	always @(posedge sdclk or posedge reset or posedge r_reg_clear) begin
		if(reset || r_reg_clear) begin
			// rdata <= 4096'b0;
			r_reg <= {4097{1'b1}};
		end else begin
			if(r_reg_ena) begin
				if(r_reg[0]) begin
					r_reg <= {dout, r_reg[4096:1]};
					// rdata <= r_reg[4096:1];
				end else begin
					r_reg <= r_reg; // 如果首位为0，说明之后开始为读出的数据
					// rdata <= r_reg[4096:1];
				end
			end else begin
				// rdata <= rdata;
				r_reg <= r_reg;
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

	
	parameter IDLE = 8'd1;
	parameter RCMD_PRE = 8'd2;
	parameter RCMD_SEND = 8'd4;
	parameter RCMD_RSPS = 8'd8;
	parameter READ = 8'd16;
	parameter PAUSE = 8'd32;
	parameter END = 8'd64;
	parameter ERROR = 8'd128;

	reg [7:0]current_state = IDLE;
	reg [7:0]next_state = IDLE;

	// assign st = current_state;

	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			current_state <= IDLE;
		end else begin
			if(re) begin
				current_state <= next_state;
			end else begin
				current_state <= IDLE;
			end
		end
	end

	always @(*) begin
		case(current_state)
			IDLE: begin
				if(re) begin
					next_state = RCMD_PRE;
				end else begin
					next_state = IDLE;
				end
			end
			RCMD_PRE: begin
				next_state = RCMD_SEND;
			end
			RCMD_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = RCMD_RSPS;
				end else begin
					next_state = RCMD_SEND;
				end
			end
			RCMD_RSPS: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == CMD17_RSPS) begin
						next_state = READ;
					end else begin
						next_state = ERROR;
					end
				end else begin
					next_state = RCMD_RSPS;
				end
			end
			READ: begin
				if(r_reg[0]) begin
					next_state = READ;
				end else begin
					next_state = PAUSE;
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
				if(re) begin
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

	// reg cmd_update = 1'b0;  // 由状态机控制
	// reg cmd_send_ena = 1'b0;  // 由状态机控制
	// reg rsps_read_ena = 1'b0; // 由状态机控制
	always @(*) begin
		case(current_state)
			RCMD_PRE: begin
				cmd_update = 1'b1;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
			end
			RCMD_SEND: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b1;
				rsps_read_ena = 1'b0;
			end
			RCMD_RSPS: begin
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

	// r_reg_ena
	always @(*) begin
		case(current_state)
			IDLE: begin
				r_reg_clear = 1'b0;
				r_reg_ena = 1'b0;
			end
			RCMD_PRE: begin
				r_reg_clear = 1'b1;
				r_reg_ena = 1'b0;
			end
			READ: begin
				r_reg_clear = 1'b0;
				r_reg_ena = 1'b1;
			end
			default: begin
				r_reg_clear = 1'b0;
				r_reg_ena = 1'b0;
			end
		endcase
	end

	// reg empty_clk_ena = 1'b0; // 由状态机控制
	always @(*) begin
		case(current_state)
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
			END: begin
				rend = 1'b1;
				rerr = 1'b0;
			end
			ERROR: begin
				rend = 1'b0;
				rerr = 1'b1;
			end
			default: begin
				rend = 1'b0;
				rerr = 1'b0;
			end
		endcase
	end

	// cs
	always @(*) begin
		case(current_state)
			RCMD_PRE: begin
				cs = 1'b0;
			end
			RCMD_SEND: begin
				cs = 1'b0;
			end
			RCMD_RSPS: begin
				cs = 1'b0;
			end
			READ: begin
				cs = 1'b0;
			end
			default: begin
				cs = 1'b1;
			end
		endcase
	end
endmodule
