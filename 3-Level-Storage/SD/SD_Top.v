`timescale 1ns / 1ps
module SD_Top
(
    clk,
    reset,
    sdclk,
    dout,
    din,
    cs,
    led,
    switch,
    up,
    down,
    right
);

    input clk;
    input reset;

    output sdclk;
    input dout;
    output din;
    output cs;

    output [15:0]led;
    input [15:0]switch;

    input up;
    input down;
    input right;

    wire [31:0]sd_addr;
    wire sd_re;
    wire sd_we;
    wire [4095:0]rdata;
    wire [4095:0]wdata;
    wire init_err;
    wire init_ok;
    wire read_err;
    wire read_ok;
    wire write_err;
    wire write_ok;
    assign sd_addr = 32'd0;
    assign sd_re = up;
    assign sd_we = down;
    SD sd
    (
        clk,
        reset,
        sdclk,
        dout,
        din,
        cs,
        sd_addr,
        sd_re,
        sd_we,
        rdata,
        wdata,
        write_err,
        write_ok,
        read_err,
        read_ok,
        init_err,
        init_ok
    );

    wire [15:0]div_out;
    SD_Read_Div sd_read_div(rdata,switch[7:0],div_out);

    SD_Write_Buffer sd_write_buffer(clk,reset,switch,sd_addr[7:0],right,wdata); 
    
    assign led = switch[15]?div_out:{10'd0,write_err,write_ok,read_err,read_ok,init_err,init_ok};
endmodule
