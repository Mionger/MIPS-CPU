module Adder_4bits
(
    A,
    B,
    C,
    S,
    P,
    G
);

    input [3:0]A;
    input [3:0]B;
    input C;

    output [3:0]S;
    output P;
    output G;

    wire [3:0]p;
    wire [3:0]g;
    wire [4:1]c;

    FA FA0(A[0],B[0],C,S[0],p[0],g[0]);
    FA FA1(A[1],B[1],c[1],S[1],p[1],g[1]);
    FA FA2(A[2],B[2],c[2],S[2],p[2],g[2]);
    FA FA3(A[3],B[3],c[3],S[3],p[3],g[3]);

    Adder_PG pg(p,g,C,P,G,c);
    
endmodule
