module Logicer
(
    A,
    B,
    ALUC,
    RESULT
);

    input [31:0]A;
    input [31:0]B;
    input [1:0]ALUC;

    output [31:0]RESULT;

    reg [31:0]RESULT;

    always@(A or B or ALUC) begin
        case(ALUC)
            2'b00:RESULT = A & B;
            2'b01:RESULT = A | B;
            2'b11:RESULT = ~(A | B);
            default:RESULT = A ^ B;
        endcase
    end

endmodule
