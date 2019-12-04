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
    sel,
    out
);
    input [31:0]Z;
    input [31:0]Saver;
    input [31:0]NPC;
    input [31:0]MDU_out;
    input [1:0]sel;
    output reg [31:0]out;

    /* 00 Z
     * 01 Saver
     * 10 NPC
     * 11 MDU_out
     */
    always @(*) begin
        if(sel[1]) begin
            if(sel[0]) begin
                out = MDU_out;
            end 
            else begin
                out = NPC;
            end
        end 
        else begin
            if(sel[0]) begin
                out = Saver;
            end 
            else begin
                out = Z;
            end
        end
    end
endmodule