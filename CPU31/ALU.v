module ALU
(
    A,
    B,
    ALUC,
    RESULT,
    ZERO,
    CARRY,
    NEGATIVE,
    OVERFLOW
);

    input [31:0]A;
    input [31:0]B;
    input [3:0]ALUC;

    output [31:0]RESULT;
    output ZERO;
    output CARRY;
    output NEGATIVE;
    output OVERFLOW;

    reg [31:0]RESULT;
    reg CARRY;
    reg OVERFLOW;

    wire [31:0]result_add_sub;
    wire [31:0]result_logic;
    wire [31:0]result_shift;
    wire [31:0]result_lui_slt;
    wire carry_add_sub;
    wire carry_shift;
    wire overflow_add_sub;
    wire equal_lui_slt;
    wire small_lui_slt;

    Adder   adder(A,B,ALUC[0],result_add_sub,carry_add_sub,overflow_add_sub);
    Logicer logicer(A,B,ALUC[1:0],result_logic);
    Shifter shifter(A[4:0],B,ALUC[1:0],result_shift,carry_shift);
    Other   other(A,B,ALUC[1:0],result_lui_slt,equal_lui_slt,small_lui_slt);

    parameter ADD_SUB         = 2'b00;
    parameter AND_OR_XOR_NOR  = 2'b01;
    parameter LUI_SLT         = 2'b10;
    parameter SRA_SRL_SLA_SLL = 2'b11;
    always @(*) begin
        case (ALUC[3:2])
            ADD_SUB:         RESULT=result_add_sub;
            AND_OR_XOR_NOR:  RESULT=result_logic;
            SRA_SRL_SLA_SLL: RESULT=result_shift;
            default:         RESULT=result_lui_slt;
        endcase
    end

    //set zero flag
    reg zero;
    always @(RESULT) begin
        if (RESULT==0) zero=1;
        else           zero=0;
    end
    assign ZERO =   ALUC[3]  & (~ALUC[2]) & ALUC[1] & equal_lui_slt 
			    | (~ALUC[3]) & zero 
			    |   ALUC[2]  & zero
			    | (~ALUC[1]) & zero;

    //set carry flag
    wire carry_valid_1;
	wire carry_valid_2;
	wire carry_valid_3;
	wire carry_valid;
	wire carry_value;

	assign carry_valid_1 = (~ALUC[3]) & (~ALUC[2]) & (~ALUC[1]);
	assign carry_valid_2 = ALUC[3] & (~ALUC[2]) & ALUC[1] & (~ALUC[0]);
	assign carry_valid_3 = ALUC[3] & ALUC[2];
	assign carry_valid = carry_valid_1 | carry_valid_2 | carry_valid_3;
	assign carry_value = (carry_valid_1 & carry_add_sub) | (carry_valid_2 & small_lui_slt) | (carry_valid_3 & carry_shift);
	always @(*) begin
		if(carry_valid) CARRY = carry_value;
		else            CARRY = CARRY;
	end

    //set negative flag
	assign NEGATIVE =   (ALUC[3]  & (~ALUC[2]) & ALUC[1] & ALUC[0] & small_lui_slt)
				    |  (~ALUC[3]  & RESULT[31]) 
                    |   (ALUC[2]  & RESULT[31])
				    | ((~ALUC[1]) & RESULT[31]) 
                    | ((~ALUC[0]) & RESULT[31]);

    //set overflow flag
	wire overflow_valid;
	assign overflow_valid = (~ALUC[3]) & (~ALUC[2]) & ALUC[1];
	always @(*) begin
		if(overflow_valid) OVERFLOW = overflow_add_sub;
		else               OVERFLOW = OVERFLOW;
	end

endmodule
