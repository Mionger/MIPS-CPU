module Lui
(
    B,
    R
);

    input [31:0]B;

    output [31:0]R;

    assign R = { B[15:0] , 16'b0 };
    
endmodule
