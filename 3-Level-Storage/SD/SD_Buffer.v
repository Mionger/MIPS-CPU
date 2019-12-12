`timescale 1ns / 1ps
module SD_Buffer
(
    clk,
    reset,
    addr,
    sd_buffer_we,
    sd_buffer_data_in,
    sd_buffer_data_out,
    sd_buffer_write_end,
    state
);
    input clk;
    input reset;
    input [6:0]addr;
    input sd_buffer_we;
    input [31:0]sd_buffer_data_in;
    
    output sd_buffer_write_end;
    output [4095:0]sd_buffer_data_out;
    output [3:0]state;

    reg [4095:0]sd_buffer_data_out = 4096'd0;
    reg sd_buffer_write_end;

    parameter IDLE = 4'd0;
    parameter PREPARE_DATA = 4'd1;
    parameter WRITE_END = 4'd2;

    reg [3:0]current_state = IDLE;
    reg [3:0]next_state = IDLE;
    assign state = current_state;
    always @(posedge clk or posedge reset) begin
        if(reset)begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE:begin
                if (sd_buffer_we) begin
                    next_state <= PREPARE_DATA;
                end
                else begin
                    next_state <= IDLE;
                end
            end 
            PREPARE_DATA:begin
                next_state <= WRITE_END;
            end
            WRITE_END:begin
                next_state <= IDLE;
            end
            default:begin
                next_state <= IDLE;
            end
        endcase
    end

    always @(*) begin
        case (current_state)
            PREPARE_DATA:begin
                sd_buffer_data_out[{addr, 5'd31}] <= sd_buffer_data_in[0];
				sd_buffer_data_out[{addr, 5'd30}] <= sd_buffer_data_in[1];
				sd_buffer_data_out[{addr, 5'd29}] <= sd_buffer_data_in[2];
				sd_buffer_data_out[{addr, 5'd28}] <= sd_buffer_data_in[3];
			    sd_buffer_data_out[{addr, 5'd27}] <= sd_buffer_data_in[4];
				sd_buffer_data_out[{addr, 5'd26}] <= sd_buffer_data_in[5];
				sd_buffer_data_out[{addr, 5'd25}] <= sd_buffer_data_in[6];
				sd_buffer_data_out[{addr, 5'd24}] <= sd_buffer_data_in[7];
			    sd_buffer_data_out[{addr, 5'd23}] <= sd_buffer_data_in[8];
				sd_buffer_data_out[{addr, 5'd22}] <= sd_buffer_data_in[9];
				sd_buffer_data_out[{addr, 5'd21}] <= sd_buffer_data_in[10];
				sd_buffer_data_out[{addr, 5'd20}] <= sd_buffer_data_in[11];
				sd_buffer_data_out[{addr, 5'd19}] <= sd_buffer_data_in[12];
				sd_buffer_data_out[{addr, 5'd18}] <= sd_buffer_data_in[13];
				sd_buffer_data_out[{addr, 5'd17}] <= sd_buffer_data_in[14];
				sd_buffer_data_out[{addr, 5'd16}] <= sd_buffer_data_in[15];
				sd_buffer_data_out[{addr, 5'd15}] <= sd_buffer_data_in[16];
				sd_buffer_data_out[{addr, 5'd14}] <= sd_buffer_data_in[17];
				sd_buffer_data_out[{addr, 5'd13}] <= sd_buffer_data_in[18];
				sd_buffer_data_out[{addr, 5'd12}] <= sd_buffer_data_in[19];
				sd_buffer_data_out[{addr, 5'd11}] <= sd_buffer_data_in[20];
				sd_buffer_data_out[{addr, 5'd10}] <= sd_buffer_data_in[21];
				sd_buffer_data_out[{addr, 5'd9}] <= sd_buffer_data_in[22];
				sd_buffer_data_out[{addr, 5'd8}] <= sd_buffer_data_in[23];
				sd_buffer_data_out[{addr, 5'd7}] <= sd_buffer_data_in[24];
				sd_buffer_data_out[{addr, 5'd6}] <= sd_buffer_data_in[25];
				sd_buffer_data_out[{addr, 5'd5}] <= sd_buffer_data_in[26];
				sd_buffer_data_out[{addr, 5'd4}] <= sd_buffer_data_in[27];
				sd_buffer_data_out[{addr, 5'd3}] <= sd_buffer_data_in[28];
				sd_buffer_data_out[{addr, 5'd2}] <= sd_buffer_data_in[29];
				sd_buffer_data_out[{addr, 5'd1}] <= sd_buffer_data_in[30];
				sd_buffer_data_out[{addr, 5'd0}] <= sd_buffer_data_in[31];
            end 
            default: begin
                sd_buffer_data_out <= sd_buffer_data_out;
            end
        endcase
    end

    always @(*) begin
        case (current_state)
            WRITE_END:begin
                sd_buffer_write_end <= 1'b1;
            end
            default:begin
                sd_buffer_write_end <= 1'b0;
            end 
        endcase
    end

endmodule