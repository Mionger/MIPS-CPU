`timescale 1ns / 1ps
module SD
(
    clk,
    reset,
    sdclk,
    dout,
    din,
    cs,
    addr,
    re,
    we,
    rdata,
    wdata,
    write_err,
    write_ok,
    read_err,
    read_ok,
    init_err,
    init_ok
);

    //全局信号
    input clk;
    input reset;

    //SD卡信号
    output sdclk;
    input dout;
    output reg din;
    output reg cs;

    //SD卡读写相关
    input [31:0]addr;
    input re;
    input we;
    output [4095:0]rdata;
    input [4095:0]wdata;

    //SD卡反馈
    output write_err;
    output write_ok;
    output read_err;
    output read_ok;
    output init_err;
    output init_ok;

    //分频，初始化时钟
    wire clk_init;
    reg [9:0]clk_init_counter = 10'b0;
    always @(posedge clk) begin
        clk_init_counter <= clk_init_counter + 1'b1;
    end
    assign clk_init = clk_init_counter[9];

    reg sdclk_cs;//状态机确定
    assign sdclk = sdclk_cs? clk: clk_init;
    
    reg [1:0]din_cs = 2'd0;//状态机提供
    reg [1:0]cs_cs = 2'd0;//状态机提供
    
    //SD卡初始化
    wire init_cs;
    wire init_din;
    SD_Init sd_init(sdclk, reset, 1'b1, dout, init_cs, init_din, init_ok, init_err); 

    //SD卡读取
    reg sd_re = 1'b0;//状态机控制
    wire sd_read_cs;
    wire sd_read_din;
    SD_Read sd_read(sdclk, reset, addr, sd_re, dout, sd_read_cs, sd_read_din, rdata, read_ok, read_err);

    //SD卡写入
    reg sd_we = 1'b0;//状态机控制
    wire sd_write_cs;
    wire sd_write_din;
    SD_Write sd_write(sdclk, reset, addr, wdata, sd_we, dout, sd_write_cs, sd_write_din, write_ok, write_err);

    //状态机参数
    parameter INIT  = 7'd1;
    parameter IDLE  = 7'd2;
    parameter ERROR = 7'd3;
    parameter TO_READ = 7'd4;
    parameter READ_END = 7'd5;
    parameter TO_WRITE = 7'd6;
    parameter WRITE_END = 7'd7;

    reg [6:0]current_state = INIT;
    reg [6:0]next_state = INIT;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            current_state <= INIT;
        end
        else begin
            current_state <= next_state;
        end
    end
    always @(*) begin
        case (current_state)
            INIT:begin
                if(init_ok) begin
                    next_state = IDLE;
                end 
                else if(init_err) begin
                    next_state = ERROR;
                end
                else begin
                    next_state = INIT;
                end
            end 
            IDLE:begin
                if(re) begin
                    next_state = TO_READ;
                end
                else if(we) begin
                    next_state = TO_WRITE;
                end
                else begin
                    next_state = IDLE;    
                end
            end
            TO_READ:begin
                if(read_ok) begin
                    next_state = READ_END;
                end
                else if(read_err) begin
                    next_state = ERROR;
                end
                else begin
                    next_state = TO_READ;
                end
            end
            READ_END:begin
                if(re)begin
                    next_state = READ_END;
                end
                else begin
                    next_state = IDLE;
                end
            end
            TO_WRITE:begin
                if(write_ok)begin
                    next_state = WRITE_END;
                end
                else if(write_err)begin
                    next_state = ERROR;
                end
                else begin
                    next_state = TO_WRITE;
                end
            end
            WRITE_END:begin
                if(we)begin
                    next_state = WRITE_END;
                end
                else begin
                    next_state  =IDLE;
                end
            end
            ERROR:begin
                next_state = ERROR;
            end
            default:begin
                next_state = INIT;
            end
        endcase
    end

    //时钟选择
    always @(*) begin
        case (current_state)
            INIT:begin
                sdclk_cs = 1'b0;
            end 
            default:begin
                sdclk_cs = 1'b1;
            end
        endcase
    end

    //片选信号选择
    always @(*) begin
        case (current_state)
            INIT:begin
                din_cs = 2'b00;
                cs_cs = 2'b00;
            end 
            TO_READ:begin
                din_cs = 2'b10;
                cs_cs = 2'b10;
            end
            READ_END:begin
                din_cs = 2'b10;
                cs_cs = 2'b10;
            end
            TO_WRITE:begin
                din_cs = 2'b11;
                cs_cs = 2'b11;
            end
            WRITE_END:begin
                din_cs = 2'b11;
                cs_cs = 2'b11;
            end
            default:begin
                din_cs = 2'b00;
                cs_cs = 2'b00;
            end
        endcase
    end

    //cs片选
    always @(*) begin
        if(!cs_cs[1])begin
            cs = init_cs;
        end
        else begin
            if(!cs_cs[0])begin
                cs = sd_read_cs;
            end
            else begin
                cs = sd_write_cs;
            end
        end
    end

    //din片选
    always @(*) begin
        if(!din_cs[1])begin
            din = init_din;
        end
        else begin
            if(!din_cs[0])begin
                din = sd_read_din;
            end
            else begin
                din = sd_write_din;
            end
        end
    end

    //向SD卡发送使能信号
    always @(*) begin
        case (current_state)
            TO_READ:begin
                sd_re = 1'b1;
                sd_we = 1'b0;
            end 
            READ_END:begin
                sd_re = 1'b1;
                sd_we = 1'b0;
            end
            TO_WRITE:begin
                sd_re = 1'b0;
                sd_we = 1'b1;
            end
            WRITE_END:begin
                sd_re = 1'b0;
                sd_we = 1'b1;
            end
            default:begin
                sd_re = 1'b0;
                sd_we = 1'b0;
            end
        endcase
    end
endmodule
