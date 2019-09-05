`timescale 1ns / 1ps
module top
(
    clk_in,
    reset,
    inst,
    pc,
    current_state,
    next_state    
);
    input clk_in;
    input reset;

    output [31:0]inst;
    output [31:0]pc;
    output [3:0]current_state;
    output [3:0]next_state;

    reg [31:0]pc;

    wire [31:0]dmem_data_out;
    wire [31:0]dmem_data_in;
    wire [31:0]dmem_addr_real;
    wire [31:0]dmem_addr;
    wire dmem_cs;
    wire dmem_w;
    wire dmem_r;
    dmem mydmem
    (
        .clk(~clk_in),
        .we(dmem_w),
        .addr(dmem_addr_real[10:0]),
        .wdata(dmem_data_in),
        .data_out(dmem_data_out)
    );
    assign dmem_addr_real = dmem_addr - 32'h10010000;

    wire [31:0]pc_real;
    imem myimem
    (
        .a(pc_real[12:2]),
        .spo(inst)
    );
    assign pc_real = pc - 32'h00400000;

    wire[31:0]pc_out;

    cpu sccpu
    (
        clk_in,
        reset,
        inst,
        pc_out,
        dmem_addr,
        dmem_data_out,
        dmem_data_in,
        dmem_w,
        current_state,
        next_state
    );

    always @(posedge clk_in or posedge reset) begin
        if(reset) begin
            pc <= 32'h00400000;
        end
        else if(next_state == 4'b0001) begin
            pc <= pc_out;
        end
        else begin
            pc <= pc;
        end
    end

endmodule