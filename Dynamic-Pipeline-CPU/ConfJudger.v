//冲突判断模块
module ConfJudger
(
    // id_branch,
    if_inst,
    id_is_LW,
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
    // input id_branch;
    input [31:0]if_inst;
    input id_is_LW;
    input id_rf_we;
    input [4:0]id_rf_waddr;
    input exe_is_LW;
    input exe_rf_we;
    input [4:0]exe_rf_waddr;
    input mem_is_LW;
    input mem_rf_we;
    input [4:0]mem_rf_waddr;
    output if_stop;

    //if阶段指令的各个部分
    wire [5:0]if_op;
	wire [4:0]if_rs;
	wire [4:0]if_rt;
	wire [4:0]if_rd;
	wire [4:0]if_shamt;
	wire [5:0]if_func;
	wire [15:0]if_imm16;
	wire [25:0]if_index;

    //译码模块（硬件层面把指令切片）
    InstructionDecoder IF_ID
    (
        .instruction(if_inst), 
        .op(if_op), 
        .rs(if_rs), 
        .rt(if_rt), 
        .rd(if_rd), 
        .shamt(if_shamt), 
        .func(if_func), 
        .imm16(if_imm16), 
        .index(if_index)
    );

    assign if_stop = (((id_is_LW && id_rf_we && id_rf_waddr != 5'b0)&&((if_rs==id_rf_waddr)||(if_rt==id_rf_waddr)))
                    ||((exe_is_LW && exe_rf_we && exe_rf_waddr != 5'b0)&&((if_rs==exe_rf_waddr)||(if_rt==exe_rf_waddr)))
                    ||((mem_is_LW && mem_rf_we && mem_rf_waddr != 5'b0)&&((if_rs==mem_rf_waddr)||(if_rt==mem_rf_waddr)))
                    );
                    // && (~id_branch); 
endmodule