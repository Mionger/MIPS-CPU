`timescale 1ns / 1ps
module DDR_Write_Buffer
(
    input clk,
    input reset,
    input [15:0]data,
    input [2:0]addr,
    input we,
    output reg [127:0]buffer
);
    always @(negedge clk or posedge reset) begin
        if(reset) begin
            buffer <= 4096'd0;
        end else begin
            if(we) begin
                case(addr)
                    3'b000: buffer[15:0] <= data; 
                    3'b001: buffer[31:16] <= data; 
                    3'b010: buffer[47:32] <= data; 
                    3'b011: buffer[63:48] <= data; 
                    3'b100: buffer[79:64] <= data; 
                    3'b101: buffer[95:80] <= data; 
                    3'b110: buffer[111:96] <= data; 
                    3'b111: buffer[127:112] <= data; 
                endcase
            end 
        end
    end
endmodule
