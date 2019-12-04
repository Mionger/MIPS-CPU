module CPU
(
    clock,
    reset,
    instruction,
    read_data,
    PC,
    DMEM_address,
    write_data,
    DMEM_WRITE
);
    input clock;
    input reset;
    input [31:0]instruction;
    input [31:0]read_data;
    output [31:0]PC;
    output [31:0]DMEM_address;
    output [31:0]write_data;
    output DMEM_WRITE;

    //IF 部分
    wire [31:0]NPC;
    wire [31:0]id_pc;
    wire [1:0]if_pc_mux_sel;
    wire [31:0]next_pc;
    wire id_change_pc;

    assign NPC = PC + 32'd4;

    wire id_rf_we;
    wire [4:0]id_rf_waddr;
    wire exe_rf_we;
    wire [4:0]exe_rf_waddr;
    wire mem_rf_we;
    wire [4:0]mem_rf_waddr;
    wire if_stop;

    //冲突判断，写入地�?是否和读取地�?相同
    //停的具体实现方式：保持PC不变
    wire id_branch;
    wire is_LW;
    wire exe_is_LW;
    wire mem_is_LW;
    ConfJudger confjudger
    (
        // id_branch,
        instruction,
        is_LW,
        id_rf_we,
        id_rf_waddr,
        exe_is_LW,
        exe_rf_we,
        exe_rf_waddr,
        mem_is_LW,
        mem_rf_we,
        mem_rf_waddr,
        if_stop
    );

    IF_PC_MUX if_pc_mux
    (
        .Adder(NPC), //PC + 4
        .id_pc(id_pc),
        .now_pc(PC),
        .sel(if_pc_mux_sel),
        .out(next_pc)
    );
    
    ProgramCounterReg pc_reg
    (
        .clock(clock),
        .reset(reset),
        .enable(1'b1),
        .data_in(next_pc),
        .data_out(PC)
    );

    IF_ControlUnit if_controlunit
    (
        .id_change_pc(id_change_pc),
        .if_stop(if_stop),
        .if_pc_mux_sel(if_pc_mux_sel)
    );

    //向下�?级流水线传�?�的指令
    wire [31:0]pass_inst;
    //停止判断
    // assign pass_inst = (if_stop||id_branch)? 32'b0: instruction;
    assign pass_inst = if_stop? 32'b0: instruction;
    
    //PIPE REG IF ID
    wire [31:0]id_inst;
    wire [31:0]id_NPC;
    Pipe_iireg pipe_iireg
    (
        .clk(clock),
        .reset(reset),
        .we(1'b1),
        .inst(pass_inst),
        .NPC(NPC),
        .id_inst(id_inst),
        .id_NPC(id_NPC)
    );

    //ID 部分
    wire [5:0]op;
	wire [4:0]rs;
	wire [4:0]rt;
	wire [4:0]rd;
	wire [4:0]shamt;
	wire [5:0]func;
	wire [15:0]imm16;
	wire [25:0]index;
    //单纯从硬件角度实现切割指�?
    InstructionDecoder id
    (
        .instruction(id_inst), 
        .op(op), 
        .rs(rs), 
        .rt(rt), 
        .rd(rd), 
        .shamt(shamt), 
        .func(func), 
        .imm16(imm16), 
        .index(index)
    );

    wire wb_rf_we;
    wire [4:0]wb_rf_waddr;
    wire [31:0]wb_rf_wdata;
    wire [31:0]rs_value;
    wire [31:0]rt_value;
    RegFile regfile
    (
        .clock(clock), 
        .reset(reset), 
        .write_enable(wb_rf_we), 
        .raddr1(rs), 
        .raddr2(rt), 
        .waddr(wb_rf_waddr), 
        .wdata(wb_rf_wdata), 
        .rdata1(rs_value), 
        .rdata2(rt_value)
    );

    wire [31:0]ze5;
    wire [31:0]ze16;
    wire [31:0]se16;
    wire [31:0]se18;
    Extender extender
    (
        .imm16(imm16), 
        .shamt(shamt), 
        .ZeroExt5_out(ze5),
        .ZeroExt16_out(ze16),
        .SignExt16_out(se16),
        .SignExt18_out(se18)
    );

    wire [31:0]JointerJ;
    Concatenater concatenater
    (
        .pc(NPC[31:28]),
        .index(index),
        .out_j(JointerJ)
    );

    

    wire [1:0]id_rf_waddr_sel;
    ID_WB_RF_WAddr_MUX id_wb_rf_waddr
    (
        .rt(rt),
        .rd(rd),
        .reg31(5'd31),
        .id_rf_waddr_sel(id_rf_waddr_sel),
        .out(id_rf_waddr)
    );

    wire [31:0]exe_NPC;
    wire [31:0]lo;
    wire [31:0]alu_result;
    wire exe_is_JAL;
    wire exe_is_MUL;
    wire [31:0]mem_NPC;
    wire [31:0]mem_MDU_out;
    wire [31:0]mem_Z;
    wire mem_is_JAL;
    wire mem_is_MUL;
    wire [31:0]rs_mux_out;
    wire [31:0]rt_mux_out;
    wire LW_conf;
    ID_RS_MUX id_rs_mux
    (
        .rs(rs),
        .rs_value(rs_value),
        .rt(rt),
        .rt_value(rt_value),
        .exe_NPC(exe_NPC),
        .exe_MDU_out(lo),
        .exe_Z(alu_result),
        .exe_rf_waddr(exe_rf_waddr),
        .exe_rf_we(exe_rf_we),
        .exe_is_JAL(exe_is_JAL),
        .exe_is_LW(exe_is_LW),
        .exe_is_MUL(exe_is_MUL),
        .mem_NPC(mem_NPC),
        .mem_MDU_out(mem_MDU_out),
        .mem_Z(mem_Z),
        .mem_rf_waddr(mem_rf_waddr),
        .mem_rf_we(mem_rf_we),
        .mem_is_JAL(mem_is_JAL),
        .mem_is_LW(mem_is_LW),
        .mem_is_MUL(mem_is_MUL),
        .rs_out(rs_mux_out),
        .rt_out(rt_mux_out),
        .LW_conf(LW_conf)
    );


    wire [1:0]id_pc_mux_sel;
    ID_PC_MUX id_pc_mux
    (
        .Jointer(JointerJ), // ||J
        .rs_value(rs_value),
        .Adder(PC + se18), // PC + SignExt18
        .sel(id_pc_mux_sel),
        .out(id_pc)
    );

    wire id_amux_sel;
    wire [1:0]id_bmux_sel;
    wire [3:0]aluc;
    // wire [1:0]id_rf_data_sel;
    wire id_dmem_we;
    wire [3:0]id_branch_ena;
    wire is_JAL;
    // wire is_LW;
    wire is_MUL;
    ID_ControlUnit id_controlunit
    (
        .op(op),
        .rs(rs),
        .rt(rt),
        .func(func),
        .rs_value(rs_mux_out),
        .rt_value(rt_mux_out),
        .id_change_pc(id_change_pc), 
        .id_pc_mux_sel(id_pc_mux_sel), 
        .id_amux_sel(id_amux_sel), 
        .id_bmux_sel(id_bmux_sel), 
        .aluc(aluc), 
        .id_rf_we(id_rf_we), 
        .id_rf_waddr_sel(id_rf_waddr_sel), 
        // .id_rf_data_sel(id_rf_data_sel), 
        .id_dmem_we(id_dmem_we), 
        .id_branch_ena(id_branch_ena),
        .is_JAL(is_JAL),
        .is_LW(is_LW),
        .is_MUL(is_MUL)
    );

    //跳转�?测模�?
    BranchJudger branchjudger
    (
        .rs_data(rs_mux_out),
        .rt_data(rt_mux_out),
        .branch_ena(id_branch_ena),
        .id_branch(id_branch)
    );
    
    //PIPE REG ID EXE
    wire [31:0]exe_rs_value;
    wire [31:0]exe_ze5;
    wire [31:0]exe_se16;
    wire [31:0]exe_ze16;
    wire [31:0]exe_rt_value;
    wire exe_amux_sel;
    wire [1:0]exe_bmux_sel;
    wire [3:0]exe_aluc;
    // wire [1:0]exe_rf_data_sel;
    wire [31:0]exe_dmem_wdata;
    wire exe_dmem_we;
    wire real_id_dmem_we;
    assign real_id_dmem_we = id_dmem_we && (~LW_conf);
    Pipe_iereg pipe_iereg
    (
        .clk(clock),
        .reset(reset),
        .we(1'b1),
        .id_rs_value(rs_mux_out),
        .id_ze5(ze5),
        .id_se16(se16),
        .id_ze16(ze16),
        .id_rt_value(rt_mux_out),
        .id_amux_sel(id_amux_sel),
        .id_bmux_sel(id_bmux_sel),
        .id_aluc(aluc),
        .id_rf_we(id_rf_we),
        .id_rf_waddr(id_rf_waddr),
        // .id_rf_data_sel(id_rf_data_sel),
        .id_dmem_wdata(rt_mux_out),
        .id_dmem_we(real_id_dmem_we),
        .id_NPC(id_NPC),
        .id_is_JAL(is_JAL),
        .id_is_LW(is_LW),
        .id_is_MUL(is_MUL),
        .exe_rs_value(exe_rs_value),
        .exe_ze5(exe_ze5),
        .exe_se16(exe_se16),
        .exe_ze16(exe_ze16),
        .exe_rt_value(exe_rt_value),
        .exe_amux_sel(exe_amux_sel),
        .exe_bmux_sel(exe_bmux_sel),
        .exe_aluc(exe_aluc),
        .exe_rf_we(exe_rf_we),
        .exe_rf_waddr(exe_rf_waddr),
        // .exe_rf_data_sel(exe_rf_data_sel),
        .exe_dmem_wdata(exe_dmem_wdata),
        .exe_dmem_we(exe_dmem_we),
        .exe_NPC(exe_NPC),
        .exe_is_JAL(exe_is_JAL),
        .exe_is_LW(exe_is_LW),
        .exe_is_MUL(exe_is_MUL)
    );

    wire [31:0]a;  
    EXE_AMUX exe_amux
    (
        .rs_value(exe_rs_value),
        .ze5(exe_ze5),
        .sel(exe_amux_sel),
        .A(a)
    );

    wire [31:0]b;
    EXE_BMUX exe_bmux
    (
        .se16(exe_se16),
        .ze16(exe_ze16),
        .rt_value(exe_rt_value),
        .sel(exe_bmux_sel),
        .B(b)
    );

    ALU alu
    (
        .a(a), 
        .b(b), 
        .aluc(exe_aluc), 
        .result(alu_result), 
        .zero(), 
        .carry(), 
        .negative(), 
        .overflow()
    );

    wire [63:0]MDU_out;
    wire [31:0]hi;
    assign MDU_out = a * b;
    assign hi = MDU_out[63:32];
    assign lo = MDU_out[31:0];

    //PIPE REG EXE MEM
    
    // wire [1:0]mem_rf_data_sel;
    wire [31:0]mem_dmem_wdata;
    wire mem_dmem_we;
    Pipe_emreg pipe_emreg
    (
        .clk(clock),
        .reset(reset),
        .exe_rf_we(exe_rf_we),
        .exe_Z(alu_result),
        .exe_rf_waddr(exe_rf_waddr),
        // .exe_rf_data_sel(exe_rf_data_sel),
        .exe_dmem_wdata(exe_dmem_wdata), // MEM 级写入内�?
        .exe_dmem_we(exe_dmem_we), // MEM 级读写指�?
        .exe_NPC(exe_NPC),
        .exe_MDU_out(lo),
        .exe_is_JAL(exe_is_JAL),
        .exe_is_LW(exe_is_LW),
        .exe_is_MUL(exe_is_MUL),
        .mem_rf_we(mem_rf_we),
        .mem_Z(mem_Z),
        .mem_rf_waddr(mem_rf_waddr),
        // .mem_rf_data_sel(mem_rf_data_sel),
        .mem_dmem_wdata(mem_dmem_wdata),
        .mem_dmem_we(mem_dmem_we),
        .mem_NPC(mem_NPC),
        .mem_MDU_out(mem_MDU_out),
        .mem_is_JAL(mem_is_JAL),
        .mem_is_LW(mem_is_LW),
        .mem_is_MUL(mem_is_MUL)
    );

    assign DMEM_address = mem_Z;
    assign write_data = mem_dmem_wdata;
    assign DMEM_WRITE = mem_dmem_we;

    //PIPE REG MEM WB
    
    wire [31:0]wb_Saver;
    // wire [1:0]wb_rf_data_sel;
    wire [31:0]wb_NPC;
    wire [31:0]wb_MDU_out;
    wire [31:0]wb_Z;
    wire wb_is_JAL;
    wire wb_is_LW;
    wire wb_is_MUL;
    Pipe_mwreg pipe_mwreg
    (
        .clk(clock),
        .reset(reset),
        .mem_rf_we(mem_rf_we),
        .mem_Z(mem_Z),
        .mem_dmem_out(read_data),
        .mem_rf_waddr(mem_rf_waddr),
        // .mem_rf_data_sel(mem_rf_data_sel),
        .mem_NPC(mem_NPC),
        .mem_MDU_out(mem_MDU_out),
        .mem_is_JAL(mem_is_JAL),
        .mem_is_LW(mem_is_LW),
        .mem_is_MUL(mem_is_MUL),
        .wb_rf_we(wb_rf_we),
        .wb_Z(wb_Z),
        .wb_Saver(wb_Saver),
        .wb_rf_waddr(wb_rf_waddr),
        // .wb_rf_data_sel(wb_rf_data_sel),
        .wb_NPC(wb_NPC),
        .wb_MDU_out(wb_MDU_out),
        .wb_is_JAL(wb_is_JAL),
        .wb_is_LW(wb_is_LW),
        .wb_is_MUL(wb_is_MUL)
    );

    WB_DataMUX wb_datamux
    (
        .Z(wb_Z),
        .Saver(wb_Saver),
        .NPC(wb_NPC),
        .MDU_out(wb_MDU_out),
        .is_JAL(wb_is_JAL),
        .is_LW(wb_is_LW),
        .is_MUL(wb_is_MUL),
        .out(wb_rf_wdata)
    );
endmodule