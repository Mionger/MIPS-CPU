`timescale 1ns / 1ps
module Adder_64bits
(
    A,
    B,
    iC,
    S,
    oC
);

    input [63:0]A;
    input [63:0]B;
    input iC;
    
    output [63:0]S;
    output oC;

    wire [3:0]p;
    wire [3:0]g;
    wire [4:1]c;
    wire op;
    wire og;

    Adder_16bits adder0(A[15: 0],B[15: 0],iC  ,S[15: 0],p[0],g[0]);
    Adder_16bits adder1(A[31:16],B[31:16],c[1],S[31:16],p[1],g[1]);
    Adder_16bits adder2(A[47:32],B[47:32],c[2],S[47:32],p[2],g[2]);
    Adder_16bits adder3(A[63:48],B[63:48],c[3],S[63:48],p[3],g[3]);

    Adder_PG adder_pg(p,g,iC,op,og,c);

    assign oC=c[4];

endmodule