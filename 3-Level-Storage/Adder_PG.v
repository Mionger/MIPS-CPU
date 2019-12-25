`timescale 1ns / 1ps
module Adder_PG
(
    P,
    G,
    C,
    p,
    g,
    c
);
    input [3:0]P;
    input [3:0]G;
    input C;

    output p;
    output g;
    output [4:1]c;

    assign c[1]=G[0]|(P[0]&C);
    assign c[2]=G[1]|(P[1]&G[0])|(P[1]&P[0]&C);
    assign c[3]=G[2]|(P[2]&G[1])|(P[2]&P[1]&G[0])|(P[2]&P[1]&P[0]&C);
    assign c[4]=G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0])|(P[3]&P[2]&P[1]&P[0]&C);

    assign p=P[3]&P[2]&P[1]&P[0];
    assign g=G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0]);

endmodule
