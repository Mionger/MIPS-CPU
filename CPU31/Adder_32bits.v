module Adder_32bits
(
    A,
    B,
    iC,
    S,
    oC
);

    input [31:0]A;
    input [31:0]B;
    input iC;

    output [31:0]S;
    output oC;

    wire [1:0]p;
    wire [1:0]g;
    wire c;

    Adder_16bits adder0(A[15:0],  B[15:0],  iC, S[15:0],  p[0],g[0]);
    Adder_16bits adder1(A[31:16], B[31:16], c,  S[31:16], p[1],g[1]);

    assign c=g[0]|(p[0]&iC);
    assign oC=g[1]|(p[1]&g[0])|(p[1]&p[0]&iC);

endmodule
