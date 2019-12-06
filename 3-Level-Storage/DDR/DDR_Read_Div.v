`timescale 1ns / 1ps
module DDR_Read_Div
(
    input [127:0]data_in,
    input [2:0]addr,
    output reg [15:0]data_out
);
    always @(*) begin
        case(addr)
            3'b000: data_out = data_in[15:0];
            3'b001: data_out = data_in[31:16];
            3'b010: data_out = data_in[47:32];
            3'b011: data_out = data_in[63:48];
            3'b100: data_out = data_in[79:64];
            3'b101: data_out = data_in[95:80];
            3'b110: data_out = data_in[111:96];
            3'b111: data_out = data_in[127:112];
        endcase
    end
endmodule
