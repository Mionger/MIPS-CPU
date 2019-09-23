`timescale 1ns / 1ps
module Adder
(
    A,
    B,
    ALUC,
    S,
    CF,
    OF
);

    input [31:0]A;
    input [31:0]B;
    input ALUC;

    output [31:0]S;
    output CF;
    output OF;

    wire [31:0]B_;
    wire iC;
    wire oC;

    Adder_invert invert(B,ALUC,B_);
    assign iC=ALUC?1:0;

    Adder_32bits adder(A,B_,iC,S,oC);

    assign CF=(ALUC&(~oC))|((~ALUC)&oC);
    assign OF=(A[31]&B_[31]&(~S[31]))|((~A[31])&(~B_[31])&S[31]);

endmodule
