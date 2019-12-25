`timescale 1ns / 1ps
module Adder_invert
(
    SOURCE,
    CS,
    INVERT
);

    input [31:0]SOURCE;
    input CS;

    output [31:0]INVERT;

    assign INVERT[0]=CS^SOURCE[0];
    assign INVERT[1]=CS^SOURCE[1];
    assign INVERT[2]=CS^SOURCE[2];
    assign INVERT[3]=CS^SOURCE[3];
    assign INVERT[4]=CS^SOURCE[4];
    assign INVERT[5]=CS^SOURCE[5];
    assign INVERT[6]=CS^SOURCE[6];
    assign INVERT[7]=CS^SOURCE[7];
    assign INVERT[8]=CS^SOURCE[8];
    assign INVERT[9]=CS^SOURCE[9];
    assign INVERT[10]=CS^SOURCE[10];
    assign INVERT[11]=CS^SOURCE[11];
    assign INVERT[12]=CS^SOURCE[12];
    assign INVERT[13]=CS^SOURCE[13];
    assign INVERT[14]=CS^SOURCE[14];
    assign INVERT[15]=CS^SOURCE[15];
    assign INVERT[16]=CS^SOURCE[16];
    assign INVERT[17]=CS^SOURCE[17];
    assign INVERT[18]=CS^SOURCE[18];
    assign INVERT[19]=CS^SOURCE[19];
    assign INVERT[20]=CS^SOURCE[20];
    assign INVERT[21]=CS^SOURCE[21];
    assign INVERT[22]=CS^SOURCE[22];
    assign INVERT[23]=CS^SOURCE[23];
    assign INVERT[24]=CS^SOURCE[24];
    assign INVERT[25]=CS^SOURCE[25];
    assign INVERT[26]=CS^SOURCE[26];
    assign INVERT[27]=CS^SOURCE[27];
    assign INVERT[28]=CS^SOURCE[28];
    assign INVERT[29]=CS^SOURCE[29];
    assign INVERT[30]=CS^SOURCE[30];
    assign INVERT[31]=CS^SOURCE[31];

endmodule
