`timescale 1ns / 1ps
module Shifter
(
    A,
    B,
    ALUC,
    RESULT,
    CF
);

    input [4:0]A;
    input [31:0]B;
    input [1:0]ALUC;

    output [31:0]RESULT;
    output CF;

    reg [31:0]RESULT;
    reg CF;

    always@(A or B or ALUC[1]) begin
        if(A==5'b00000)  CF=1'bx;
        else if(ALUC[1]) CF=B[32-A];
        else             CF=B[A-1];
    end

    parameter SRA = 2'b00;
    parameter SRL = 2'b01;
    always@(A or B or ALUC) begin
        case (ALUC)
            SRA:begin
                RESULT= A[0] ? {         B[31],       B[31: 1]}:      B;
                RESULT= A[1] ? {{ 2{RESULT[31]}},RESULT[31: 2]}: RESULT;
                RESULT= A[2] ? {{ 4{RESULT[31]}},RESULT[31: 4]}: RESULT;
                RESULT= A[3] ? {{ 8{RESULT[31]}},RESULT[31: 8]}: RESULT;
                RESULT= A[4] ? {{16{RESULT[31]}},RESULT[31:16]}: RESULT;
            end
            SRL:begin
                RESULT= A[0] ? { 1'b0,       B[31: 1]}:      B;
                RESULT= A[1] ? { 2'b0,  RESULT[31: 2]}: RESULT;
                RESULT= A[2] ? { 4'b0,  RESULT[31: 4]}: RESULT;
                RESULT= A[3] ? { 8'b0,  RESULT[31: 8]}: RESULT;
                RESULT= A[4] ? {16'b0,  RESULT[31:16]}: RESULT;
            end
            default:begin
                RESULT= A[0] ? {     B[30: 0], 1'b0}:      B;
                RESULT= A[1] ? {RESULT[29: 0], 2'b0}: RESULT;
                RESULT= A[2] ? {RESULT[27: 0], 4'b0}: RESULT;
                RESULT= A[3] ? {RESULT[23: 0], 8'b0}: RESULT;
                RESULT= A[4] ? {RESULT[15: 0],16'b0}: RESULT;
            end 
        endcase
    end
endmodule
