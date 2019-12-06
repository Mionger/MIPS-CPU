`timescale 1ns / 1ps
module DDR_Top
(
    input clk,
    input reset,
    input [2:0]switch,
    output [15:0]led,
    input up,
    input down,
    input left,
    input right,
    inout [15:0]            ddr2_dq,
    inout [1:0]             ddr2_dqs_n,
    inout [1:0]             ddr2_dqs_p,
    output [12:0]           ddr2_addr,
    output [2:0]            ddr2_ba,
    output                  ddr2_ras_n,
    output                  ddr2_cas_n,
    output                  ddr2_we_n,
    output [0:0]            ddr2_ck_p,
    output [0:0]            ddr2_ck_n,
    output [0:0]            ddr2_cke,
    output [0:0]            ddr2_cs_n,
    output [1:0]            ddr2_dm,
    output [0:0]            ddr2_odt
);

    wire [23:0]addr;
    wire [127:0]wdata;
    wire [127:0]rdata;
    wire wend;
    wire we;
    wire re;
    wire rend;
    wire [2:0]state;
    assign {we,re} = {left, right};
    assign addr = 24'd0;
    DDR2_Ram ddr2_ram
    (
        clk,
        clk,
        reset,
        we,
        re,
        addr,
        wdata,
        rdata,
        wend,
        rend,
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
        state
    );

    wire [15:0]data_read;
    DDR_Read_Div ddr_read_div
    (
        rdata,
        switch,
        data_read
    );

    wire [15:0]data_write;
    assign data_write = 16'hffff;
    DDR_Write_Buffer ddr_write_buffer
    (
        clk,
        reset,
        data_write,
        switch,
        up,
        wdata
    );

    assign led = down?data_read:{14'd0, wend, rend};
endmodule
