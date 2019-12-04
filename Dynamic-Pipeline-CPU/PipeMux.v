module IF_PC_MUX
(
    Adder, 
    id_pc,
    now_pc,
    sel,
    out
);
    input [31:0]Adder; 
    input [31:0]id_pc;
    input [31:0]now_pc;
    input [1:0]sel;
    output reg [31:0]out;
    /* 00 Adder
     * 01 id_pc
     * 1x now_pc
     */
    always @(*) begin
        if(sel[1]) begin
            out = now_pc;
        end 
        else begin
            if(sel[0]) begin
                out = id_pc;
            end 
            else begin
                out = Adder;
            end
        end
    end
endmodule

module ID_WB_RF_WAddr_MUX
(
    rt,
    rd,
    reg31,
    id_rf_waddr_sel,
    out
);
    input [4:0]rt;
    input [4:0]rd;
    input [4:0]reg31;
    input [1:0]id_rf_waddr_sel;
    output reg [4:0]out;
    /* 00 rt
     * 01 rd
     * 1x reg31
     */
    always @(*) begin
        if(id_rf_waddr_sel[1]) begin
            out = reg31;
        end 
        else begin
            if(id_rf_waddr_sel[0]) begin
                out = rd;
            end 
            else begin
                out = rt;
            end
        end
    end
endmodule

module ID_PC_MUX
(
    Jointer, 
    rs_value,
    Adder,
    sel,
    out
);
    input [31:0]Jointer;
    input [31:0]rs_value;
    input [31:0]Adder;
    input [1:0]sel;
    output reg [31:0]out;

    /* 00 Jointer
     * 01 rs_value
     * 1x Adder
     */
    always @(*) begin
        if(sel[1]) begin
            //1x
            out = Adder;
        end 
        else begin
            if(sel[0]) begin
                //01
                out = rs_value;
            end 
            else begin
                //00
                out = Jointer;
            end
        end
    end
endmodule

module EXE_AMUX
(
    rs_value,
    ze5,
    sel,
    A
);
    input [31:0]rs_value;
    input [31:0]ze5;
    input sel;
    output [31:0]A;

    /* 0 rs_value
     * 1 ze5
     */
    assign A = sel? ze5: rs_value;
endmodule

module EXE_BMUX
(
    se16,
    ze16,
    rt_value,
    sel,
    B
);
    input [31:0]se16;
    input [31:0]ze16;
    input [31:0]rt_value;
    input [1:0]sel;
    output reg [31:0]B;

    /* 00 se16
     * 01 ze16
     * 1x rt_value
     */
    always @(*) begin
        if(sel[1]) begin
            //1x
            B = rt_value;
        end 
        else begin
            if(sel[0]) begin
                //01
                B = ze16;
            end 
            else begin
                //00
                B = se16;
            end
        end 
    end
endmodule

module WB_DataMUX
(
    Z,
    Saver,
    NPC,
    MDU_out,
    is_JAL,
    is_LW,
    is_MUL,
    out
);
    input [31:0]Z;
    input [31:0]Saver;
    input [31:0]NPC;
    input [31:0]MDU_out;
    input is_JAL;
    input is_LW;
    input is_MUL;
    output reg [31:0]out;

    /* 00 Z
     * 01 Saver
     * 10 NPC
     * 11 MDU_out
     */
    always @(*) begin
        if (is_LW) begin
            out = Saver;
        end
        else if(is_JAL) begin
            out = NPC;
        end
        else if(is_MUL) begin
            out = MDU_out;
        end
        else begin
            out = Z;
        end
    end
endmodule

module ID_RS_MUX
(
    rs,
    rs_value,
    rt,
    rt_value,
    exe_NPC,
    exe_MDU_out,
    exe_Z,
    exe_rf_waddr,
    exe_rf_we,
    exe_is_JAL,
    exe_is_LW,
    exe_is_MUL,
    mem_NPC,
    mem_MDU_out,
    mem_Z,
    mem_rf_waddr,
    mem_rf_we,
    mem_is_JAL,
    mem_is_LW,
    mem_is_MUL,
    rs_out,
    rt_out,
    LW_conf
);
    input [4:0]rs;
    input [31:0]rs_value;
    input [4:0]rt;
    input [31:0]rt_value;
    input [31:0]exe_NPC;
    input [31:0]exe_MDU_out;
    input [31:0]exe_Z;
    input [4:0]exe_rf_waddr;
    input exe_rf_we;
    input exe_is_JAL;
    input exe_is_LW;
    input exe_is_MUL;
    input [31:0]mem_NPC;
    input [31:0]mem_MDU_out;
    input [31:0]mem_Z;
    input [4:0]mem_rf_waddr;
    input mem_rf_we;
    input mem_is_JAL;
    input mem_is_LW;
    input mem_is_MUL;
    output reg [31:0]rs_out = 32'b0;
    output reg [31:0]rt_out = 32'b0;
    output reg LW_conf = 1'b0;

    reg rs_LW_conf = 1'b0;
    reg rt_LW_conf = 1'b0;

    always @(*) begin
        if(rs_LW_conf || rt_LW_conf) begin
            LW_conf = 1'b1;
        end
        else begin
            LW_conf = 1'b0;
        end
    end

    always @(*) begin
        if(exe_rf_we && exe_rf_waddr == rs && rs != 5'b0) begin
            if(exe_is_JAL) begin
                rs_LW_conf = 1'b0;
                rs_out = exe_NPC;
            end
            else if(exe_is_MUL) begin
                rs_LW_conf = 1'b0;
                rs_out = exe_MDU_out;
            end
            else if(exe_is_LW) begin
                rs_LW_conf = 1'b1;
                rs_out = 32'b0;
            end
            else begin
                rs_LW_conf = 1'b0;
                rs_out = exe_Z;
            end
        end
        else begin
            if(mem_rf_we && mem_rf_waddr == rs && rs != 5'b0)begin
                if(mem_is_JAL) begin
                    rs_LW_conf = 1'b0;
                    rs_out = mem_NPC;
                end
                else if(mem_is_MUL) begin
                    rs_LW_conf = 1'b0;
                    rs_out = mem_MDU_out;
                end
                else if(mem_is_LW) begin
                    rs_LW_conf = 1'b1;
                    rs_out = 32'b0;
                end
                else begin
                    rs_LW_conf = 1'b0;
                    rs_out = mem_Z;
                end
            end
            else begin
                rs_LW_conf = 1'b0;
                rs_out = rs_value;
            end
        end
    end

    always @(*) begin
        if(exe_rf_we && exe_rf_waddr == rt && rt != 5'b0) begin
            if(exe_is_JAL) begin
                rt_LW_conf = 1'b0;
                rt_out = exe_NPC;
            end
            else if(exe_is_MUL) begin
                rt_LW_conf = 1'b0;
                rt_out = exe_MDU_out;
            end
            else if(exe_is_LW) begin
                rt_LW_conf = 1'b1;
                rt_out = 32'b0;
            end
            else begin
                rt_LW_conf = 1'b0;
                rt_out = exe_Z;
            end
        end
        else begin
            if(mem_rf_we && mem_rf_waddr == rt && rt != 5'b0)begin
                if(mem_is_JAL) begin
                    rt_LW_conf = 1'b0;
                    rt_out = mem_NPC;
                end
                else if(mem_is_MUL) begin
                    rt_LW_conf = 1'b0;
                    rt_out = mem_MDU_out;
                end
                else if(mem_is_LW) begin
                    rt_LW_conf = 1'b1;
                    rt_out = 32'b0;
                end
                else begin
                    rt_LW_conf = 1'b0;
                    rt_out = mem_Z;
                end
            end
            else begin
                rt_LW_conf = 1'b0;
                rt_out = rt_value;
            end
        end
    end
endmodule