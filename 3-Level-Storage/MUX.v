`timescale 1ns / 1ps
module MUX #(parameter WIDTH = 32)
(
    iC0,
    iC1,
    iC2,
    iC3,
    iS1,
    iS0,
    oZ
);
    input [WIDTH - 1:0] iC0;
    input [WIDTH - 1:0] iC1;
    input [WIDTH - 1:0] iC2;
    input [WIDTH - 1:0] iC3;
    input iS1;
    input iS0;

    output [WIDTH - 1:0] oZ;

    reg [WIDTH - 1:0] oZ;

    always @ (*)begin
        casex ({iS1,iS0})
            2'b00: oZ=iC0;
            2'b01: oZ=iC1;
            2'b10: oZ=iC2;
            2'b11: oZ=iC3;
        endcase
    end
endmodule
