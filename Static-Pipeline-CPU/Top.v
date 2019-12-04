module Top
(
	clk_100,
	reset,
	INST,
	PC
); 

	input clk_100;
	input reset;
	output [31:0]INST;
	output [31:0]PC;
	
	wire clk_cpu;
	assign clk_cpu = clk_100;

	wire [31:0]pc;
	wire [31:0]inst;
	wire [31:0]addr;
	wire [31:0]wdata;
	wire we;
	wire [31:0]rdata;
	assign INST = inst;
	assign PC   = pc;
	
   	CPU cpu
	(
	    .clock(clk_cpu),
	    .reset(reset),
	    .instruction(inst),
	    .read_data(rdata),
	    .PC(pc),
	    .DMEM_address(addr),
	    .write_data(wdata),
	    .DMEM_WRITE(we)
	);

   	wire [31:0]actual_pc = pc - 32'h00400000;
	imem myimem(actual_pc[12:2], inst);

	wire [31:0]actual_dmem_addr = addr - 32'h10010000;
	wire DMEM_we;
	wire [31:0]DMEM_out;
	dmem mydmem(actual_dmem_addr[10:0], wdata, ~clk_100, DMEM_we, DMEM_out);

	WriteSelect writeselect
	(
		.addr(addr),
		.we(we),
		.DMEM_we(DMEM_we)
	);

	ReadSelect readselect
	(
        .addr(addr),
        .dmem(DMEM_out),
        .rdata(rdata)
    );
endmodule