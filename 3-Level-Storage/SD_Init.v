`timescale 1ns / 1ps
module SD_Init
(
    sdclk,
    reset,
    init_start,
    dout,
    cs,
    din,
    init_ok,
    init_err
);

    input sdclk;
    input reset;
    input init_start;
    input dout;

    output reg cs;
    output reg din;
    output reg init_ok;
    output reg init_err;

	//SD卡指令
	parameter CMD0 = 48'h40_00_00_00_00_95;
	parameter CMD0_RSPS = 8'h01; //RSPS for ReSPonSe

	parameter CMD8 = 48'h48_00_00_01_AA_87;
	parameter CMD8_HEAD = 8'h01;
	parameter CMD8_TAIL = 8'hAA;

	parameter CMD55 = 48'h77_00_00_00_00_65;
	parameter CMD55_WAIT_RSPS = 8'h01;
	parameter CMD55_OK_RSPS = 8'h00;

	parameter ACMD41 = 48'h69_40_00_00_00_77;
	parameter ACMD41_AGAIN_RSPS = 8'h01;
	parameter ACMD41_OK_RSPS = 8'h00;

	parameter INIT_CMD = 48'hFF_FF_FF_FF_FF_FF;


	reg [9:0]await_cnt = 10'b0;

	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			await_cnt <= 10'b0;
		end 
		else begin
			//start一直拉高
			if(init_start) begin
				if(await_cnt[9]) begin
					await_cnt <= await_cnt;
				end 
				else begin
					await_cnt <= await_cnt + 1'b1;
				end
			end 
			else begin
				await_cnt <= 10'b0;
			end
		end
	end

	reg [47:0]cmd_to_send = INIT_CMD; // 由状态机控制
	reg [47:0]cmd_reg = INIT_CMD;
	reg cmd_update = 1'b0;  // 由状态机控制
	reg cmd_send_ena = 1'b0;  // 由状态机控制
	reg [5:0]cmd_cnt = 6'b0;

	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			cmd_cnt <= 6'b0;
		end 
		else begin
			//处于发送状态，发送计数器变化
			if(cmd_send_ena) begin
				cmd_cnt <= cmd_cnt + 1'b1;
			end 
			//非发送状态，计数器清零
			else begin
				cmd_cnt <= 6'b0;
			end
		end
	end
	
	//命令发送
	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			cmd_reg <= INIT_CMD;
			din <= 1'b1;
		end 
		else begin
			if(cmd_update) begin
				cmd_reg <= cmd_to_send;
				din <= 1'b1;
			end 
			else begin
				if(cmd_send_ena) begin
					if(cmd_cnt >= 6'd1 && cmd_cnt <= 6'd48) begin
						cmd_reg <= {cmd_reg[46:0], 1'b1};
						din <= cmd_reg[47];
					end 
					else begin
						cmd_reg <= cmd_reg;
						din <= 1'b1;
					end
				end 
				else begin
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
		end 
		else begin
			if(rsps_read_ena) begin
				if(rsps_reg[7]) begin
					rsps_reg <= {rsps_reg[6:0], dout};
				end 
				else begin
					rsps_reg <= rsps_reg; // 首位为 0 说明接收结束
				end
			end 
			else begin
				rsps_reg <= 8'hFF;
			end
		end
	end

	reg [39:0]cmd8_rsps_reg = 40'hFF_FF_FF_FF_FF;
	reg cmd8_rsps_read_ena = 1'b0; // 由状态机控制

	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			cmd8_rsps_reg <= 40'hFF_FF_FF_FF_FF;
		end 
		else begin
			if(cmd8_rsps_read_ena) begin
				if(cmd8_rsps_reg[39]) begin
					cmd8_rsps_reg <= {cmd8_rsps_reg[38:0], dout};
				end 
				else begin
					cmd8_rsps_reg <= cmd8_rsps_reg; // 首位为 0 说明接收结束
				end
			end 
			else begin
				cmd8_rsps_reg <= 40'hFF_FF_FF_FF_FF;
			end
		end
	end

	reg [4:0]empty_clk_cnt = 5'b0;
	reg empty_clk_ena = 1'b0; // 由状态机控制

	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			empty_clk_cnt <= 5'b0;
		end 
		else begin
			if(empty_clk_ena) begin
				empty_clk_cnt <= empty_clk_cnt + 1'b1;
			end 
			else begin
				empty_clk_cnt <= 5'b0;
			end
		end
	end


	// all states
	parameter AWAIT = 5'd0;
	parameter CMD0_PRE = 5'd1;
	parameter CMD0_SEND = 5'd2;
	parameter CMD0_RCV = 5'd3;
	parameter CMD0_PAUSE = 5'd4;
	parameter CMD8_PRE = 5'd5;
    parameter CMD8_SEND = 5'd6;
    parameter CMD8_RCV = 5'd7;
    parameter CMD8_PAUSE = 5'd8;
	parameter CMD55_PRE = 5'd9;
	parameter CMD55_SEND = 5'd10;
	parameter CMD55_RCV = 5'd11;
	parameter CMD55_PAUSE = 5'd12;
	parameter ACMD41_PRE = 5'd13;
	parameter ACMD41_SEND = 5'd14;
	parameter ACMD41_RCV = 5'd15;
	parameter ACMD41_AGAIN_PAUSE = 5'd16;
	parameter ACMD41_SUCCESS_PAUSE = 5'd17;
	parameter SUCCESS = 5'd18;
	parameter ERROR = 5'd19;

	reg [4:0]current_state = AWAIT;
	reg [4:0]next_state = AWAIT;

	//状态转移
	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			current_state <= AWAIT;
		end 
		else begin
			current_state <= next_state;
		end
	end

	//状态转移条件
	always @(*) begin
		case(current_state)
			AWAIT: begin
				//开始信号一直拉高
				if(init_start && await_cnt[9]) begin
					next_state = CMD0_PRE;
				end 
				else begin
					next_state = AWAIT;
				end
			end
			CMD0_PRE: begin
				next_state = CMD0_SEND;
			end
			CMD0_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = CMD0_RCV;
				end 
				//没发够48位，继续发送
				else begin
					next_state = CMD0_SEND;
				end
			end
			CMD0_RCV: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == CMD0_RSPS) begin
						next_state = CMD0_PAUSE;
					end 
					else begin
						next_state = ERROR;
					end
				end 
				else begin
					next_state = CMD0_RCV;
				end
			end
			CMD0_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = CMD8_PRE;
				end 
				else begin
					next_state = CMD0_PAUSE;
				end
			end
			CMD8_PRE: begin
				next_state = CMD8_SEND;
			end
			CMD8_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = CMD8_RCV;
				end 
				else begin
					next_state = CMD8_SEND;
				end
			end
			CMD8_RCV: begin
				if(cmd8_rsps_reg[39] == 1'b0) begin
					if(cmd8_rsps_reg[39:32] == CMD8_HEAD && cmd8_rsps_reg[7:0] == CMD8_TAIL) begin
						next_state = CMD8_PAUSE;
					end 
					else begin
						next_state = ERROR;
					end
				end 
				else begin
					next_state = CMD8_RCV;
				end
			end
			CMD8_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = CMD55_PRE;
				end 
				else begin
					next_state = CMD8_PAUSE;
				end
			end
			CMD55_PRE: begin
				next_state = CMD55_SEND;
			end
			CMD55_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = CMD55_RCV;
				end 
				else begin
					next_state = CMD55_SEND;
				end
			end
			CMD55_RCV: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == CMD55_WAIT_RSPS || rsps_reg == CMD55_OK_RSPS) begin
						next_state = CMD55_PAUSE;
					end 
					else begin
						next_state = ERROR;
					end
				end 
				else begin
					next_state = CMD55_RCV;
				end
			end
			CMD55_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = ACMD41_PRE;
				end 
				else begin
					next_state = CMD55_PAUSE;
				end
			end
			ACMD41_PRE: begin
				next_state = ACMD41_SEND;
			end
			ACMD41_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = ACMD41_RCV;
				end 
				else begin
					next_state = ACMD41_SEND;
				end
			end
			ACMD41_RCV: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == ACMD41_AGAIN_RSPS) begin
						next_state = ACMD41_AGAIN_PAUSE;
					end 
					else if(rsps_reg == ACMD41_OK_RSPS) begin 
						next_state = ACMD41_SUCCESS_PAUSE;
					end 
					else begin
						next_state = ERROR;
					end
				end else begin
					next_state = ACMD41_RCV;
				end
			end
			ACMD41_AGAIN_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = CMD55_PRE;
				end 
				else begin
					next_state = ACMD41_AGAIN_PAUSE;
				end
			end
			ACMD41_SUCCESS_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = SUCCESS;
				end 
				else begin
					next_state = ACMD41_SUCCESS_PAUSE;
				end
			end
			SUCCESS: begin
				next_state = SUCCESS;
			end
			ERROR: begin
				next_state = ERROR;
			end
			default: begin
				next_state = AWAIT;
			end
		endcase
	end

	//控制待发送命令
	always @(*) begin
		case(current_state)
			CMD0_PRE: begin
				cmd_to_send = CMD0;
			end
			CMD8_PRE: begin
				cmd_to_send = CMD8;
			end
			CMD55_PRE: begin
				cmd_to_send = CMD55;
			end
			ACMD41_PRE: begin
				cmd_to_send = ACMD41;
			end
			default: begin
				cmd_to_send = INIT_CMD;
			end
		endcase
	end

	// reg cmd_update = 1'b0;  // 由状态机控制
	// reg cmd_send_ena = 1'b0;  // 由状态机控制
	// reg rsps_read_ena = 1'b0; // 由状态机控制
	always @(*) begin
		case(current_state)
			CMD0_PRE: begin
				cmd_update = 1'b1;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			CMD0_SEND: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b1;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			CMD0_RCV: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b1;
				cmd8_rsps_read_ena = 1'b0;
			end
			CMD8_PRE: begin
				cmd_update = 1'b1;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			CMD8_SEND: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b1;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			CMD8_RCV: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b1;
			end
			CMD55_PRE: begin
				cmd_update = 1'b1;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			CMD55_SEND: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b1;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			CMD55_RCV: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b1;
				cmd8_rsps_read_ena = 1'b0;
			end
			ACMD41_PRE: begin
				cmd_update = 1'b1;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			ACMD41_SEND: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b1;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
			ACMD41_RCV: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b1;
				cmd8_rsps_read_ena = 1'b0;
			end
			default: begin
				cmd_update = 1'b0;
				cmd_send_ena = 1'b0;
				rsps_read_ena = 1'b0;
				cmd8_rsps_read_ena = 1'b0;
			end
		endcase
	end


	// reg empty_clk_ena = 1'b0; // 由状态机控制
	always @(*) begin
		case(current_state)
			CMD0_PAUSE: begin
				empty_clk_ena = 1'b1;
			end
			CMD8_PAUSE: begin
				empty_clk_ena = 1'b1;
			end
			CMD55_PAUSE: begin
				empty_clk_ena = 1'b1;
			end
			ACMD41_AGAIN_PAUSE: begin
				empty_clk_ena = 1'b1;
			end
			ACMD41_SUCCESS_PAUSE: begin
				empty_clk_ena = 1'b1;
			end
			default: begin
				empty_clk_ena = 1'b0;
			end
		endcase
	end

	always @(*) begin
		case(current_state)
			CMD0_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD0_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD0_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD8_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD8_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD8_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD55_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD55_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			CMD55_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			ACMD41_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			ACMD41_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			ACMD41_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
			ERROR: begin
				cs = 1'b1;
				init_ok = 1'b0;
				init_err = 1'b1;
			end
			SUCCESS: begin
				cs = 1'b1;
				init_ok = 1'b1;
				init_err = 1'b0;
			end
			default: begin
				cs = 1'b1;
				init_ok = 1'b0;
				init_err = 1'b0;
			end
		endcase
	end
endmodule
