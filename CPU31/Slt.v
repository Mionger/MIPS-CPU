module Slt
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
    input ALUC;

    output [31:0]RESULT;
    output EQUAL;
    output SMALL;

    reg [2:0]result;

    parameter BIG = 3'b100;
    parameter EQU = 3'b010;
    parameter SMA = 3'b001;

    always@(A or B)begin
        if (A>B)     result=BIG;
        else if(A<B) result=SMA;
        else         result=EQU;
    end

    assign RESULT[0]=   (    (~ALUC)&result[0]) 
                        |    (ALUC&A[31]&(~B[31])&1) 
                        |    (ALUC&A[31]&B[31]&result[0])
				        |    (ALUC&(~A[31])&B[31]&0) 
				        |    (ALUC&(~A[31])&(~B[31])&result[0]
                        );
	

	assign RESULT[31:1]=0;
    assign EQUAL=result[1];
    assign SMALL=RESULT[0];

endmodule
