`timescale 1ns / 1ps
module ControlUnit
(
    CLK,
    RST,
    OP,
    RSC,
    FUNC,
    R,
	RS,
    MDU_BUSY,
    CP0_STATUS,
	ALU_ZF,
    M0,
    M1,
    M2,
    M3,
    M4,
    M5,
    M6,
    M7,
    M8,
    M9,
    M10,
    M11,
    M12,
    M13,
    M14,
    M15,
    M16,
    PC_ENA,
    IR_ENA,
    R_ENA,
    RF_W,
    SAVE_ENA,
    ALUC,
    HI_ENA,
    LO_ENA,
    MDU_START,
    MDUC,
    DMEM_WE,
    CP0_CAUSE,
    CP0_EXCEPTION,
    CP0_ERET,
    CP0_MFC0,
    CP0_MTC0,
	CURRENT_STATE,
	NEXT_STATE
);
    input CLK;
    input RST;
    input [5:0]OP;
    input [4:0]RSC;
    input [5:0]FUNC;
    input [31:0]R;
    input [31:0]RS;
    input MDU_BUSY;
    input [31:0]CP0_STATUS;
	input ALU_ZF;
    
    output [1:0]M0;
    output [1:0]M1;
    output [1:0]M2;
    output [1:0]M3;
    output [1:0]M4;
    output [1:0]M5;
    output [1:0]M6;
    output [1:0]M7;
    output [1:0]M8;
    output [1:0]M9;
    output [1:0]M10;
    output [1:0]M11;
    output [1:0]M12;
    output [1:0]M13;
    output [1:0]M14;
    output [1:0]M15;
    output [1:0]M16;
    output PC_ENA;
    output IR_ENA;
    output R_ENA;
    output RF_W;
    output SAVE_ENA;
    output [3:0]ALUC;
    output HI_ENA;
    output LO_ENA;
    output MDU_START;
    output [1:0]MDUC;
    output DMEM_WE;
    output [4:0]CP0_CAUSE;
    output CP0_EXCEPTION;
    output CP0_ERET;
    output CP0_MFC0;
    output CP0_MTC0;
	output [3:0]CURRENT_STATE;
	output [3:0]NEXT_STATE;

    reg [1:0]M0;
    reg [1:0]M1;
    reg [1:0]M2;
    reg [1:0]M3;
    reg [1:0]M4;
    reg [1:0]M5;
    reg [1:0]M6;
    reg [1:0]M7;
    reg [1:0]M8;
    reg [1:0]M9;
    reg [1:0]M10;
    reg [1:0]M11;
    reg [1:0]M12;
    reg [1:0]M13;
    reg [1:0]M14;
    reg [1:0]M15;
    reg [1:0]M16;
    reg PC_ENA;
    reg IR_ENA;
    reg R_ENA;
    reg RF_W;
    reg SAVE_ENA;
    reg [3:0]ALUC;
    reg HI_ENA;
    reg LO_ENA;
    reg MDU_START;
    reg [1:0]MDUC;
    reg DMEM_WE;
    reg [4:0]CP0_CAUSE;

    // 译码部分
    wire ADD     = (OP == 6'b000000 & FUNC == 6'b100000);
    wire ADDU    = (OP == 6'b000000 & FUNC == 6'b100001);
    wire SUB     = (OP == 6'b000000 & FUNC == 6'b100010);
    wire SUBU    = (OP == 6'b000000 & FUNC == 6'b100011);
    wire AND     = (OP == 6'b000000 & FUNC == 6'b100100);
    wire OR      = (OP == 6'b000000 & FUNC == 6'b100101);
    wire XOR     = (OP == 6'b000000 & FUNC == 6'b100110);
    wire NOR     = (OP == 6'b000000 & FUNC == 6'b100111);
    wire SLT     = (OP == 6'b000000 & FUNC == 6'b101010);
    wire SLTU    = (OP == 6'b000000 & FUNC == 6'b101011);
    wire SLL     = (OP == 6'b000000 & FUNC == 6'b000000);
    wire SRL     = (OP == 6'b000000 & FUNC == 6'b000010);
    wire SRA     = (OP == 6'b000000 & FUNC == 6'b000011);
    wire SLLV    = (OP == 6'b000000 & FUNC == 6'b000100);
    wire SRLV    = (OP == 6'b000000 & FUNC == 6'b000110);
    wire SRAV    = (OP == 6'b000000 & FUNC == 6'b000111);
    wire JR      = (OP == 6'b000000 & FUNC == 6'b001000);
    wire ADDI    = (OP == 6'b001000);
    wire ADDIU   = (OP == 6'b001001);
    wire ANDI    = (OP == 6'b001100);
    wire ORI     = (OP == 6'b001101);
    wire XORI    = (OP == 6'b001110);
    wire LUI     = (OP == 6'b001111);
    wire LW      = (OP == 6'b100011);
    wire SW      = (OP == 6'b101011);
    wire BEQ     = (OP == 6'b000100);
    wire BNE     = (OP == 6'b000101);
    wire SLTI    = (OP == 6'b001010);
    wire SLTIU   = (OP == 6'b001011);
    wire J       = (OP == 6'b000010);
    wire JAL     = (OP == 6'b000011);
    wire DIV     = (OP == 6'b000000 & FUNC == 6'b011010);
    wire DIVU    = (OP == 6'b000000 & FUNC == 6'b011011);
    wire MULT    = (OP == 6'b000000 & FUNC == 6'b011000);
	wire MUL     = (OP == 6'b011100 & FUNC == 6'b000010);
    wire MULTU   = (OP == 6'b000000 & FUNC == 6'b011001);
    wire BGEZ    = (OP == 6'b000001);
    wire JALR    = (OP == 6'b000000 & FUNC == 6'b001001);
    wire LBU     = (OP == 6'b100100);
    wire LHU     = (OP == 6'b100101);
    wire LB      = (OP == 6'b100000);
    wire LH      = (OP == 6'b100001);
    wire SB      = (OP == 6'b101000);
    wire SH      = (OP == 6'b101001);
    wire BREAK   = (OP == 6'b000000 & FUNC == 6'b001101);
    wire SYSCALL = (OP == 6'b000000 & FUNC == 6'b001100);
    wire ERET    = (OP == 6'b010000 & RSC  == 5'b10000);
    wire MFHI    = (OP == 6'b000000 & FUNC == 6'b010000);
    wire MFLO    = (OP == 6'b000000 & FUNC == 6'b010010);
    wire MTHI    = (OP == 6'b000000 & FUNC == 6'b010001);
    wire MTLO    = (OP == 6'b000000 & FUNC == 6'b010011);
    wire MFC0    = (OP == 6'b010000 & RSC  == 5'b00000);
    wire MTC0    = (OP == 6'b010000 & RSC  == 5'b00100);
    wire CLZ     = (OP == 6'b011100 & FUNC == 6'b100000);
    wire TEQ     = (OP == 6'b000000 & FUNC == 6'b110100);

    reg step2;
    reg step3;
    reg step4;
    always@(*) begin
        if(JR|J|MFHI|MFLO|MTHI|MTLO|MTC0|CLZ) begin
            step2 = 1;
            step3 = 0;
            step4 = 0;
        end
        else if(LW|BEQ|BNE|DIV|DIVU|MULT|MUL|MULTU|LBU|LHU|LB|LH|SB|SH|BREAK|SYSCALL|TEQ|BGEZ) begin
            step2 = 0;
            step3 = 0;
            step4 = 1;
        end  
        else begin
            step2 = 0;
            step3 = 1;
            step4 = 0;
        end
    end

    // 步骤状�?�机
    parameter q1 = 4'b0001;
    parameter q2 = 4'b0010;
    parameter q3 = 4'b0100;
    parameter q4 = 4'b1000;
    reg [3:0]current_state = q1;
    reg [3:0]next_state;
	// wire [3:0]next_state_;
	assign NEXT_STATE = next_state;
	assign CURRENT_STATE = current_state;
    wire t1 = current_state[0];
	wire t2 = current_state[1];
	wire t3 = current_state[2];
	wire t4 = current_state[3];

	always @(posedge CLK  or posedge RST) begin
        if(RST) begin
            current_state <= q1;
			// next_state <= q1;
        end
        else begin
            current_state <= next_state;
        end
    end

    // always @(negedge CLK) begin
	always @(*) begin
		case(current_state)
			q1: begin
				next_state <= q2;
			end
			q2: begin
				if(BEQ) begin
					if(ALU_ZF) begin
						next_state <= q3;
					end 
					else begin
						next_state <= q1;
					end
				end 
				else if(BNE) begin
					if(ALU_ZF) begin
						next_state <= q1;
					end 
					else begin
						next_state <= q3;
					end
				end 
				else if(BGEZ) begin
					if(RS[31])begin
						next_state <= q1;
					end
					else begin
						next_state <= q3;
					end
				end
				else if(BREAK) begin
					if(CP0_STATUS[0] & CP0_STATUS[2]) begin
						next_state <= q3;
					end 
					else begin
						next_state <= q1;
					end
				end 
				else if(SYSCALL) begin
					if(CP0_STATUS[0] & CP0_STATUS[1]) begin
						next_state <= q3;
					end 
					else begin
						next_state <= q1;
					end
				end 
				else if(TEQ) begin
					if(CP0_STATUS[0] & CP0_STATUS[3] & ALU_ZF) begin
						next_state <= q3;
					end 
					else begin
						next_state <= q1;
					end
				end 
				else begin
					if(step2) begin
						next_state <= q1;
					end else begin
						next_state <= q3;
					end
				end
			end
			q3: begin
				if(MULT | MULTU | MUL | DIV | DIVU) begin
					if(MDU_BUSY) begin
						next_state <= q3;
					end 
					else begin
						next_state <= q4;
					end
				end 
				else begin
					if(step4) begin
						next_state <= q4;
					end 
					else begin
						next_state <= q1;
					end
				end
			end
			q4: begin
				next_state <= q1;
			end
			// default: begin
			// 	next_state <= q1;
			// end
		endcase
	end

	

	//PC
	always @(*) begin
		if((BEQ & t4)|(BGEZ & t4)|(BNE & t4)) begin
			M0 = 2'b00;
            M1 = 2'b00;
            M2 = 2'bxx;
			PC_ENA = 1;
		end 
        else if(JR & t2) begin
			M0 = 2'b01;
            M1 = 2'bxx;
            M2 = 2'b01;
			PC_ENA = 1;
        end 
        else if((J & t2)|(JAL & t3)) begin
			M0 = 2'b00;
            M1 = 2'b10;
            M2 = 2'bxx;
			PC_ENA = 1;
		end 
        else if(JALR & t3) begin
            M0 = 2'b01;
            M1 = 2'bxx;
            M2 = 2'b01;
            PC_ENA = 1;
		end 
        else if((BREAK | SYSCALL | TEQ) & t4) begin
			M0 = 2'b01;
            M1 = 2'bxx;
            M2 = 2'b00;
			PC_ENA = 1;
		end 
        else if(ERET & t3) begin
			M0 = 2'b00;
            M1 = 2'b11;
            M2 = 2'bxx;
			PC_ENA = 1;
		end 
        else if(t1) begin
            M0 = 2'b00;
            M1 = 2'b01;
            M2 = 2'bxx;
			PC_ENA = 1;
		end 
        else begin
			M0 = 2'bxx;
            M1 = 2'bxx;
            M2 = 2'bxx;
			PC_ENA = 0;
		end
	end

	//IR
	always @(*) begin
		if(t1) begin
			IR_ENA = 1;
		end 
        else begin
			IR_ENA = 0;
		end
	end

	// DMEM
	always @(*) begin
		if(SB & t4) begin
			DMEM_WE = 1;
			M11 = 2'b01;
		end 
        else if(SH & t4) begin
			DMEM_WE = 1;
			M11 = 2'b00;
		end 
        else if(SW & t3) begin
			DMEM_WE = 1;
			M11 = 2'b10;
		end 
        else begin
			DMEM_WE = 0;
			M11 = 2'bxx;
		end
	end

	//RegFile
	always @(*) begin
		case(current_state)
			q2: begin
				if(JAL) begin
					RF_W = 1;
                    M3 = 2'b11;
                    M7 = 2'bxx;
                    M8 = 2'b10;
                    M9 = 2'bxx;
                    M10 = 2'b01;
				end 
                else if(JALR) begin
					RF_W = 1;
					M3 = 2'b00;
                    M7 = 2'bxx;
                    M8 = 2'b10;
                    M9 = 2'bxx;
                    M10 = 2'b01;
				end 
                else if(MFHI) begin
					RF_W = 1;
					M3 = 2'b00;
                    M7 = 2'bxx;
                    M8 = 2'bxx;
                    M9 = 2'b00;
                    M10 = 2'b10;
				end 
                else if(MFLO) begin
					RF_W = 1;
					M3 = 2'b00;
                    M7 = 2'bxx;
                    M8 = 2'bxx;
                    M9 = 2'b01;
                    M10 = 2'b10;
				end 
				else if(CLZ) begin //如果出错，改为第四个周期
					RF_W = 1;
					M3 = 2'b00;
                    M7 = 2'bxx;
                    M8 = 2'b11;
                    M9 = 2'bxx;
                    M10 = 2'b01;
				end
                else begin
					RF_W = 0;
					M3 = 2'bxx;
                    M7 = 2'bxx;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'bxx;
				end
			end
			q3: begin
                if(ADD|ADDU|AND|NOR|OR|SLL|SLLV|SLT|SLTU|SRA|SRAV|SRL|SRLV|SUB|SUBU|XOR) begin
					RF_W = 1;
					M3 = 2'b00;
                    M7 = 2'b00;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'b00;
				end
				else if(ADDI|ADDIU|ANDI|LUI|ORI|SLTI|SLTIU|XORI) begin
					RF_W = 1;
					M3 = 2'b01;
                    M7 = 2'b00;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'b00;
				end
				else if(MFC0) begin
					RF_W = 1;
					M3 = 2'b01;
                    M7 = 2'b01;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'b00;
				end 
                else begin
					RF_W = 0;
					M3 = 2'bxx;
                    M7 = 2'bxx;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'bxx;
				end
			end
			q4: begin
				if(LB) begin
					RF_W = 1;
					M3 = 2'b01;
                    M7 = 2'bxx;
                    M8 = 2'b01;
                    M9 = 2'bxx;
                    M10 = 2'b01;
				end 
				else if(LBU) begin
					RF_W = 1;
					M3 = 2'b01;
                    M7 = 2'bxx;
                    M8 = 2'b00;
                    M9 = 2'bxx;
                    M10 = 2'b01;
				end 
				else if(LH) begin
					RF_W = 1;
					M3 = 2'b01;
                    M7 = 2'b11;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'b00;
				end 
				else if(LHU) begin
					RF_W = 1;
					M3 = 2'b01;
                    M7 = 2'b10;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'b00;
				end 
				else if(LW) begin
					RF_W = 1;
					M3 = 2'b01;
                    M7 = 2'b01;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'b00;
				end 
				else if(MUL) begin
					RF_W = 1;
					M3 = 2'b00;
                    M7 = 2'bxx;
                    M8 = 2'bxx;
                    M9 = 2'b10;
                    M10 = 2'b10;
				end
				else begin
					RF_W = 0;
					M3 = 2'bxx;
                    M7 = 2'bxx;
                    M8 = 2'bxx;
                    M9 = 2'bxx;
                    M10 = 2'bxx;
				end
			end
			default: begin
				RF_W = 0;
				M3 = 2'bxx;
                M7 = 2'bxx;
                M8 = 2'bxx;
                M9 = 2'bxx;
                M10 = 2'bxx;
			end
		endcase
	end

	// ALU相关信号
	// A端口数据选择
	always @(*) begin
		if((SLL & t2)|(SRA & t2)|(SRL & t2)) begin
			M4 = 2'b01;
		end 
		else if(t1 |(BEQ & t3)|(BGEZ & t3)|(BNE & t3)) begin
			M4 = 2'b10;
		end 
		else begin
			M4 = 2'b00;
		end
	end
	// B端口数据选择
	always @(*) begin
		if((ADDI & t2)|(ADDIU & t2)|(LB & t2)|(LBU & t2)|(LH & t2)|(LHU & t2)|(LUI & t2)|(LW & t2)|(SB & t2)|(SH & t2)|(SLTI & t2)|(SW & t2))begin
			M5 = 2'b01;
			M6 = 2'b01;
			R_ENA = 1;
		end 
		else if((ANDI & t2)|(ORI & t2)|(SLTIU & t2)|(XORI & t2)) begin
			M5 = 2'b01;
			M6 = 2'b00;
			R_ENA = 1;
		end 
		else if((BEQ & t3)|(BGEZ & t3)|(BNE & t3)) begin
			M5 = 2'b01;
			M6 = 2'b10;
			R_ENA = 1;
		end 
		else if(t1) begin
			M5 = 2'b10;
			M6 = 2'bxx;
			R_ENA = 1;
		end 
		else begin
			if(t2) begin
				M5 = 2'b00;
				M6 = 2'bxx;
				R_ENA = 1;
			end else begin
				M5 = 2'bxx;
				M6 = 2'bxx;
				R_ENA = 0;
			end
		end
	end
	// ALUC生成
	always @(*) begin
		case(current_state)
			q1: begin
				ALUC = 4'b0010;
			end
			q2: begin
				if(ADDIU|ADDU) begin
					ALUC = 4'b0000;
				end
				else if(ADDI|LB|LBU|LH|LHU|LW|SB|SH|SW|ADD) begin
					ALUC = 4'b0010;
				end  
				else if(SUBU) begin
					ALUC = 4'b0001;
				end 
				else if(BEQ|BNE|SUB|TEQ) begin
					ALUC = 4'b0011;
				end 
				else if(ANDI|AND) begin
					ALUC = 4'b0100;
				end 
				else if(ORI|OR) begin
					ALUC = 4'b0101;
				end
				else if(XORI|XOR) begin
					ALUC = 4'b0110;
				end
				else if(NOR) begin
					ALUC = 4'b0111;
				end
				else if(LUI) begin
					ALUC = 4'b1000;
				end 
				else if(SLTI|SLT) begin
					ALUC = 4'b1011;
				end 
				else if(SLTIU|SLTU) begin
					ALUC = 4'b1010;
				end 
				else if(SLL|SLLV) begin
					ALUC = 4'b1111;
				end 
				else if(SRA|SRAV) begin
					ALUC = 4'b1100;
				end 
				else if(SRL|SRLV) begin
					ALUC = 4'b1101;
				end 
				else begin
					ALUC = 4'bxxxx;
				end
			end
			q3: begin
				if(BEQ|BNE|BGEZ) begin
					ALUC = 4'b0010;
				end 
				else begin
					ALUC = 4'bxxxx;
				end
			end
			default: begin
				ALUC = 4'bxxxx;
			end
		endcase
	end

	// MDU
	// �?始信号发�?
	always @(*) begin
		if((DIV|DIVU|MULT|MULTU|MUL)&(t1|t2)) begin
			MDU_START = 1;
		end 
		else begin
			MDU_START = 0;
		end
	end
	// MDUC信号控制
	always @(*) begin
		if(DIV) begin
			MDUC = 2'b10;
		end 
		else if(DIVU) begin
			MDUC = 2'b11;
		end 
		else if(MULT | MUL) begin
			MDUC = 2'b00;
		end 
		else if(MULTU) begin
			MDUC = 2'b01;
		end 
		else begin
			MDUC = 2'bxx;
		end
	end

	// SAVE寄存�?
	always @(*) begin
		if(t3) begin
			if(LB|LBU|LH|LHU|LW) begin
				M14 = 2'b00;
				SAVE_ENA = 1;
			end 
			else begin
				M14 = 2'bxx;
				SAVE_ENA = 0;
			end
		end else if(t2) begin
			if(MFC0) begin
				M14 = 2'b01;
				SAVE_ENA = 1;
			end else begin
				M14 = 2'bxx;
				SAVE_ENA = 0;
			end
		end else begin
			M14 = 2'bxx;
			SAVE_ENA = 0;
		end
	end

	// S_Ext_16
	always @(*) begin
		if(t2) begin
			if(ADDI|ADDIU|LB|LBU|LH|LHU|LUI|LW|SB|SH|SLTI|SW) begin
				M16 = 2'b00;
			end else begin
				M16 = 2'bxx;
			end
		end else if(t4) begin
			if(LH) begin
				M16 = 2'b01;
			end else begin
				M16 = 2'bxx;
			end
		end else begin
			M16 = 2'bxx;
		end
	end

	// Ext_16
	always @(*) begin
		if(t2) begin
			if(ANDI|ORI|SLTIU|XORI) begin
				M15 = 2'b00;
			end else begin
				M15 = 2'bxx;
			end
		end else if(t4) begin
			if(LHU) begin
				M15 = 2'b01;
			end else begin
				M15 = 2'bxx;
			end
		end else begin
			M15 = 2'bxx;
		end
	end

	//HI LO
	always @(*) begin
		if((DIV|DIVU|MULT|MULTU)&t4) begin
			M12 = 2'b00;
			HI_ENA = 1;
		end 
		else if(MTHI & t2) begin
			M12 = 2'b01;
			HI_ENA = 1;
		end 
		else begin
			M12 = 2'bxx;
			HI_ENA = 0;
		end
	end

	always @(*) begin
		if((DIV|DIVU|MULT|MULTU)&t4) begin
			M13 = 2'b00;
			LO_ENA = 1;
		end 
		else if(MTLO & t2) begin
			M13 = 2'b01;
			LO_ENA = 1;
		end 
		else begin
			M13 = 2'bxx;
			LO_ENA = 0;
		end
	end

	//CP0
	assign CP0_MFC0 = (MFC0 & t2);
	assign CP0_MTC0 = (MTC0 & t2);
	assign CP0_EXCEPTION = ((BREAK | SYSCALL | TEQ)& t3);
	// assign CP0_EXCEPTION = (((BREAK|SYSCALL) & t3)|(TEQ & t4));
	assign CP0_ERET = (ERET & t2);
	always @(*) begin
		if(t3) begin
			if(BREAK) begin
				CP0_CAUSE = 5'b01001;
			end
			else if(SYSCALL) begin
				CP0_CAUSE = 5'b01000;
			end 
			else if(TEQ) begin
				CP0_CAUSE = 5'b01101;
			end
			else begin
				CP0_CAUSE = 5'b00000;
			end
		end
		else begin
			CP0_CAUSE = 5'bxxxxx;
		end
	end
	// always @(*) begin
	// 	if(t3) begin
	// 		if(BREAK) begin
	// 			CP0_CAUSE = 5'b01001;
	// 		end 
	// 		else if(SYSCALL) begin
	// 			CP0_CAUSE = 5'b01000;
	// 		end 
	// 		else begin
	// 			CP0_CAUSE = 5'bxxxxx;
	// 		end
	// 	end 
	// 	else if(t4) begin
	// 		if(TEQ) begin
	// 			CP0_CAUSE = 5'b01101;
	// 		end 
	// 		else begin
	// 			CP0_CAUSE = 5'b00000;
	// 		end
	// 	end 
	// 	else begin
	// 		CP0_CAUSE = 5'bxxxxx;
	// 	end
	// end
    
endmodule