`timescale 1ns / 1ps
module Cache_Controller
(
    clk,
    reset,
    state,

    cpu_addr,
    cpu_data_read,
    cpu_re,
    cpu_read_end,

    cache_data_write,
    cache_data_read,
    cache_addr,
    cache_we,

    ddr_ctrl_addr,
    ddr_ctrl_re,
    ddr_ctrl_data_read,
    ddr_ctrl_read_end,

    cache_page,
    cache_write_buffer_end
);
    input clk;
    input reset;
    input [31:0]cpu_addr;
    input cpu_re;
    input [31:0]cache_data_read;
    input [4095:0]ddr_ctrl_data_read;
    input ddr_ctrl_read_end;
    input cache_write_buffer_end;

    output [3:0]state;
    output [31:0]cpu_data_read;
    output cpu_read_end;
    output [4095:0]cache_data_write;
    output [31:0]cache_addr;
    output cache_we;
    output [31:0]ddr_ctrl_addr;
    output ddr_ctrl_re;
    output [1:0]cache_page;

    assign cpu_data_read = cache_data_read;
    assign cache_data_write = ddr_ctrl_data_read;
    assign cache_addr = cpu_addr;
    assign ddr_ctrl_addr = cpu_addr;
    
    reg cpu_read_end;//
    reg cache_we;//
    reg ddr_ctrl_re;//
    reg [1:0]cache_page;//

    reg [31:0]in_cache_addr_0;
    reg [31:0]in_cache_addr_1;
    reg [31:0]in_cache_addr_2;
    reg [31:0]in_cache_addr_3;
    reg [1:0]in_cache_page_0;
    reg [1:0]in_cache_page_1;
    reg [1:0]in_cache_page_2;
    reg [1:0]in_cache_page_3;

    parameter IDLE = 4'd0;
    parameter CHECK = 4'd1;
    parameter GET_DATA = 4'd2;
    parameter GET_DATA_END = 4'd3;
    parameter TO_READ = 4'd4;
    parameter READ_END = 4'd5;
    parameter WRITE_CACHE = 4'd6;
    parameter WRITE_CACHE_END = 4'd7;

    reg [3:0]current_state = IDLE;
    reg [3:0]next_state = IDLE;
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
            IDLE: begin
                if(cpu_re)begin
                    next_state <= CHECK;
                end
                else begin
                    next_state <= IDLE;
                end
            end
            CHECK: begin
                if(addr[16:9] == in_cache_addr_0[16:9] || addr[16:9] == in_cache_addr_1[16:9] || addr[16:9] == in_cache_addr_2[16:9] || addr[16:9] == in_cache_addr_3[16:9])begin
                    next_state <= TO_READ;
                end
                else begin
                    next_state <= GET_DATA;
                end
            end
            GET_DATA: begin
                if(ddr_ctrl_read_end)begin
                    next_state <= GET_DATA_END;
                end
                else begin
                    next_state <= GET_DATA;
                end
            end
            GET_DATA_END: begin
                next_state <= WRITE_CACHE;
            end 
            WRITE_CACHE: begin
                if(cache_write_buffer_end)begin
                   next_state <= WRITE_CACHE_END; 
                end
                else begin
                    next_state <= WRITE_CACHE;
                end
            end
            WRITE_CACHE_END: begin
                next_state <= TO_READ;
            end
            TO_READ: begin
                next_state <= READ_END;
            end
            READ_END: begin
                next_state <= IDLE;
            end
            default: begin
                next_state <= IDLE;
            end
        endcase
    end

    always @(*) begin
        case (current_state)
            READ_END: begin
                cpu_read_end <= 1'b1;
            end 
            default: begin
                cpu_read_end <= 1'b0;
            end 
        endcase
    end

    always @(*) begin
        case (current_state)
            WRITE_CACHE: begin
                cache_we <= 1'b1;
            end 
            default: begin
                cache_we <= 1'b0;
            end 
        endcase
    end

    always @(*) begin
        case (current_state)
            GET_DATA: begin
                ddr_ctrl_re <= 1'b1;      
            end
            default: begin
                ddr_ctrl_re <= 1'b0;
            end
        endcase
    end

    always @(*) begin
        if(reset)begin
            in_cache_page_0 <= 2'd0;
            in_cache_page_1 <= 2'd1;
            in_cache_page_2 <= 2'd2;
            in_cache_page_3 <= 2'd3;
        end
        else begin
           case (current_state)
                CHECK: begin
                    if(addr[16:9] == in_cache_addr_0[16:9])begin
                        cache_page = in_cache_page_0;
                    end
                    else if(addr[16:9] == in_cache_addr_1[16:9])begin
                        cache_page = in_cache_page_1;
                    end
                    else if (addr[16:9] == in_cache_addr_2[16:9])begin
                        cache_page = in_cache_page_2;
                    end
                    else if(addr[16:9] == in_cache_addr_3[16:9])begin
                        cache_page = in_cache_page_3;
                    end
                    else begin
                        cache_page = in_cache_page_3;
                        in_cache_page_3 = in_cache_page_2;
                        in_cache_page_2 = in_cache_page_1;
                        in_cache_page_1 = in_cache_page_0;
                        in_cache_page_0 = cache_page;
                    end
                end
                default: begin
                    cache_page = cache_page;
                    in_cache_page_3 = in_cache_page_3;
                    in_cache_page_2 = in_cache_page_2;
                    in_cache_page_1 = in_cache_page_1;
                    in_cache_page_0 = in_cache_page_0;
                end
            endcase 
        end
    end

    always @(*) begin
        if(reset)begin
            in_cache_addr_0 = 32'hFFFFFFFF;
            in_cache_addr_1 = 32'hFFFFFFFF;
            in_cache_addr_2 = 32'hFFFFFFFF;
            in_cache_addr_3 = 32'hFFFFFFFF;
        end
        else begin
            case (current_state)
                CHECK: begin
                    if(!(addr[16:9] == in_cache_addr_0[16:9] || addr[16:9] == in_cache_addr_1[16:9] || addr[16:9] == in_cache_addr_2[16:9] || addr[16:9] == in_cache_addr_3[16:9]))begin
                        in_cache_addr_3 = in_cache_addr_2;
                        in_cache_addr_2 = in_cache_addr_1;
                        in_cache_addr_1 = in_cache_addr_0;
                        in_cache_addr_0 = {15'd0,addr[16:9],9'd0};
                    end      
                end
                default: begin
                    in_cache_addr_0 = in_cache_addr_0;
                    in_cache_addr_1 = in_cache_addr_1;
                    in_cache_addr_2 = in_cache_addr_2;
                    in_cache_addr_3 = in_cache_addr_3;
                end
            endcase
        end
    end
endmodule
