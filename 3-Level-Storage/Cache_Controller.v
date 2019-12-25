`timescale 1ns / 1ps
module Cache_Controller
(
    clk,
    reste,

    cache_ctrl_from_cache_re,
    cache_ctrl_to_cache_we,
    cache_ctrl_from_ddr_re,
    cache_ctrl_to_cpu_we,

    cache_ctrl_addr_from_cpu,
    cache_ctrl_addr_to_cache,//页号
    cache_ctrl_addr_to_ddr,

    cache_ctrl_data_from_ddr,
    cache_ctrl_data_from_cache,
    cache_ctrl_data_to_cache,
    cache_ctrl_data_to_cpu,

    cache_buffer_we,
    cache_buffer_write_end,

    state
);
    input clk;
    input reset;
    input cache_ctrl_from_cache_re;
    input cache_ctrl_to_cache_we;
    input cache_ctrl_from_ddr_re;
    input cache_ctrl_to_cpu_we;
    input [31:0]cache_ctrl_addr_from_cpu;
    input [4095:0]cache_ctrl_data_from_ddr;
    input [31:0]cache_ctrl_data_from_cache;
    input cache_buffer_write_end;

    output [31:0]cache_ctrl_addr_to_cache;
    output [31:0]cache_ctrl_addr_to_ddr;
    output [4095:0]cache_ctrl_data_to_cache;
    output [31:0]cache_ctrl_data_to_cpu;

    output cache_buffer_we;

    output [4:0]state;

    reg cache_buffer_we;
    // reg [4095:0]cache_ctrl_data_to_cache;
    // reg [31:0]cache_ctrl_data_to_cpu;

    reg [4095:0]temp_data_1 = 4096'd0;
    reg [31:0]temp_data_2   = 32'd0;
    assign cache_ctrl_data_to_cache = temp_data_1;
    assign cache_ctrl_data_to_cpu = temp_data_2;

    assign cache_ctrl_addr_to_ddr = cache_ctrl_addr_from_cpu;
    assign cache_ctrl_addr_to_cache = cache_ctrl_addr_from_cpu;

    parameter IDLE                = 5'd1;
    parameter READ_FROM_DDR       = 5'd2;
    parameter READ_FROM_DDR_END   = 5'd3;
    parameter WRITE_TO_CACHE      = 5'd4;
    parameter WRITE_TO_CACHE_END  = 5'd5;
    parameter READ_FROM_CACHE     = 5'd6;
    parameter READ_FROM_CACHE_END = 5'd7;
    parameter WRITE_TO_CPU        = 5'd8;
    parameter WRITE_TO_CPU_END    = 5'd9;

    reg [4:0]current_state = IDLE;
    reg [4:0]next_state = IDLE;
    assign state = current_state;
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
            IDLE:begin
                if(cache_ctrl_from_ddr_re)begin
                    next_state <= READ_FROM_DDR;
                end
                else if(cache_ctrl_to_cache_we)begin
                    next_state <= WRITE_TO_CACHE;
                end
                else if(cache_ctrl_from_cache_re)begin
                    next_state <= READ_FROM_CACHE;             
                end
                else if(cache_ctrl_to_cpu_we)begin
                    next_state <= WRITE_TO_CPU;
                end
                else begin
                    next_state <= IDLE;
                end
            end
            READ_FROM_DDR:begin
                next_state <= READ_FROM_DDR_END;
            end
            READ_FROM_DDR_END:begin
                next_state <= IDLE;
            end
            WRITE_TO_CACHE:begin
                if(cache_buffer_write_end)begin
                    next_state <= WRITE_TO_CACHE_END;
                end
                else begin
                    next_state <= WRITE_TO_CACHE;
                end
            end
            WRITE_TO_CACHE_END:begin
                next_state <= IDLE;
            end
            READ_FROM_DDR:begin
                next_state <= READ_FROM_CACHE_END;
            end
            READ_FROM_CACHE_END:begin
                next_state <= IDLE;
            end
            WRITE_TO_CPU:begin
                next_state <= WRITE_TO_CPU_END;
            end
            WRITE_TO_CPU_END:begin
                next_state <= IDLE;
            end
            default:begin
                next_state <= IDLE;
            end 
        endcase
    end

    //数据变化
    // reg [4095:0]temp_data_1 = 4096'd0;
    // reg [31:0]temp_data_2   = 32'd0;
    always @(*) begin
        case (current_state)
            READ_FROM_DDR:begin
                temp_data_1 <= cache_ctrl_data_from_ddr;
                temp_data_2 <= temp_data_2;
            end 
            READ_FROM_CACHE:begin
                temp_data_1 <= temp_data_1;
                temp_data_2 <= cache_ctrl_data_from_cache;
            end
            default:begin
                temp_data_1 <= temp_data_1;
                temp_data_2 <= temp_data_2;
            end 
        endcase
    end

    // reg cache_buffer_we;
    always @(*) begin
        case (current_state)
            WRITE_TO_CACHE:begin
                cache_buffer_we <= 1'b1;
            end 
            default:begin
                cache_buffer_we <= 1'b0;
            end
        endcase
    end
endmodule