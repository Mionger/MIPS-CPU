`timescale 1ns / 1ps
module top
(
    clk_in,
    reset,
    o_seg,
    o_sel,
    sd_clk,
    sd_dout,
    sd_din,
    sd_cs,
    ddr2_dq,
    ddr2_dqs_n,
    ddr2_dqs_p,
    ddr2_addr,
    ddr2_ba,
    ddr2_ras_n,
    ddr2_cas_n,
    ddr2_we_n,
    ddr2_ck_p,
    ddr2_ck_n,
    ddr2_cke,
    ddr2_cs_n,
    ddr2_dm,
    ddr2_odt,
);
    input clk_in;
    input reset;

    output [7:0]o_seg;
    output [7:0]o_sel;

    output sd_clk;
    input sd_dout; 
    output sd_din;
    output sd_cs;

    inout [15:0]ddr2_dq;
    inout [1:0]ddr2_dqs_n;
    inout [1:0]ddr2_dqs_p;
    output [12:0]ddr2_addr;
    output [2:0]ddr2_ba;
    output ddr2_ras_n;
    output ddr2_cas_n;
    output ddr2_we_n;
    output [0:0]ddr2_ck_p;
    output [0:0]ddr2_ck_n;
    output [0:0]ddr2_cke;
    output [0:0]ddr2_cs_n;
    output [1:0]ddr2_dm;
    output [0:0]ddr2_odt;

    wire [31:0]dmem_data_out;
    wire [31:0]dmem_data_in;
    wire [31:0]dmem_addr_real;
    wire [31:0]dmem_addr;
    wire dmem_cs;
    wire dmem_w;
    wire dmem_r;
    dmem mydmem
    (
        .clk(~clk_in),
        .we(dmem_w),
        .addr(dmem_addr_real[10:0]),
        .wdata(cpu_data_out),
        .data_out(dmem_data_out)
    );
    assign dmem_addr_real = cpu_addr - 32'h10010000;

    reg [31:0]pc;
    wire [31:0]pc_real;
    wire [31:0]inst;
    wire [31:0]imem_in;
    wire imem_we;
    imem myimem
    (
        .clk(clk_in),
        .reset(reset),
        .a(pc_real[12:2]),
        .d(imem_in),
        .we(imem_we),
        .spo(inst)
    );
    assign pc_real = pc - 32'h00400000;

    wire[31:0]pc_out;

    wire [3:0]current_state;
    wire [3:0]next_state;
    wire [31:0]cpu_addr;
    wire [31:0]cpu_data_out;
    wire [31:0]cpu_data_in;
    wire cpu_we;
    wire sd_write_ok;
    cpu sccpu
    (
        clk_in,
        reset,
        inst,
        pc_out,
        cpu_addr,
        cpu_data_in,
        cpu_data_out,
        cpu_we,
        sd_write_ok,
        current_state,
        next_state
    );

    //七段数码管
    seg7x16 seg
    (
        clk_in,
        reset,
        1,
        pc,
        o_seg,
        o_sel
    );

    //sd_ddr_cache
    wire [31:0]data_read;
    wire sd_buffer_we;
    wire sd_we;
    wire cache_re;
    wire [6:0]sd_ddr_cache_state;
    module SD_DDR_Cache
    (
        clk,
        reset,
        sd_clk,
        sd_dout,
        sd_din,
        sd_cs,
        ddr2_dq,
        ddr2_dqs_n,
        ddr2_dqs_p,
        ddr2_addr,
        ddr2_ba,
        ddr2_ras_n,
        ddr2_cas_n,
        ddr2_we_n,
        ddr2_ck_p,
        ddr2_ck_n,
        ddr2_cke,
        ddr2_cs_n,
        ddr2_dm,
        ddr2_odt, 
    
        cpu_addr,//对cache请求数据的地址
        cpu_addr,//对SD写入数据的地址

        data_read,//cache读出来的数据
        cpu_data_out,//写入SD数据

        sd_buffer_we,
        sd_we,
        cache_re,

        sd_write_ok,

        sd_ddr_cache_state
    );

    wire sd_state_we;
    wire [31:0]sd_state;
    assign sd_state = sd_state_we?cpu_data_out:32'd0;
    assign sd_we = sd_state[0];
    INTERFACE_O interface_o
    (
        cpu_addr,
        cpu_we,
        dmem_w,
        sd_buffer_we,
        sd_state_we
    );

    INTERFACE_I interface_i
    (
        cpu_addr,
        dmem_data_out,
        data_read,
        cpu_data_in
    );

    always @(posedge clk_in or posedge reset) begin
        if(reset) begin
            pc <= 32'h00400000;
        end
        else if(next_state == 4'b0001) begin
            pc <= pc_out;
        end
        else begin
            pc <= pc;
        end
    end

endmodule