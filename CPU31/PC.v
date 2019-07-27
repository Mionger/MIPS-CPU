module PC
(
    CLK, 
    RST, 
    ENA, 
    DATA_IN, 
    DATA_OUT
);

	input CLK;
	input RST;
	input ENA;
	input [31:0]DATA_IN;
	
    output [31:0] DATA_OUT;
	
    reg [31:0] DATA_OUT;

	// initial begin
	// 	DATA_OUT = 32'h00400000;
	// end

	always @(negedge CLK or posedge RST) begin
		if(RST) begin
			DATA_OUT <= 32'h00400000;
		end else begin
			if(ENA) begin
				DATA_OUT <= DATA_IN;
			end else begin
				DATA_OUT <= DATA_OUT;
			end
		end
	end
    
endmodule
