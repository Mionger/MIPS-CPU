//IF ID 间的寄存器
module Pipe_iireg
(
    clk,
    reset,
    we,
    inst,
    NPC,
    id_inst,
    id_NPC
);
    input clk;
    input reset;
    input we;
    input [31:0]inst;
    input [31:0]NPC;
    output reg [31:0]id_inst = 32'b0;
    output reg [31:0]id_NPC = 32'b0;

    always @(posedge reset or posedge clk) begin
        if(reset) begin
            id_inst <= 32'b0;
            id_NPC <= 32'b0;
        end 
        else begin
            if(we) begin
                id_inst <= inst;
                id_NPC <= NPC;
            end 
            else begin
                id_inst <= id_inst;
                id_NPC <= id_NPC;
            end
        end
    end
endmodule

// ID EXE 间的寄存器
module Pipe_iereg
(
    clk,
    reset,
    we,
    id_rs_value,
    id_ze5,
    id_se16,
    id_ze16,
    id_rt_value,
    id_amux_sel,
    id_bmux_sel,
    id_aluc,
    id_rf_we,
    id_rf_waddr,
    // id_rf_data_sel,
    id_dmem_wdata,
    id_dmem_we,
    id_NPC,
    id_is_JAL,
    id_is_LW,
    id_is_MUL,
    exe_rs_value,
    exe_ze5,
    exe_se16,
    exe_ze16,
    exe_rt_value,
    exe_amux_sel,
    exe_bmux_sel,
    exe_aluc,
    exe_rf_we,
    exe_rf_waddr,
    // exe_rf_data_sel,
    exe_dmem_wdata,
    exe_dmem_we,
    exe_NPC,
    exe_is_JAL,
    exe_is_LW,
    exe_is_MUL
);
    input clk;
    input reset;
    input we;
    input [31:0]id_rs_value;
    input [31:0]id_ze5;
    input [31:0]id_se16;
    input [31:0]id_ze16;
    input [31:0]id_rt_value;
    input id_amux_sel;
    input [1:0]id_bmux_sel;
    input [3:0]id_aluc;
    input id_rf_we;
    input [4:0]id_rf_waddr;
    // input [1:0]id_rf_data_sel;
    input [31:0]id_dmem_wdata;
    input id_dmem_we;
    input [31:0]id_NPC;
    input id_is_JAL;
    input id_is_LW;
    input id_is_MUL;
    output reg [31:0]exe_rs_value = 32'b0;
    output reg [31:0]exe_ze5 = 32'b0;
    output reg [31:0]exe_se16 = 32'b0;
    output reg [31:0]exe_ze16 = 32'b0;
    output reg [31:0]exe_rt_value = 32'b0;
    output reg exe_amux_sel = 1'b0;
    output reg [1:0]exe_bmux_sel = 2'b0;
    output reg [3:0]exe_aluc = 4'b0;
    output reg exe_rf_we = 1'b0;
    output reg [4:0]exe_rf_waddr = 5'b0;
    // output reg [1:0]exe_rf_data_sel = 2'b0;
    output reg [31:0]exe_dmem_wdata = 32'b0;
    output reg exe_dmem_we = 1'b0;
    output reg [31:0]exe_NPC = 32'b0;
    output reg exe_is_JAL = 1'b0;
    output reg exe_is_LW = 1'b0;
    output reg exe_is_MUL = 1'b0;

    always @(posedge reset or posedge clk) begin
        if(reset) begin
            exe_rs_value <= 32'b0;
            exe_ze5 <= 32'b0;
            exe_se16 <= 32'b0;
            exe_ze16 <= 32'b0;
            exe_rt_value <= 32'b0;
            exe_amux_sel <= 1'b0;
            exe_bmux_sel <= 2'b0;
            exe_aluc <= 4'b0;
            exe_rf_we <= 'b0;
            exe_rf_waddr <= 5'b0;
            // exe_rf_data_sel <= 1'b0;
            exe_dmem_wdata <= 32'b0;
            exe_dmem_we <= 1'b0;
            exe_NPC <= 32'b0;
            exe_is_JAL <= 1'b0;
            exe_is_LW <= 1'b0;
            exe_is_MUL <= 1'b0;
        end 
        else begin
            if(we) begin 
                exe_rs_value <= id_rs_value;
                exe_ze5 <= id_ze5;
                exe_se16 <= id_se16;
                exe_ze16 <= id_ze16;
                exe_rt_value <= id_rt_value;
                exe_amux_sel <= id_amux_sel;
                exe_bmux_sel <= id_bmux_sel;
                exe_aluc <= id_aluc;
                exe_rf_we <= id_rf_we;
                exe_rf_waddr <= id_rf_waddr;
                // exe_rf_data_sel <= id_rf_data_sel;
                exe_dmem_wdata <= id_dmem_wdata;
                exe_dmem_we <= id_dmem_we;
                exe_NPC <= id_NPC;
                exe_is_JAL <= id_is_JAL;
                exe_is_LW <= id_is_LW;
                exe_is_MUL <= id_is_MUL;
            end 
            else begin
                exe_rs_value <= exe_rs_value;
                exe_ze5 <= exe_ze5;
                exe_se16 <= exe_se16;
                exe_ze16 <= exe_ze16;
                exe_rt_value <= exe_rt_value;
                exe_amux_sel <= exe_amux_sel;
                exe_bmux_sel <= exe_bmux_sel;
                exe_aluc <= exe_aluc;
                exe_rf_we <= exe_rf_we;
                exe_rf_waddr <= exe_rf_waddr;
                // exe_rf_data_sel <= exe_rf_data_sel;
                exe_dmem_wdata <= exe_dmem_wdata;
                exe_dmem_we <= exe_dmem_we;
                exe_NPC <= exe_NPC;
                exe_is_JAL <= exe_is_JAL;
                exe_is_LW <= exe_is_LW;
                exe_is_MUL <= exe_is_MUL;
            end
        end
    end
endmodule

// EXE MEM 间的寄存器
module Pipe_emreg
(
    clk,
    reset,
    exe_rf_we,
    exe_Z,
    exe_rf_waddr,
    // exe_rf_data_sel,
    exe_dmem_wdata, 
    exe_dmem_we, 
    exe_NPC,
    exe_MDU_out,
    exe_is_JAL,
    exe_is_LW,
    exe_is_MUL,
    mem_rf_we,
    mem_Z,
    mem_rf_waddr,
    // mem_rf_data_sel,
    mem_dmem_wdata,
    mem_dmem_we,
    mem_NPC,
    mem_MDU_out,
    mem_is_JAL,
    mem_is_LW,
    mem_is_MUL
);
    input clk;
    input reset;
    input exe_rf_we;
    input [31:0]exe_Z;
    input [4:0]exe_rf_waddr;
    // input [1:0]exe_rf_data_sel;
    input [31:0]exe_dmem_wdata; 
    input exe_dmem_we; 
    input [31:0]exe_NPC;
    input [31:0]exe_MDU_out;
    input exe_is_JAL;
    input exe_is_LW;
    input exe_is_MUL;
    output reg mem_rf_we = 1'b0;
    output reg [31:0]mem_Z = 32'b0;
    output reg [4:0]mem_rf_waddr = 5'b0;
    // output reg [1:0]mem_rf_data_sel = 2'b0;
    output reg [31:0]mem_dmem_wdata = 32'b0;
    output reg mem_dmem_we = 1'b0;
    output reg [31:0]mem_NPC = 32'b0;
    output reg [31:0]mem_MDU_out = 32'b0;
    output reg mem_is_JAL = 1'b0;
    output reg mem_is_LW = 1'b0;
    output reg mem_is_MUL = 1'b0;

    always @(posedge reset or posedge clk) begin
        if(reset) begin
            mem_rf_we <= 1'b0;
            mem_Z <= 32'b0;
            mem_rf_waddr <= 5'b0;
            // mem_rf_data_sel <= 1'b0;
            mem_dmem_wdata <= 32'b0;
            mem_dmem_we <= 1'b0;
            mem_NPC <= 32'b0;
            mem_MDU_out <= 32'b0;
            mem_is_JAL <= 1'b0;
            mem_is_LW <= 1'b0;
            mem_is_MUL <= 1'b0;
        end 
        else begin
            mem_rf_we <= exe_rf_we;
            mem_Z <= exe_Z;
            mem_rf_waddr <= exe_rf_waddr;
            // mem_rf_data_sel <= exe_rf_data_sel;
            mem_dmem_wdata <= exe_dmem_wdata;
            mem_dmem_we <= exe_dmem_we;
            mem_NPC <= exe_NPC;
            mem_MDU_out <= exe_MDU_out;
            mem_is_JAL <= exe_is_JAL;
            mem_is_LW <= exe_is_LW;
            mem_is_MUL <= exe_is_MUL;
        end
    end
endmodule

// MEM WB 间的寄存器
module Pipe_mwreg
(
    clk,
    reset,
    mem_rf_we,
    mem_Z,
    mem_dmem_out,
    mem_rf_waddr,
    // mem_rf_data_sel,
    mem_NPC,
    mem_MDU_out,
    mem_is_JAL,
    mem_is_LW,
    mem_is_MUL,
    wb_rf_we,
    wb_Z,
    wb_Saver,
    wb_rf_waddr,
    // wb_rf_data_sel,
    wb_NPC,
    wb_MDU_out,
    wb_is_JAL,
    wb_is_LW,
    wb_is_MUL
);
    input clk;
    input reset;
    input mem_rf_we;
    input [31:0]mem_Z;
    input [31:0]mem_dmem_out;
    input [4:0]mem_rf_waddr;
    // input [1:0]mem_rf_data_sel;
    input [31:0]mem_NPC;
    input [31:0]mem_MDU_out;
    input mem_is_JAL;
    input mem_is_LW;
    input mem_is_MUL;
    output reg wb_rf_we = 1'b0;
    output reg [31:0]wb_Z = 32'b0;
    output reg [31:0]wb_Saver = 32'b0;
    output reg [4:0]wb_rf_waddr = 5'b0;
    // output reg [1:0]wb_rf_data_sel = 2'b0;
    output reg [31:0]wb_NPC = 32'b0;
    output reg [31:0]wb_MDU_out = 32'b0;
    output reg wb_is_JAL = 1'b0;
    output reg wb_is_LW = 1'b0;
    output reg wb_is_MUL = 1'b0;

    always @(posedge reset or posedge clk) begin
        if(reset) begin
            wb_rf_we <= 1'b0;
            wb_Z <= 32'b0;
            wb_Saver <= 32'b0;
            wb_rf_waddr <= 5'b0;
            // wb_rf_data_sel <= 1'b0;
            wb_NPC <= 32'b0;
            wb_MDU_out <= 32'b0;
            wb_is_JAL <= 1'b0;
            wb_is_LW <= 1'b0;
            wb_is_MUL <= 1'b0;
        end 
        else begin
            wb_rf_we <= mem_rf_we;
            wb_Z <= mem_Z;
            wb_Saver <= mem_dmem_out;
            wb_rf_waddr <= mem_rf_waddr;
            // wb_rf_data_sel <= mem_rf_data_sel;
            wb_NPC <= mem_NPC;
            wb_MDU_out <= mem_MDU_out;
            wb_is_JAL <= mem_is_JAL;
            wb_is_LW <= mem_is_LW;
            wb_is_MUL <= mem_is_MUL;
        end
    end
endmodule