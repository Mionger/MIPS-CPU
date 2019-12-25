`timescale 1ns / 1ps
module Adder_16bits
(
    A,
    B,
    C,
    S,
    P,
    G
);

    input [15:0]A;
    input [15:0]B;
    input C;

    output [15:0]S;
    output P;
    output G;

    wire [3:0]p;
    wire [3:0]g;
    wire [4:1]c;

    Adder_4bits adder0(A[3:0],  B[3:0],  C,   S[3:0],  p[0],g[0]);
    Adder_4bits adder1(A[7:4],  B[7:4],  c[1],S[7:4],  p[1],g[1]);
    Adder_4bits adder2(A[11:8], B[11:8], c[2],S[11:8], p[2],g[2]);
    Adder_4bits adder3(A[15:12],B[15:12],c[3],S[15:12],p[3],g[3]);

    Adder_PG pg(p,g,C,P,G,c);
    
endmodule
