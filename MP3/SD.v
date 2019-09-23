module sd_top(
    input clk,
    input dout,
    input reset,
    input [15:0]sw,
    output sdclk,
    output din,
    output cs,
    output [15:0]led,
	output init_over,
	output r_end
);
    reg [9:0]cnt = 10'b0;
    always @(posedge clk) begin
        cnt <= cnt + 1'b1;
    end
    assign sdclk = cnt[9];
    
    wire ok, err, ini_din, r_din;
    wire ini_cs, r_cs;
    wire re;
    wire [4095:0]rdata;
    wire rend;

    reg state = 1'b0;
    always @(posedge sdclk) begin
    	if(ok) begin
    		state <= 1'b1;
    	end else begin
    		state <= 1'b0;
    	end
    end

    assign din = state? r_din: ini_din;
    assign cs = state? r_cs: ini_cs;
	
	//初始化成�????
    SD_Initialize SI(sdclk, reset, 1'b1, dout, ini_cs, ini_din, ok, err);
	assign init_ok = ok;

	//wire [7:0]STATUS;
    SD_Read SR(sdclk, reset, 32'd0, state, dout, r_cs, r_din, rdata, rend);//,STATUS);//ֱ��������ַ
	assign r_end = rend;
    wire [15:0]out;

	// assign out[7]=STATUS[7];
	// assign out[6]=STATUS[6];
	// assign out[5]=STATUS[5];
	// assign out[4]=STATUS[4];
	// assign out[3]=STATUS[3];
	// assign out[2]=STATUS[2];
	// assign out[1]=STATUS[1];
	// assign out[0]=STATUS[0];

	//多路选择�????
   	Read_Div RD(rdata, sw[7:0], out);
    assign led = out;
endmodule


module Read_Div(
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

module SD_Read(
	input sdclk,
	input reset,
	input [31:0]addr,
	input re,
	input dout,
	output reg cs,
	output reg din,
	output [4095:0]rdata,
	output reg rend//,
	//output [7:0]STATUS
);
	parameter CMD17_HEAD = 8'h51;
	parameter CMD17_CRC = 8'hFF;
	parameter CMD17_RSPS = 8'h00;

	reg [47:0]cmd_reg; // = {CMD17_HEAD, addr, CMD17_CRC};
	reg cmd_update = 1'b0;  // 由状态机控制
	reg cmd_send_ena = 1'b0;  // 由状态机控制
	reg [5:0]cmd_cnt = 6'b0;

	//计数器，指令发�?�位�????
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
	
	//串行发�?�指�????
	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			cmd_reg <= 48'HFF_FF_FF_FF_FF_FF;
			din <= 1'b1;
		end else begin
			if(cmd_update) begin
				cmd_reg <= {CMD17_HEAD, addr, CMD17_CRC};//addr直接做参数，�????要左移九�????
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

	//接收响应
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
					rsps_reg <= rsps_reg; // 首位�???? 0 说明接收结束
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
					r_reg <= r_reg; // 如果首位�????0，说明之后开始为读出的数�????
					// rdata <= r_reg[4096:1];
				end
			end else begin
				// rdata <= rdata;
				r_reg <= r_reg;
			end
			
		end
	end

	// 空时钟信�????
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
	parameter WCMD_PRE = 8'd2;
	parameter WCMD_SEND = 8'd4;
	parameter WCMD_RSPS = 8'd8;
	parameter READ = 8'd16;
	parameter PAUSE = 8'd32;
	parameter END = 8'd64;
	parameter ERROR = 8'd128;

	reg [7:0]current_state = IDLE;
	reg [7:0]next_state = IDLE;
	//assign STATUS=current_state;//
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
					if(rsps_reg == CMD17_RSPS) begin//CMD17的响�????0x00
						next_state = READ;
					end else begin
						next_state = ERROR;
					end
				end else begin
					next_state = WCMD_RSPS;
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
				if(empty_clk_cnt[4]) begin//8个空时钟
					next_state = END;
				end else begin
					next_state = PAUSE;
				end
			end
			END: begin
				next_state = END;
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

	// r_reg_ena
	always @(*) begin
		case(current_state)
			IDLE: begin
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
			end
			default: begin
				rend = 1'b0;
			end
		endcase
	end

	// cs
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
			READ: begin
				cs = 1'b0;
			end
			default: begin
				cs = 1'b1;
			end
		endcase
	end
endmodule

module SD_Initialize(
	input sdclk, // 初始化时时钟频率应小�???? 400KHz
	input reset,
	input start, // 是否�????始初始化
	input dout,
	output reg cs = 1'b1,
	output reg din = 1'b1,
	output reg init_ok = 1'b0,
	output reg err = 1'b0
);
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
		end else begin
			if(start) begin
				if(await_cnt[9]) begin
					await_cnt <= await_cnt;
				end else begin
					await_cnt <= await_cnt + 1'b1;
				end
			end else begin
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
			cmd_reg <= INIT_CMD;
			din <= 1'b1;
		end else begin
			if(cmd_update) begin
				cmd_reg <= cmd_to_send;
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

	// reg [7:0]rsps_buf = 8'b0;
	// reg rsps_start = 1'b0;
	// reg [3:0]rsps_cnt = 4'b0;
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
					rsps_reg <= rsps_reg; // 首位�???? 0 说明接收结束
				end
			end else begin
				rsps_reg <= 8'hFF;
			end
		end
	end

	reg [39:0]cmd8_rsps_reg = 40'hFF_FF_FF_FF_FF;
	reg cmd8_rsps_read_ena = 1'b0; // 由状态机控制

	always @(negedge sdclk or posedge reset) begin
		if(reset) begin
			cmd8_rsps_reg <= 40'hFF_FF_FF_FF_FF;
		end else begin
			if(cmd8_rsps_read_ena) begin
				if(cmd8_rsps_reg[39]) begin
					cmd8_rsps_reg <= {cmd8_rsps_reg[38:0], dout};
				end else begin
					cmd8_rsps_reg <= cmd8_rsps_reg; // 首位�???? 0 说明接收结束
				end
			end else begin
				cmd8_rsps_reg <= 40'hFF_FF_FF_FF_FF;
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
	// assign st = current_state;

	always @(posedge sdclk or posedge reset) begin
		if(reset) begin
			current_state <= AWAIT;
		end else begin
			current_state <= next_state;
		end
	end

	always @(*) begin
		case(current_state)
			AWAIT: begin
				if(start && await_cnt[9]) begin
					next_state = CMD0_PRE;
				end else begin
					next_state = AWAIT;
				end
			end
			CMD0_PRE: begin
				next_state = CMD0_SEND;
			end
			CMD0_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = CMD0_RCV;
				end else begin
					next_state = CMD0_SEND;
				end
			end
			CMD0_RCV: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == CMD0_RSPS) begin
						next_state = CMD0_PAUSE;
					end else begin
						next_state = ERROR;
					end
				end else begin
					next_state = CMD0_RCV;
				end
			end
			CMD0_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = CMD8_PRE;
				end else begin
					next_state = CMD0_PAUSE;
				end
			end
			CMD8_PRE: begin
				next_state = CMD8_SEND;
			end
			CMD8_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = CMD8_RCV;
				end else begin
					next_state = CMD8_SEND;
				end
			end
			CMD8_RCV: begin
				if(cmd8_rsps_reg[39] == 1'b0) begin
					if(cmd8_rsps_reg[39:32] == CMD8_HEAD && cmd8_rsps_reg[7:0] == CMD8_TAIL) begin
						next_state = CMD8_PAUSE;
					end else begin
						next_state = ERROR;
					end
				end else begin
					next_state = CMD8_RCV;
				end
			end
			CMD8_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = CMD55_PRE;
				end else begin
					next_state = CMD8_PAUSE;
				end
			end
			CMD55_PRE: begin
				next_state = CMD55_SEND;
			end
			CMD55_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = CMD55_RCV;
				end else begin
					next_state = CMD55_SEND;
				end
			end
			CMD55_RCV: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == CMD55_WAIT_RSPS || rsps_reg == CMD55_OK_RSPS) begin
						next_state = CMD55_PAUSE;
					end else begin
						next_state = ERROR;
					end
				end else begin
					next_state = CMD55_RCV;
				end
			end
			CMD55_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = ACMD41_PRE;
				end else begin
					next_state = CMD55_PAUSE;
				end
			end
			ACMD41_PRE: begin
				next_state = ACMD41_SEND;
			end
			ACMD41_SEND: begin
				if(cmd_cnt >= 6'd49) begin
					next_state = ACMD41_RCV;
				end else begin
					next_state = ACMD41_SEND;
				end
			end
			ACMD41_RCV: begin
				if(rsps_reg[7] == 1'b0) begin
					if(rsps_reg == ACMD41_AGAIN_RSPS) begin
						next_state = ACMD41_AGAIN_PAUSE;
					end else if(rsps_reg == ACMD41_OK_RSPS) begin 
						next_state = ACMD41_SUCCESS_PAUSE;
					end else begin
						next_state = ERROR;
					end
				end else begin
					next_state = ACMD41_RCV;
				end
			end
			ACMD41_AGAIN_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = CMD55_PRE;
				end else begin
					next_state = ACMD41_AGAIN_PAUSE;
				end
			end
			ACMD41_SUCCESS_PAUSE: begin
				if(empty_clk_cnt[4]) begin
					next_state = SUCCESS;
				end else begin
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

	// reg [47:0]cmd_to_send = INIT_CMD; // 由状态机控制
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

	// output reg cs = 1'b1,
	// output reg init_ok = 1'b0,
	// output reg err = 1'b0
	always @(*) begin
		case(current_state)
//		    AWAIT: begin
//				cs = 1'b0;
//                init_ok = 1'b0;
//                err = 1'b0;		    
//		    end
			CMD0_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD0_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD0_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD8_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD8_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD8_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD55_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD55_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			CMD55_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			ACMD41_PRE: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			ACMD41_SEND: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			ACMD41_RCV: begin
				cs = 1'b0;
				init_ok = 1'b0;
				err = 1'b0;
			end
			ERROR: begin
				cs = 1'b1;
				init_ok = 1'b0;
				err = 1'b1;
			end
			SUCCESS: begin
				cs = 1'b1;
				init_ok = 1'b1;
				err = 1'b0;
			end
			default: begin
				cs = 1'b1;
				init_ok = 1'b0;
				err = 1'b0;
			end
		endcase
	end
endmodule