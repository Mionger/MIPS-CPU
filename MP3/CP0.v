`timescale 1ns / 1ps
module CP0
(
    CLK,
    RST,
    MFC0,
    MTC0,
    PC,
    RDC,
    DATA_IN,
    EXCEPTION,
    ERET,
    CAUSE,
    INTR,
    DATA_OUT,
    STATUS,
    TIMER_INT,
    EXC_ADDR
);

    input CLK;
    input RST;
    input MFC0;
    input MTC0;
    input [31:0]PC;
    input [4:0]RDC;
    input [31:0]DATA_IN;
    input EXCEPTION;
    input ERET;
    input [4:0]CAUSE;
    input INTR;

    output [31:0]DATA_OUT;
    output [31:0]STATUS;
    output TIMER_INT;
    output [31:0]EXC_ADDR;

	reg [31:0]DATA_OUT;

    reg [31:0]memory[31:0];
    reg exception_valid = 1'b0;//默认接受中断
	always @(*) begin
		// 接受中断 同时有中断信号
		if(EXCEPTION & memory[12][0]) begin
			case(CAUSE[4:0])
				4'b01000: begin //systcall
					if(memory[12][1]) begin
						exception_valid = 1'b1;
					end else begin
						exception_valid = 1'b0;
					end
				end
				4'b01001: begin //break
					if(memory[12][2]) begin
						exception_valid = 1'b1;
					end else begin
						exception_valid = 1'b0;
					end
				end
				4'b01101: begin //teq
					if(memory[12][3]) begin
						exception_valid = 1'b1;
					end else begin
						exception_valid = 1'b0;
					end
				end
				// 待扩展
				default: begin
					exception_valid = 1'b0;
				end
			endcase
		end else begin
			exception_valid = 1'b0;
		end
	end 

	reg in_exception = 1'b0;
	always @(negedge CLK or posedge RST) begin
		if(RST) begin
			memory[12] <= 32'h0000000f;	// 默认状态三种中断指令全开
			memory[13] <= 32'b0;
			memory[14] <= 32'b0;
			in_exception <= 1'b0;
		end else begin
			// 寄存器存数据
			if(MTC0) begin
				memory[RDC] <= DATA_IN;
			end else begin
				// 中断开始
				if(exception_valid & (~in_exception)) begin
                    // 中断现场保存操作完全通过汇编代码完成
					// memory[12] <= {memory[12][26:0], 5'b0};
					memory[13] <= {25'b0 ,CAUSE, 2'b0};
					memory[14] <= PC - 32'h4;
					in_exception <= 1'b1;
				// 中断结束
				end else if(ERET & in_exception) begin
                    // 中断现场恢复操作完全通过汇编代码完成
					// memory[12] <= {5'b0, memory[12][31:5]};
					in_exception <= 1'b0;
				end
			end
		end
	end

	// 寄存器读取
	always @(*) begin
		if(MFC0) begin
			DATA_OUT = memory[RDC];
		end else begin
			DATA_OUT = 32'bx;
		end
	end

	assign STATUS = memory[12];
	assign EXC_ADDR = memory[14];
    
endmodule
