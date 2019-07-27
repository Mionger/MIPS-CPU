module cpu
(
    CLK,
    RST,
    INSTR,
    R_DATA,
    PC,
    IM_R,
    DM_CS,
    DM_W,
    DM_R,
    DMEM_ADDR,
    W_DATA
);

    input CLK;
    input RST;
    input [31:0]INSTR;
    input [31:0]R_DATA;

    output [31:0]PC;
    output IM_R;
    output DM_CS;
    output DM_W;
    output DM_R;
    output [31:0]DMEM_ADDR;
    output [31:0]W_DATA;

    wire [31:0]mux1_out;
    wire [31:0]mux2_out;
    wire [31:0]alu_r;
    wire [3:0]aluc;
    wire zf;
    wire cf;
    wire nf;
    wire of;
    ALU alu
    (
        mux1_out,
        mux2_out,
        aluc,
        alu_r,
        zf,
        cf,
        nf,
        of
    );
    assign DMEM_ADDR = alu_r;

    wire pc_clk;
    wire pc_ena;
    wire [31:0]mux0_out;
    wire [31:0]pc_out;
    PC pc
    (
        pc_clk,
        RST,
        pc_ena,
        mux0_out,
        pc_out
    );
    assign pc_ena = 1'b1;
    assign PC = pc_out;

    wire [4:0]rsc;
    wire [4:0]rtc;
    wire [4:0]rdc;
    wire [4:0]sa;
    wire [15:0]imme;
    wire [25:0]index;
    wire [3:0]head;
    wire [53:0]ir_result;
    IR ir
    (
        INSTR,
        rsc,
        rtc,
        rdc,
        sa,
        imme,
        index,
        head,
        ir_result
    );

    wire [1:0]m0;
    wire m1;
    wire [1:0]m2;
    wire [1:0]m3;
    wire m4;
    wire rf_w;
    ControlUnit controlunit
    (
        CLK,
        ir_result,
        zf,
        pc_clk,
        IM_R,
        m0,
        m1,
        m2,
        m3,
        m4,
        rf_w,
        aluc,
        DM_CS,
        DM_R,
        DM_W
    );

    wire [31:0]rs;
    wire [31:0]rt;
    wire [31:0]mux3_out;
    wire [4:0]mux4_out;
    RegFile cpu_ref
    (
        CLK,
        RST,
        rf_w,
        rsc,
        rtc,
        mux4_out,
        mux3_out,
        rs,
        rt
    );
    assign W_DATA = rt;

    wire [31:0]ext5_out;
    Extend#(5) ext5
    (
        sa,
        ext5_out,
        1'b0
    );

    wire [31:0]ext16_out;
    Extend#(16) ext16
    (
        imme,
        ext16_out,
        1'b0
    );

    wire [31:0]s_ext16_out;
    Extend#(16) s_ext16
    (
        imme,
        s_ext16_out,
        1'b1
    );

    wire [31:0]ext18_out;
    Extend#(18) ext18
    (
        {imme,2'b00},
        ext18_out,
        1'b1
    );

    wire [31:0]ii_out;
    II ii
    (
        head,
        index,
        ii_out
    );

    wire [31:0]npc_out;
    wire npc_cf;
    Adder_32bits npc
    (
        pc_out,
        32'd4,
        1'b0,
        npc_out,
        npc_cf
    );

    wire [31:0]add_out;
    wire add_cf;
    Adder_32bits add
    (
        ext18_out,
        npc_out,
        1'b0,
        add_out,
        add_cf
    );

    wire [31:0]add_jal_out;
    wire add_jal_cf;
    Adder_32bits add_jal
    (
        pc_out,
        32'd4,
        1'b0,
        add_jal_out,
        add_jal_cf
    );

    MUX#(32) mux0
    (
        npc_out,
        rs,
        add_out,
        ii_out,
        m0[1],
        m0[0],
        mux0_out
    );

    MUX#(32) mux1
    (
        ext5_out,
        rs,
        ext5_out,
        rs,
        1'b0,
        m1,
        mux1_out
    );

    MUX#(32) mux2
    (
        rt,
        ext16_out,
        32'b0,
        s_ext16_out,
        m2[1],
        m2[0],
        mux2_out
    );

    MUX#(32) mux3
    (
        R_DATA,
        alu_r,
        32'b0,
        add_jal_out,
        m3[1],
        m3[0],
        mux3_out
    );

    
    MUX#(5) mux4
    (
        rtc,
        rdc,
        rtc,
        rdc,
        1'b0,
        m4,
        mux4_out
    );

endmodule