module Extend #(parameter WIDTH = 16)
(
    A,
    B,
    SIGN
);
    input [WIDTH - 1:0]A;
    input SIGN;

    output [31:0]B;

    assign B = SIGN? {{(32-WIDTH){A[WIDTH - 1]}},A} : {{(32-WIDTH){1'b0}},A};
endmodule
