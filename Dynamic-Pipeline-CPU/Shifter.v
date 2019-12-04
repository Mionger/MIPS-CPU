module Shifter
(
    a, 
    b, 
    aluc, 
    r, 
    carry
);
    input [4:0]a;
    input signed [31:0]b;
    input [1:0] aluc;
    output reg [31:0]r;
    output reg carry;
	
 	always @(a or b or aluc[1])begin
 		if(a == 0) begin
            carry=1'bx;
        end else begin
            if(aluc[1]) begin
                carry=b[32-a];
     		end
     		else begin
                carry=b[a-1];
     		end
        end
 	end
 	
    always @(a or b or aluc) begin
        case(aluc)
            //算术右移
            2'b00: begin
                r = a[0]? {b[31], b[31:1]}: b;
                r = a[1]? {{2{r[31]}}, r[31:2]}: r;
                r = a[2]? {{4{r[31]}}, r[31:4]}: r;
                r = a[3]? {{8{r[31]}}, r[31:8]}: r;
                r = a[4]? {{16{r[31]}}, r[31:16]}: r;
            end 
            //逻辑右移
            2'b01: begin
                r = a[0]? {1'b0, b[31:1]}: b;
                r = a[1]? {2'b0, r[31:2]}: r;
                r = a[2]? {4'b0, r[31:4]}: r;
                r = a[3]? {8'b0, r[31:8]}: r;
                r = a[4]? {16'b0, r[31:16]}: r;
            end
            //左移
            default: begin
                r = a[0]? {b[30:0], 1'b0}: b;
                r = a[1]? {r[29:0], 2'b0}: r;
                r = a[2]? {r[27:0], 4'b0}: r;
                r = a[3]? {r[23:0], 8'b0}: r;
                r = a[4]? {r[15:0], 16'b0}: r;
            end
        endcase
    end
endmodule
