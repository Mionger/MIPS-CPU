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