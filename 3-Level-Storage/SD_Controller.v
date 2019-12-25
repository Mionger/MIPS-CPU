`timescale 1ns / 1ps
module SD_Controller
(
    clk,
    reset,
    sd_clk,
    sd_dout,
    sd_din,
    sd_cs,
    sd_ctrl_addr_read,
    sd_ctrl_addr_write,
    sd_ctrl_re,
    sd_ctrl_we,
    sd_ctrl_data_read,
    sd_ctrl_data_write,
    init_ok,
    init_err,
    read_ok,
    read_err,
    write_ok,
    write_err,
    state
);
    input clk;
    input reset;
    input sd_dout;
    input [31:0]sd_ctrl_addr_read;
    input [31:0]sd_ctrl_addr_write;
    input sd_ctrl_re;
    input sd_ctrl_we;
    input [4095:0]sd_ctrl_data_write;

    output sd_clk;
    output sd_din;
    output sd_cs;
    output [4095:0]sd_ctrl_data_read;
    output init_ok;
    output init_err;
    output read_ok;
    output read_err;
    output write_ok;
    output write_err;
    output [3:0]state;

    reg sd_din;
    reg sd_cs;
    reg [1:0]din_cs = 2'd0;
    reg [1:0]cs_cs = 2'd0;

    wire clk_init;
    
    //分频，获取初始化时钟
    reg [9:0]clk_init_counter = 10'b0;
    always @(posedge clk) begin
        clk_init_counter <= clk_init_counter + 1'b1;
    end
    assign clk_init = clk_init_counter[9];
    
    reg sd_clk_cs;
    assign sd_clk = sd_clk_cs? clk: clk_init;

    wire init_cs;
    wire init_din;
    SD_Init sd_init(sd_clk, reset, 1'b1, sd_dout, init_cs, init_din, init_ok, init_err); 


    reg sd_re = 1'b0;
    wire sd_read_cs;
    wire sd_read_din;
    SD_Read sd_read(sd_clk, reset, sd_ctrl_addr_read, sd_re, sd_dout, sd_read_cs, sd_read_din, sd_ctrl_data_read, read_ok, read_err);

    reg sd_we = 1'b0;
    wire sd_write_cs;
    wire sd_write_din;
    SD_Write sd_write(sd_clk, reset, sd_ctrl_addr_write, sd_ctrl_data_write, sd_we, sd_dout, sd_write_cs, sd_write_din, write_ok, write_err);

    parameter INIT  = 4'd1;
    parameter IDLE  = 4'd2;
    parameter ERROR = 4'd3;
    parameter TO_READ = 4'd4;
    parameter READ_END = 4'd5;
    parameter TO_WRITE = 4'd6;
    parameter WRITE_END = 4'd7;   

    reg [3:0]current_state = INIT;
    reg [3:0]next_state = INIT;
    assign state = current_state;
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
                    next_state <= IDLE;
                end 
                else if(init_err) begin
                    next_state <= ERROR;
                end
                else begin
                    next_state <= INIT;
                end
            end
            IDLE:begin
                if(sd_ctrl_re) begin
                    next_state <= TO_READ;
                end
                else if(sd_ctrl_we) begin
                    next_state <= TO_WRITE;
                end
                else begin
                    next_state <= IDLE;    
                end
            end
            ERROR:begin
                next_state <= ERROR;
            end 
            TO_READ:begin
                if(read_ok)begin
                    next_state <= READ_END;
                end
                else if(read_err)begin
                    next_state <= ERROR;
                end
                else begin
                    next_state <= READ_END;
                end
            end
            READ_END:begin
                if(sd_ctrl_re)begin
                    next_state <= READ_END;
                end
                else begin
                    next_state <= IDLE;
                end
            end
            TO_WRITE:begin
                if(write_ok)begin
                    next_state <= WRITE_END;
                end
                else if(write_err)begin
                    next_state <= ERROR;
                end
                else begin
                    next_state <= TO_WRITE;
                end
            end
            WRITE_END:begin
                if(sd_ctrl_we)begin
                    next_state <= WRITE_END;
                end
                else begin
                    next_state <= IDLE;
                end
            end
            default:begin
                next_state = INIT;
            end
        endcase
    end

    always @(*) begin
        case (current_state)
            INIT:begin
                sd_clk_cs <= 1'b0;
            end 
            default:begin
                sd_clk_cs <= 1'b1;
            end 
        endcase
    end

    always @(*) begin
        case (current_state)
            INIT:begin
                din_cs <= 2'b00;
                cs_cs  <= 2'b00;
            end 
            TO_READ:begin
                din_cs <= 2'b10;
                cs_cs  <= 2'b10;
            end
            READ_END:begin
                din_cs <= 2'b10;
                cs_cs  <= 2'b10;
            end
            TO_WRITE:begin
                din_cs <= 2'b11;
                cs_cs  <= 2'b11;
            end
            WRITE_END:begin
                din_cs <= 2'b11;
                cs_cs  <= 2'b11;
            end
            default:begin
                din_cs <= 2'b00;
                cs_cs  <= 2'b00;
            end 
        endcase
    end

    always @(*) begin
        if(!cs_cs[1])begin
            sd_cs <= init_cs;
        end
        else begin
            if(!cs_cs[0])begin
                sd_cs <= sd_read_cs;
            end
            else begin
                sd_cs <= sd_write_cs;
            end
        end
    end

    always @(*) begin
        if(!din_cs[1])begin
            sd_din <= init_din;
        end
        else begin
            if(!din_cs[0])begin
                sd_din <= sd_read_din;
            end
            else begin
                sd_din <= sd_write_din;
            end
        end
    end

    always @(*) begin
        case (current_state)
            TO_READ:begin
                sd_re <= 1'b1;
                sd_we <= 1'b0;
            end 
            READ_END:begin
                sd_re <= 1'b1;
                sd_we <= 1'b0;
            end
            TO_WRITE:begin
                sd_re <= 1'b0;
                sd_we <= 1'b1;
            end
            WRITE_END:begin
                sd_re <= 1'b0;
                sd_we <= 1'b1;
            end
            default:begin
                sd_re <= 1'b0;
                sd_we <= 1'b0;
            end
        endcase
    end
endmodule