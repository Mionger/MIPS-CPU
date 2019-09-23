`timescale 1ns / 1ps
module CPU
(
    CLK,
    RST,
    INST,
    PC,
    ADDR,
    DATA_IN,
    DATA_OUT,
    DMEM_W,
    CURRENT_STATE,
    NEXT_STATE
);
    input CLK;
    input RST;
    input [31:0]INST;
    input [31:0]DATA_IN;

    output [31:0]PC;
    output [31:0]ADDR;
    output [31:0]DATA_OUT;
    output DMEM_W;
    output [3:0]CURRENT_STATE;
    output [3:0]NEXT_STATE;

    wire [31:0]m4_out;
    wire [31:0]m5_out;
    wire [3:0]aluc;
    wire [31:0]alu_result;
    wire alu_zero;
    wire alu_carry;
    wire alu_negative;
    wire alu_overflow;
    ALU alu
    (
        m4_out,
        m5_out,
        aluc,
        alu_result,
        alu_zero,
        alu_carry,
        alu_negative,
        alu_overflow
    );

    wire r_ena;
    wire [31:0]r_out;
    R r
    (
	    CLK,
        r_ena,
        alu_result,
        r_out
    );
    assign ADDR = r_out;

    wire pc_ena;
    wire [31:0]m0_out;
    wire [31:0]pc_out;
    ProgramCounter pc
    (
        CLK, 
        RST, 
        pc_ena, 
        m0_out, 
        pc_out
    );
    assign PC = pc_out;

    wire ir_ena;
    wire [31:0]ir_out;
    IR ir
    (
	    CLK,
        ir_ena,
        INST,
        ir_out
    );

    wire [5:0]op;
    wire [4:0]rsc;
    wire [4:0]rtc;
    wire [4:0]rdc;
    wire [4:0]sa;
    wire [5:0]func;
    wire [15:0]imme;
    wire [25:0]index;
    ID id
    (
        ir_out,
        op,
        rsc,
        rtc,
        rdc,
        sa,
        func,
        imme,
        index
    );

    wire rf_w;
    wire [4:0]m3_out;
    wire [31:0]m10_out;
    wire [31:0]rs;
    wire [31:0]rt;
    RegFile cpu_ref
    (
        CLK, 
        RST, 
        rf_w, 
        rsc, 
        rtc, 
        m3_out, 
        m10_out, 
        rs, 
        rt
    );

    wire [1:0]mduc;
    wire mdu_start;
    wire mdu_busy;
    wire [31:0]mdu_r1;
    wire [31:0]mdu_r2;
    MDU mdu
    (
        CLK, 
        rs, 
        rt, 
        mduc, 
        mdu_start, 
        mdu_busy, 
        mdu_r1, 
        mdu_r2
    );

    wire save_ena;
    wire [31:0]m14_out;
    wire [31:0]save_out;
    SAVE save
    (
        CLK,
        save_ena,
        m14_out,
        save_out
    );

    wire [15:0]m16_out;
    wire [31:0]sign_ext_16_out;
    EXT #(16) sign_ext_16
    (
        m16_out,
        sign_ext_16_out,
        1'b1
    );

    wire [15:0]m15_out;
    wire [31:0]zero_ext_16_out;
    EXT #(16) ext_16
    (
        m15_out,
        zero_ext_16_out,
        1'b0
    );

    wire [31:0]sign_ext_18_out;
    EXT #(18) sign_ext_18
    (
        {imme,2'b00},
        sign_ext_18_out,
        1'b1
    );

    wire [31:0]sign_ext_8_out;
    EXT #(8) sign_ext_8
    (
        save_out[7:0],
        sign_ext_8_out,
        1'b1
    );

    wire [31:0]zero_ext_8_out;
    EXT #(8) ext_8
    (
        save_out[7:0],
        zero_ext_8_out,
        1'b0
    );

    wire [31:0]zero_ext_5_out;
    EXT #(5) ext_5
    (
        sa,
        zero_ext_5_out,
        1'b0
    );

    wire [31:0]ii_out;
    II ii
    (
        PC[31:28],
        index,
        ii_out
    );

    wire [31:0]ii8_out;
    II8 ii8
    (
        DATA_IN[31:8],
        rt[7:0],
        ii8_out
    );

    wire [31:0]ii16_out;
    II16 ii16
    (
        DATA_IN[31:16],
        rt[15:0],
        ii16_out
    );

    wire CP0_mfc0;
    wire CP0_mtc0;
    wire CP0_exception;
    wire CP0_eret;
    wire CP0_intr;
    wire CP0_timer_int;
    wire [4:0]CP0_cause;
    wire [31:0]CP0_out;
    wire [31:0]CP0_status;
    wire [31:0]CP0_epc;
    CP0 cp0
    (
        CLK,
        RST,
        CP0_mfc0,
        CP0_mtc0,
        PC,
        rdc,
        rt,
        CP0_exception,
        CP0_eret,
        CP0_cause,
        CP0_intr,
        CP0_out,
        CP0_status,
        CP0_timer_int,
        CP0_epc
    );

    wire hi_ena;
    wire [31:0]m12_out;
    wire [31:0]hi_out;
    HI hi
    (
        CLK,
        hi_ena,
        m12_out,
        hi_out
    );

    wire lo_ena;
    wire [31:0]m13_out;
    wire [31:0]lo_out;
    LO lo
    (
        CLK,
        lo_ena,
        m13_out,
        lo_out
    );

    wire [31:0]clz_out;
    CLZ clz
    (
        rs,
        clz_out
    );

    wire [31:0]m1_out;
    wire [31:0]m2_out;
    wire [1:0]m0;
    MUX M0
    (
        m1_out,
        m2_out,
        32'd0,
        32'd0,
        m0[1],
        m0[0],
        m0_out
    );

    wire [1:0]m1;
    MUX M1
    (
        r_out,
        alu_result,
        ii_out,
        CP0_epc,
        m1[1],
        m1[0],
        m1_out
    );

    wire [1:0]m2;
    MUX M2
    (
        32'h00400004,
        rs,
        32'd0,
        32'd0,
        m2[1],
        m2[0],
        m2_out
    );

    wire [1:0]m3;
    MUX #(5)M3
    (
        rdc,
        rtc,
        rsc,
        5'd31,
        m3[1],
        m3[0],
        m3_out
    );

    wire [1:0]m4;
    MUX M4
    (
        rs,
        zero_ext_5_out,
        pc_out,
        32'd0,
        m4[1],
        m4[0],
        m4_out
    );

    wire[1:0]m5;
    wire [31:0]m6_out;
    MUX M5
    (
        rt,
        m6_out,
        32'd4,
        32'd0,
        m5[1],
        m5[0],
        m5_out
    );

    wire[1:0]m6;
    MUX M6
    (
        zero_ext_16_out,
        sign_ext_16_out,
        sign_ext_18_out,
        32'd0,
        m6[1],
        m6[0],
        m6_out
    );

    wire[1:0]m7;
    wire[31:0]m7_out;
    MUX M7
    (
        r_out,
        save_out,
        zero_ext_16_out,
        sign_ext_16_out,
        m7[1],
        m7[0],
        m7_out
    );

    wire[1:0]m8;
    wire[31:0]m8_out;
    MUX M8
    (
        zero_ext_8_out,
        sign_ext_8_out,
        pc_out,
        clz_out,
        m8[1],
        m8[0],
        m8_out
    );

    wire[1:0]m9;
    wire[31:0]m9_out;
    MUX M9
    (
        hi_out,
        lo_out,
        mdu_r2,
        32'd0,
        m9[1],
        m9[0],
        m9_out
    );

    wire[1:0]m10;
    MUX M10
    (
        m7_out,
        m8_out,
        m9_out,
        32'd0,
        m10[1],
        m10[0],
        m10_out
    );

    wire[1:0]m11;
    MUX M11
    (
        ii16_out,
        ii8_out,
        rt,
        32'd0,
        m11[1],
        m11[0],
        DATA_OUT
    );

    wire[1:0]m12;
    MUX M12
    (
        mdu_r1,
        rs,
        32'd0,
        32'd0,
        m12[1],
        m12[0],
        m12_out
    );

    wire[1:0]m13;
    MUX M13
    (
        mdu_r2,
        rs,
        32'd0,
        32'd0,
        m13[1],
        m13[0],
        m13_out
    );

    wire[1:0]m14;
    MUX M14
    (
        DATA_IN,
        CP0_out,
        32'd0,
        32'd0,
        m14[1],
        m14[0],
        m14_out
    );

    wire[1:0]m15;
    MUX #(16)M15
    (
        imme,
        save_out[15:0],
        16'd0,
        16'd0,
        m15[1],
        m15[0],
        m15_out
    );

    wire[1:0]m16;
    MUX #(16)M16
    (
        imme,
        save_out[15:0],
        16'd0,
        16'd0,
        m16[1],
        m16[0],
        m16_out
    );

    ControlUnit controlunit
    (
        CLK,
        RST,
        op,
        rsc,
        func,
        r_out,
        rs,
        mdu_busy,
        CP0_status,
        alu_zero,
        m0,
        m1,
        m2,
        m3,
        m4,
        m5,
        m6,
        m7,
        m8,
        m9,
        m10,
        m11,
        m12,
        m13,
        m14,
        m15,
        m16,
        pc_ena,
        ir_ena,
        r_ena,
        rf_w,
        save_ena,
        aluc,
        hi_ena,
        lo_ena,
        mdu_start,
        mduc,
        DMEM_W,
        CP0_cause,
        CP0_exception,
        CP0_eret,
        CP0_mfc0,
        CP0_mtc0,
        CURRENT_STATE,
        NEXT_STATE
    );
endmodule
