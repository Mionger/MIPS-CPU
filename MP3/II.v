`timescale 1ns / 1ps
module II
(
    A,
    B,
    RESULT
);
    input [3:0]A;
    input [25:0]B;

    output [31:0]RESULT; 

    assign RESULT = {A, B,2'b00};
endmodule

module II8
(
    A,
    B,
    RESULT
);
    input [23:0]A;
    input [7:0]B;

    output [31:0]RESULT; 

    assign RESULT = {A, B};
endmodule

module II16
(
    A,
    B,
    RESULT
);
    input [15:0]A;
    input [15:0]B;

    output [31:0]RESULT; 

    assign RESULT = {A, B};
endmodule