module Other
(
    A,
    B,
    ALUC,
    RESULT,
    EQUAL,
    SMALL
);

    input [31:0]A;
    input [31:0]B;
    input [1:0]ALUC;

    output [31:0]RESULT;
    output EQUAL;
    output SMALL;

    reg [31:0]RESULT;

    wire [31:0]result_lui;
    wire [31:0]result_slt;

    Lui lui(B,result_lui);
    Slt slt(A,B,ALUC[0],result_slt,EQUAL,SMALL);

    always @(ALUC or result_lui or result_slt) begin
        if(ALUC[1]) RESULT=result_slt;
        else        RESULT=result_lui; 
    end

endmodule


                
