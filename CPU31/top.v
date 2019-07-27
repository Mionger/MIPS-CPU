module CPU31
(
    clk_in,
    reset,
    inst,
    pc
);
    input clk_in;
    input reset;

    output [31:0]inst;
    output [31:0]pc;

    wire [31:0]dmem_data_out;
    wire [31:0]dmem_data_in;
    wire [31:0]dmem_addr_real;
    wire [31:0]dmem_addr;
    wire dmem_cs;
    wire dmem_w;
    wire dmem_r;
    dmem mydmem
    (
        .clk(clk_in),
        .we(dmem_w),
        .addr(dmem_addr[10:0]),
        .wdata(dmem_data_in),
        .data_out(dmem_data_out)
    );
    assign dmem_addr_real = dmem_addr - 32'h10010000;

    wire im_r;
    wire [31:0]pc_real;
    imem myimem
    (
        .a(pc[12:2]),
        .spo(inst)
    );
    assign pc_real = pc - 32'h00400000;

    cpu mycpu
    (
        clk_in,
        reset,
        inst,
        dmem_data_out,
        pc,
        im_r,
        dmem_cs,
        dmem_w,
        dmem_r,
        dmem_addr,
        dmem_data_in
    );
endmodule
