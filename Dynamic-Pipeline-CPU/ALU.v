module ALU
(
	a, 
	b, 
	aluc, 
	result, 
	zero, 
	carry, 
	negative, 
	overflow
);
	input [31:0]a;
	input [31:0]b;
	input [3:0]aluc;
	output reg [31:0]result; 
	output zero;
	output reg carry;
	output negative;
	output reg overflow;

	//aluc[3:2]为00对应加减法
	wire [31:0]result_00;
	wire carry_00;
	wire overflow_00;
	AddSub addsub(a, b, aluc[0], result_00, carry_00, overflow_00);

	//aluc[3:2]为01对应与、或、异或、非或操作
	wire [31:0]result_01;
	LogicArithmetic logicarithmetic(a, b, aluc[1:0], result_01);

	//aluc[3:2]为10对应Lui及Slt操作
	wire [31:0]result_10;
	wire is_equal;
	wire is_smaller;
	LuiSlt luislt(a, b, aluc[1:0], result_10, is_equal, is_smaller);

	//aluc[3:2]为11对应移位操作
	wire [31:0]result_11;
	wire carry_11;
	Shifter shifter(a[4:0], b, aluc[1:0], result_11, carry_11);

	//result最终输出
	always @(*) begin
		case(aluc[3:2])
			2'b00: begin
				result = result_00;
			end
			2'b01: begin
				result = result_01;
			end
			2'b10: begin
				result = result_10;
			end
			default: begin
				result = result_11;
			end
		endcase
	end

	//zero最终输出
	reg is_zero;
	always @(result) begin
		if(result == 0)begin
			is_zero=1;
		end
		else begin
			is_zero=0;
		end
	end

	assign zero = aluc[3] & (~aluc[2]) & aluc[1] & is_equal 
			    | (~aluc[3]) & is_zero 
			    | aluc[2] & is_zero
			    | (~aluc[1]) & is_zero;

	//carry最终输出
	wire carry_valid_1;
	wire carry_valid_2;
	wire carry_valid_3;
	wire carry_valid;
	wire carry_value;

	assign carry_valid_1 = (~aluc[3]) & (~aluc[2]) & (~aluc[1]);
	assign carry_valid_2 = aluc[3] & (~aluc[2]) & aluc[1] & (~aluc[0]);
	assign carry_valid_3 = aluc[3] & aluc[2];
	assign carry_valid = carry_valid_1 | carry_valid_2 | carry_valid_3;
	assign carry_value = (carry_valid_1 & carry_00) | (carry_valid_2 & is_smaller) | (carry_valid_3 & carry_11);
	always @(*) begin
		if(carry_valid) begin
			carry = carry_value;
		end else begin
			carry = carry;
		end
	end

	//negative最终输出
	assign negative = (aluc[3] & (~aluc[2]) & aluc[1] & aluc[0] & is_smaller)
				    | (~aluc[3] & result[31]) | (aluc[2] & result[31])
				    | ((~aluc[1]) & result[31]) | ((~aluc[0]) & result[31]);

	//overflow最终输出
	wire overflow_valid;
	assign overflow_valid = (~aluc[3]) & (~aluc[2]) & aluc[1];
	always @(*) begin
		if(overflow_valid) begin
			overflow = overflow_00;
		end
		 else begin
		 	overflow = overflow;
		 end
	end
endmodule