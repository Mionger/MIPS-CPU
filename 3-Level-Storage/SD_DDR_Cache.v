`timescale 1ns / 1ps
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
    
    addr_read,//对cache请求数据的地址
    addr_write,//对SD写入数据的地址
    
    data_read,//cache读出来的数据
    data_write,//写入SD数据

    sd_buffer_we,
    sd_we,
    cache_re,

    sd_write_ok,

    state
);

    input clk;
    input reset;
    
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

    input [31:0]addr_read;
    input [31:0]addr_write;

    output [31:0]data_read;
    input [31:0]data_write;

    input sd_buffer_we;
    input sd_we;
    input cache_re;

    output sd_write_ok;

    output [6:0]state;

    wire clk200;
    wire clk333;
    clk_wiz_0 cw(.clk_in1(clk),.clk_out1(clk200), .clk_out2(clk333));

    reg [31:0]sd_ctrl_addr_read; 
    reg [31:0]sd_ctrl_addr_write;
    reg sd_ctrl_re;
    reg sd_ctrl_we;
    wire [4095:0]sd_ctrl_data_read;
    wire [4095:0]sd_ctrl_data_write;
    wire init_ok;
    wire init_err;
    wire read_ok;
    wire read_err;
    wire write_ok;
    wire write_err;
    assign sd_write_ok = write_ok;
    wire [3:0]sd_ctrl_state;
    SD_Controller sd_controller
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
        sd_ctrl_state
    );

    wire sd_buffer_write_end;//状态转移判断条件
    wire [3:0]sd_buffer_state;
    reg sd_buffer_write_we;
    SD_Buffer sd_buffer
    (
        clk,
        reset,
        addr_write[8:2],
        sd_buffer_write_we,
        data_write,
        sd_ctrl_data_write,
        sd_buffer_write_end,
        sd_buffer_state
    );

    wire [4095:0]ddr_ctrl_data_to_cache;
    wire [4095:0]ddr_ctrl_data_from_buffer;
    wire [4095:0]ddr_ctrl_data_to_buffer;
    wire [31:0]ddr_ctrl_addr_from_cache;
    wire [31:0]ddr_ctrl_addr_to_buffer;
    reg ddr_ctrl_read_from_sd;
    reg ddr_ctrl_write_to_buffer;
    reg ddr_ctrl_read_from_buffer;
    reg ddr_ctrl_write_to_cache;
    wire ddr_ctrl_from_buffer_write_ok;
    wire ddr_ctrl_from_buffer_read_ok;
    wire ddr_ctrl_from_ddr_write_ok;
    wire ddr_ctrl_from_ddr_read_ok;
    wire ddr_ctrl_we_ctrl_to_buffer;
    wire ddr_ctrl_re_ctrl_from_buffer;
    wire ddr_ctrl_we_buffer_to_ddr;
    wire ddr_ctrl_we_ddr_to_buffer;
    wire ddr_ctrl_read_sd_ok;
    wire ddr_ctrl_write_buffer_ok;
    wire ddr_ctrl_read_buffer_ok;
    wire ddr_ctrl_send_to_cache_ok;
    wire [6:0]ddr_ctrl_state;
    DDR_Controller ddr_controller
    (
        clk,
        reset,
        sd_ctrl_data_read,
        ddr_ctrl_data_to_cache,
        ddr_ctrl_data_from_buffer,
        ddr_ctrl_data_to_buffer,
        ddr_ctrl_addr_from_cache,
        ddr_ctrl_addr_to_buffer,
        ddr_ctrl_read_from_sd,
        ddr_ctrl_write_to_buffer,
        ddr_ctrl_read_from_buffer,
        ddr_ctrl_write_to_cache,
        ddr_ctrl_from_buffer_write_ok,
        ddr_ctrl_from_buffer_read_ok,
        ddr_ctrl_from_ddr_write_ok,
        ddr_ctrl_from_ddr_read_ok,
        ddr_ctrl_we_ctrl_to_buffer,
        ddr_ctrl_re_ctrl_from_buffer,
        ddr_ctrl_we_buffer_to_ddr,
        ddr_ctrl_we_ddr_to_buffer,
        ddr_ctrl_read_sd_ok,
        ddr_ctrl_write_buffer_ok,
        ddr_ctrl_read_buffer_ok,
        ddr_ctrl_send_to_cache_ok,
        ddr_ctrl_state
    );

    wire ddr2_we;
    wire ddr2_re;
    wire [23:0]ddr2_addr;
    wire [127:0]ddr2_wdata;
    wire [127:0]ddr2_rdata;
    wire ddr2_wend;
    wire ddr2_rend;
    wire [2:0]ddr2_state;
    DDR2_Ram ddr_ram
    (
        clk200,
        clk333,
        reste,
        ddr2_we,
        ddr2_re,
        ddr2_addr,
        ddr2_wdata,
        ddr2_rdata,
        ddr2_wend,
        ddr2_rend,
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
        ddr2_state
    );

    wire [6:0]ddr_buffer_state;
    DDR_Buffer ddr_buffer
    (
        clk,
        reset,
        ddr_ctrl_data_to_buffer,
        ddr_ctrl_data_from_buffer,
        ddr2_wdata,
        ddr2_rdata,
        ddr_ctrl_addr_to_buffer,
        ddr2_addr,
        ddr_ctrl_we_ctrl_to_buffer,
        ddr_ctrl_re_ctrl_from_buffer,
        ddr_ctrl_we_buffer_to_ddr,
        ddr_ctrl_we_ddr_to_buffer,
        ddr2_we,
        ddr2_re,
        ddr2_wend,
        ddr2_rend,
        ddr_ctrl_from_buffer_write_ok,
        ddr_ctrl_from_buffer_read_ok,
        ddr_ctrl_from_ddr_write_ok,
        ddr_ctrl_from_ddr_read_ok,
        ddr_buffer_state
    );

    reg cache_ctrl_from_cache_re;
    reg cache_ctrl_to_cache_we;
    reg cache_ctrl_from_ddr_re;
    reg cache_ctrl_to_cpu_we;
    wire [31:0]cache_ctrl_data_from_cache;
    wire cache_buffer_write_end;
    wire [31:0]cache_ctrl_addr_to_cache;
    wire [4095:0]cache_ctrl_data_to_cache;
    wire cache_buffer_we;
    wire [4:0]cache_ctrl_state;
    Cache_Controller cache_controller
    (
        clk,
        reset,
        cache_ctrl_from_cache_re,
        cache_ctrl_to_cache_we,
        cache_ctrl_from_ddr_re,
        cache_ctrl_to_cpu_we,
        addr_read,
        ddr_ctrl_data_to_cache,
        cache_ctrl_data_from_cache,
        cache_buffer_write_end,
        cache_ctrl_addr_to_cache,
        ddr_ctrl_addr_from_cache,
        cache_ctrl_data_to_cache,
        data_read,
        cache_buffer_we,
        cache_ctrl_state
    );

    wire [31:0]ddr_buffer_data_to_cache;
    wire ddr_buffer_we_to_cache;
    Cache_Buffer cache_buffer
    (
        clk,
        reset,
        cache_ctrl_data_to_cache,
        cache_buffer_we,
        cache_buffer_write_end,
        addr_read[10:9],
        ddr_buffer_data_to_cache,
        addr_to_cache[8:2],
        ddr_buffer_we_to_cache
    );

    Cache cache
    (
        .clk(clk),
        .a(addr_read[10:2]),
        .d(cache_ctrl_data_to_cache),
        .we(ddr_buffer_we_to_cache),
        .spo(cache_ctrl_data_from_cache),
    );

    parameter INIT_START           = 7'd1;
    parameter INIT_SD_INIT         = 7'd2;
    parameter INIT_CODE_TO_DDR     = 7'd3;
    parameter READ_FROM_SD_CODE    = 7'd4;
    parameter WRITE_TO_CTRL_CODE   = 7'd5;
    parameter WRITE_TO_DDR_CODE    = 7'd6;
    parameter INIT_DATA_TO_DDR     = 7'd7;
    parameter READ_FROM_SD_DATA    = 7'd8;
    parameter WRITE_TO_CTRL_DATA   = 7'd9;
    parameter WRITE_TO_DDR_DATA    = 7'd10;
    parameter INIT_DDR_END         = 7'd11;
    parameter INIT_CODE_TO_CACHE   = 7'd12;
    parameter READ_FROM_DDR_CODE   = 7'd13;
    parameter READ_FROM_CTRL_CODE = 7'd14;
    parameter WRITE_TO_CTRL_CODE   = 7'd15;
    parameter WRITE_TO_CACHE_CODE  = 7'd16;
    parameter INIT_DATA_TO_CACHE   = 7'd17;
    parameter READ_FROM_DDR_DATA   = 7'd18;
    parameter READ_FROM_CTRL_DATA  = 7'd19;
    parameter WRITE_TO_CTRL_DATA   = 7'd20;
    parameter WRITE_TO_CACHE_DATA  = 7'd21;
    parameter INIT_CACHE_END       = 7'd22;
    parameter IDLE                 = 7'd23;
    parameter TO_READ              = 7'd24;
    parameter READ_FROM_CACHE      = 7'd25;
    parameter READ_FROM_CACHE_CTRL = 7'd26;
    parameter READ_END             = 7'd27;
    parameter TO_WRITE_SD          = 7'd28;
    parameter WRITE_SD             = 7'd29;
    parameter WRITE_SD_END         = 7'd30;
    parameter TO_WRITE_SD_BUFFER   = 7'd31;
    parameter WRITE_SD_BUFFER      = 7'd32;
    parameter WRITE_SD_BUFFER_END  = 7'd33;
    
    reg [6:0]current_state = INIT_START;
    reg [6:0]next_state = INIT_START;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            INIT_START:begin
                next_state <= INIT_SD_INIT;
            end 
            INIT_SD_INIT:begin
                if(init_ok)begin
                    next_state <= INIT_CODE_TO_DDR;
                end
                else begin
                    next_state <= INIT_SD_INIT;
                end
            end
            INIT_CODE_TO_DDR:begin
                next_state <= READ_FROM_SD_CODE;
            end
            READ_FROM_SD_CODE:begin
                if(read_ok)begin
                    next_state <= WRITE_TO_CTRL_CODE;
                end
                else begin
                    next_state <= READ_FROM_SD_CODE;
                end
            end
            WRITE_TO_CTRL_CODE:begin
                if(ddr_ctrl_read_sd_ok)begin
                    next_state <= WRITE_TO_DDR_CODE;
                end
                else begin
                    next_state <= WRITE_TO_CTRL_CODE;
                end
            end
            WRITE_TO_DDR_CODE:begin
                if(ddr_ctrl_write_buffer_ok)begin
                    next_state <= INIT_DATA_TO_DDR;
                end
                else begin
                    next_state <= WRITE_TO_DDR_CODE;
                end
            end
            INIT_DATA_TO_DDR:begin
                next_state <= READ_FROM_SD_DATA;
            end
            READ_FROM_SD_DATA:begin
                if(read_ok)begin
                    next_state <= WRITE_TO_CTRL_DATA;
                end
                else begin
                    next_state <= READ_FROM_SD_DATA;
                end
            end
            WRITE_TO_CTRL_DATA:begin
                if(ddr_ctrl_read_sd_ok)begin
                    next_state <= WRITE_TO_DDR_DATA;
                end
                else begin
                    next_state <= WRITE_TO_CTRL_DATA;
                end
            end
            WRITE_TO_DDR_DATA:begin
                if(ddr_ctrl_write_buffer_ok)begin
                    next_state <= INIT_DDR_END;
                end
                else begin
                    next_state <= WRITE_TO_DDR_DATA;c
                end
            end
            INIT_DDR_END:begin
                next_state <= INIT_CODE_TO_CACHE;
            end
            INIT_CODE_TO_CACHE:begin
                next_state <= READ_FROM_DDR_CODE;
            end
            READ_FROM_DDR_CODE:begin
                if(ddr_ctrl_read_buffer_ok)begin
                    next_state <= READ_FROM_CTRL_CODE;
                end
                else begin
                    next_state <= READ_FROM_DDR_CODE;
                end
            end
            READ_FROM_CTRL_CODE:begin
                if(ddr_ctrl_send_to_cache_ok)begin
                    next_state <= WRITE_TO_CTRL_CODE;
                end
                else  begin
                    next_state <= READ_FROM_CTRL_CODE;
                end
            end
            WRITE_TO_CTRL_CODE:begin
                next_state <= WRITE_TO_CACHE_CODE;
            end
            WRITE_TO_CACHE_CODE:begin
                if(cache_buffer_write_end)begin
                    next_state <= INIT_DATA_TO_CACHE;
                end
                else begin
                    next_state <= WRITE_TO_CACHE_CODE;
                end
            end
            INIT_DATA_TO_CACHE:begin
                next_state <= READ_FROM_DDR_DATA;
            end
            READ_FROM_DDR_DATA:begin
                if(ddr_ctrl_read_buffer_ok)begin
                    next_state <= READ_FROM_CTRL_DATA;
                end
                else begin
                    next_state <= READ_FROM_DDR_DATA;
                end
            end
            READ_FROM_CTRL_DATA:begin
                if(ddr_ctrl_send_to_cache_ok)begin
                    next_state <= WRITE_TO_CTRL_DATA;
                end
                else begin
                    next_state <= READ_FROM_CTRL_DATA;
                end
            end
            WRITE_TO_CTRL_DATA:begin
                next_state <= WRITE_TO_CACHE_DATA;
            end
            WRITE_TO_CACHE_DATA:begin
                if(cache_buffer_write_end)begin
                    next_state <= INIT_CACHE_END;
                end
                else begin
                    next_state <= WRITE_TO_CACHE_DATA;
                end
            end
            INIT_CACHE_END:begin
                next_state <= IDLE;
            end
            IDLE:begin
                if(cache_re)begin
                    next_state <= TO_READ;
                end
                else if(sd_buffer_we)begin
                    next_state <= TO_WRITE_SD_BUFFER;
                end
                else if(sd_we)begin
                    next_state <= TO_WRITE_SD;
                end
                else begin
                    next_state <= IDLE;
                end
            end
            TO_READ:begin
                next_state <= READ_FROM_CACHE;
            end
            READ_FROM_CACHE:begin
                next_state <= READ_FROM_CACHE_CTRL;
            end
            READ_FROM_CACHE_CTRL:begin
                next_state <= READ_END;
            end
            READ_END:begin
                next_state <= IDLE;
            end
            TO_WRITE_SD_BUFFER:begin
                next_state <= WRITE_SD_BUFFER;
            end
            WRITE_SD_BUFFER:begin
                if(sd_buffer_write_end)begin
                    next_state <= WRITE_SD_BUFFER_END;
                end
                else begin
                    next_state <= WRITE_SD_BUFFER;
                end
            end
            WRITE_SD_BUFFER_END:begin
                next_state <= IDLE;
            end
            TO_WRITE_SD:begin
                next_state <= WRITE_SD;
            end
            WRITE_SD:begin
                if(write_ok)begin
                    next_state <= WRITE_SD_END;
                end
                else begin
                    next_state <= WRITE_SD;
                end
            end
            WRITE_SD_END:begin
                next_state <= IDLE;
            end
            default:begin
                next_state <= INIT_START;
            end
        endcase
    end

    //sd控制器
    // reg [31:0]sd_ctrl_addr_read; 
    // reg [31:0]sd_ctrl_addr_write;
    // reg sd_ctrl_re;
    // reg sd_ctrl_we;
    always @(*) begin
        case (current_state)
            INIT_CODE_TO_DDR:begin
                sd_ctrl_addr_read <= 32'd0;
                sd_ctrl_addr_write <= sd_ctrl_addr_write;
                sd_ctrl_re <= 1'b0;
                sd_ctrl_we <= 1'b0;
            end 
            READ_FROM_SD_CODE:begin
                sd_ctrl_addr_read <= sd_ctrl_addr_read;
                sd_ctrl_addr_write <= sd_ctrl_addr_write;
                sd_ctrl_re <= 1'b1;
                sd_ctrl_we <= 1'b0;
            end
            INIT_DATA_TO_DDR:begin
                sd_ctrl_addr_read <= 32'd1;
                sd_ctrl_addr_write <= sd_ctrl_addr_write;
                sd_ctrl_re <= 1'b0;
                sd_ctrl_we <= 1'b0;
            end
            READ_FROM_SD_DATA:begin
                sd_ctrl_addr_read <= sd_ctrl_addr_read;
                sd_ctrl_addr_write <= sd_ctrl_addr_write;
                sd_ctrl_re <= 1'b1;
                sd_ctrl_we <= 1'b0;
            end
            TO_WRITE_SD:begin
                sd_ctrl_addr_read <= sd_ctrl_addr_read;
                sd_ctrl_addr_write <= 32'd1;
                sd_ctrl_re <= 1'b0;
                sd_ctrl_we <= 1'b0;
            end
            WRITE_SD:begin
                sd_ctrl_addr_read <= sd_ctrl_addr_read;
                sd_ctrl_addr_write <= sd_ctrl_addr_write;
                sd_ctrl_re <= 1'b0;
                sd_ctrl_we <= 1'b1;
            end
            default:begin
                sd_ctrl_addr_read <= sd_ctrl_addr_read;
                sd_ctrl_addr_write <= sd_ctrl_addr_write;
                sd_ctrl_re <= 1'b0;
                sd_ctrl_we <= 1'b0;
            end
        endcase
    end

    //sd buffer
    reg sd_buffer_write_we;
    always @(*) begin
        case (current_state)
            WRITE_SD_BUFFER:begin
                sd_buffer_write_we <= 1'b1;
            end 
            default:begin
                sd_buffer_write_we <= 1'b0;
            end 
        endcase
    end

    //ddr控制器
    // reg ddr_ctrl_read_from_sd;
    // reg ddr_ctrl_write_to_buffer;
    // reg ddr_ctrl_read_from_buffer;
    // reg ddr_ctrl_write_to_cache;
    always @(*) begin
        case (current_state)
            WRITE_TO_CTRL_CODE:begin
                ddr_ctrl_read_from_sd <= 1'b1;
                ddr_ctrl_write_to_buffer <= 1'b0;
                ddr_ctrl_read_from_buffer <= 1'b0;
                ddr_ctrl_write_to_cache <= 1'b0;
            end 
            WRITE_TO_DDR_CODE:begin
                ddr_ctrl_read_from_sd <= 1'b0;
                ddr_ctrl_write_to_buffer <= 1'b1;
                ddr_ctrl_read_from_buffer <= 1'b0;
                ddr_ctrl_write_to_cache <= 1'b0;
            end
            WRITE_TO_CTRL_DATA:begin
                ddr_ctrl_read_from_sd <= 1'b1;
                ddr_ctrl_write_to_buffer <= 1'b0;
                ddr_ctrl_read_from_buffer <= 1'b0;
                ddr_ctrl_write_to_cache <= 1'b0;
            end
            WRITE_TO_DDR_DATA:begin
                ddr_ctrl_read_from_sd <= 1'b0;
                ddr_ctrl_write_to_buffer <= 1'b1;
                ddr_ctrl_read_from_buffer <= 1'b0;
                ddr_ctrl_write_to_cache <= 1'b0;
            end
            READ_FROM_DDR_CODE:begin
                ddr_ctrl_read_from_sd <= 1'b0;
                ddr_ctrl_write_to_buffer <= 1'b0;
                ddr_ctrl_read_from_buffer <= 1'b1;
                ddr_ctrl_write_to_cache <= 1'b0;
            end
            READ_FROM_CTRL_CODE:begin
                ddr_ctrl_read_from_sd <= 1'b0;
                ddr_ctrl_write_to_buffer <= 1'b0;
                ddr_ctrl_read_from_buffer <= 1'b0;
                ddr_ctrl_write_to_cache <= 1'b1;
            end
            READ_FROM_DDR_DATA:begin
                ddr_ctrl_read_from_sd <= 1'b0;
                ddr_ctrl_write_to_buffer <= 1'b0;
                ddr_ctrl_read_from_buffer <= 1'b1;
                ddr_ctrl_write_to_cache <= 1'b0;
            end
            READ_FROM_CTRL_DATA:begin
                ddr_ctrl_read_from_sd <= 1'b0;
                ddr_ctrl_write_to_buffer <= 1'b0;
                ddr_ctrl_read_from_buffer <= 1'b0;
                ddr_ctrl_write_to_cache <= 1'b1;
            end
            default:begin
                ddr_ctrl_read_from_sd <= 1'b0;
                ddr_ctrl_write_to_buffer <= 1'b0;
                ddr_ctrl_read_from_buffer <= 1'b0;
                ddr_ctrl_write_to_cache <= 1'b0;
            end 
        endcase
    end

    //cache控制器
    // reg cache_ctrl_from_cache_re;
    // reg cache_ctrl_to_cache_we;
    // reg cache_ctrl_from_ddr_re;
    // reg cache_ctrl_to_cpu_we;
    always @(*) begin
        case (current_state)
            WRITE_TO_CTRL_CODE:begin
                cache_ctrl_from_cache_re <= 1'b0;
                cache_ctrl_to_cache_we <= 1'b0;
                cache_ctrl_from_ddr_re <= 1'b1;
                cache_ctrl_to_cpu_we <= 1'b0;
            end 
            WRITE_TO_CACHE_CODE:begin
                cache_ctrl_from_cache_re <= 1'b0;
                cache_ctrl_to_cache_we <= 1'b1;
                cache_ctrl_from_ddr_re <= 1'b0;
                cache_ctrl_to_cpu_we <= 1'b0;
            end
            WRITE_TO_CTRL_DATA:begin
                cache_ctrl_from_cache_re <= 1'b0;
                cache_ctrl_to_cache_we <= 1'b0;
                cache_ctrl_from_ddr_re <= 1'b1;
                cache_ctrl_to_cpu_we <= 1'b0;
            end
            WRITE_TO_CACHE_DATA:begin
                cache_ctrl_from_cache_re <= 1'b0;
                cache_ctrl_to_cache_we <= 1'b1;
                cache_ctrl_from_ddr_re <= 1'b0;
                cache_ctrl_to_cpu_we <= 1'b0;
            end
            READ_FROM_CACHE:begin
                cache_ctrl_from_cache_re <= 1'b1;
                cache_ctrl_to_cache_we <= 1'b0;
                cache_ctrl_from_ddr_re <= 1'b0;
                cache_ctrl_to_cpu_we <= 1'b0;
            end
            READ_FROM_CACHE_CTRL:begin
                cache_ctrl_from_cache_re <= 1'b0;
                cache_ctrl_to_cache_we <= 1'b0;
                cache_ctrl_from_ddr_re <= 1'b0;
                cache_ctrl_to_cpu_we <= 1'b1;
            end
            default:begin
                cache_ctrl_from_cache_re <= 1'b0;
                cache_ctrl_to_cache_we <= 1'b0;
                cache_ctrl_from_ddr_re <= 1'b0;
                cache_ctrl_to_cpu_we <= 1'b0;
            end 
        endcase
    end
endmodule