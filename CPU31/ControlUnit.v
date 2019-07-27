module ControlUnit
(
    CLK,
    RESULT,
    Z_FLAG,
    PC_CLK,
    IM_R,
    M0,
    M1,
    M2,
    M3,
    M4,
    RF_W,
    ALUC,
    DM_CS,
    DM_R,
    DM_W
);

    input CLK;
    input [53:0]RESULT;
    input Z_FLAG;

    output PC_CLK;
    output IM_R;
    output [1:0]M0;
    output M1;
    output [1:0]M2;
    output [1:0]M3;
    output M4;
    output RF_W;
    output [3:0]ALUC;
    output DM_CS;
    output DM_R;
    output DM_W;


    assign PC_CLK = CLK;
    assign IM_R = 1'b1;
    assign M0[1] = (RESULT[24]&Z_FLAG)|(RESULT[25]&~Z_FLAG)|RESULT[29]|RESULT[30];
    assign M0[0] = RESULT[16]|RESULT[29]|RESULT[30];
    assign M1 = RESULT[0]|RESULT[1]|RESULT[2]|RESULT[3]         // ADD ADDU SUB SUBU
               |RESULT[4]|RESULT[5]|RESULT[6]|RESULT[7]         // AND OR XOR NOR
               |RESULT[8]|RESULT[9]                             // SLT SLTU
               |RESULT[13]|RESULT[14]|RESULT[15]                // SLLV SRLV SRAV
               |RESULT[16]|RESULT[29]|RESULT[30]                // JR J JAL
               |RESULT[17]|RESULT[18]                           // ADDI ADDIU
               |RESULT[19]|RESULT[20]|RESULT[21]                // ANDI ORI XORI
               |RESULT[22]|RESULT[23]                           // LW SW
               |RESULT[24]|RESULT[25]                           // BEQ BNE
               |RESULT[26]|RESULT[27]                           // SLTI SLTIU
               |RESULT[28];                                     // LUI
    assign M2[1] = RESULT[17]|RESULT[18]|RESULT[22]|RESULT[23]|RESULT[26];
                   // ADDI LW SW SLTI
    assign M2[0] = RESULT[17]|RESULT[18]                        // ADDI ADDIU
                  |RESULT[19]|RESULT[20]|RESULT[21]             // ANDI ORI XORI
                  |RESULT[28]                                   // LUI
                  |RESULT[22]|RESULT[23]                        // LW SW
                  |RESULT[26]|RESULT[27];                       // SLTI SLTIU
    assign M3[1] = RESULT[30];                                  // JAL
    assign M3[0] = RESULT[0]|RESULT[1]|RESULT[2]|RESULT[3]      // ADD ADDU SUB SUBU
                  |RESULT[4]|RESULT[5]|RESULT[6]|RESULT[7]      // AND OR XOR NOR
                  |RESULT[8]|RESULT[9]                          // SLT SLTU
                  |RESULT[10]|RESULT[11]|RESULT[12]             // SLL SRL SRA
                  |RESULT[13]|RESULT[14]|RESULT[15]             // SLLV SRLV SRAV
                  |RESULT[16]|RESULT[29]|RESULT[30]             // JR J JAL
                  |RESULT[17]|RESULT[18]                        // ADDI ADDIU
                  |RESULT[19]|RESULT[20]|RESULT[21]             // ANDI ORI XORI
                  |RESULT[23]                                   // SW
                  |RESULT[24]|RESULT[25]                        // BEQ BNE
                  |RESULT[26]|RESULT[27]                        // SLTI SLTIU
                  |RESULT[28];                                  // LUI
    assign M4 = RESULT[0]|RESULT[1]|RESULT[2]|RESULT[3]         // ADD ADDU SUB SUBU
               |RESULT[4]|RESULT[5]|RESULT[6]|RESULT[7]         // AND OR XOR NOR
               |RESULT[8]|RESULT[9]                             // SLT SLTU
               |RESULT[10]|RESULT[11]|RESULT[12]                // SLL SRL SRA
               |RESULT[13]|RESULT[14]|RESULT[15]                // SLLV SRLV SRAV
               |RESULT[16]|RESULT[29]|RESULT[30]                // JR J JAL
               |RESULT[23]                                      // SW
               |RESULT[24]|RESULT[25];                          // BEQ BNE
    // assign RF_CLK = ~CLK;
    assign RF_W = RESULT[0]|RESULT[1]|RESULT[2]|RESULT[3]       // ADD ADDU SUB SUBU
                 |RESULT[4]|RESULT[5]|RESULT[6]|RESULT[7]       // AND OR XOR NOR
                 |RESULT[8]|RESULT[9]                           // SLT SLTU
                 |RESULT[10]|RESULT[11]|RESULT[12]              // SLL SRL SRA
                 |RESULT[13]|RESULT[14]|RESULT[15]              // SLLV SRLV SRAV
                 |RESULT[17]|RESULT[18]                         // ADDI ADDIU
                 |RESULT[19]|RESULT[20]|RESULT[21]              // ANDI ORI XORI
                 |RESULT[22]                                    // LW 
                 |RESULT[26]|RESULT[27]                         // SLTI SLTIU
                 |RESULT[28]                                    // LUI
                 |RESULT[30];                                   // JAL
    assign DM_CS = RESULT[22]|RESULT[23];                       // LW SW
    assign DM_R = RESULT[22];                                   // LW 
    assign DM_W = RESULT[23];                                   // SW  

    assign ALUC[3] = RESULT[8]|RESULT[9]|RESULT[10]|RESULT[11]|RESULT[12]|RESULT[13]|RESULT[14]|RESULT[15]|RESULT[26]|RESULT[27]|RESULT[28];
    assign ALUC[2] = RESULT[4]|RESULT[5]|RESULT[6]|RESULT[7]|RESULT[10]|RESULT[11]|RESULT[12]|RESULT[13]|RESULT[14]|RESULT[15]|RESULT[19]|RESULT[20]|RESULT[21];
    assign ALUC[1] = RESULT[0]|RESULT[2]|RESULT[6]|RESULT[7]|RESULT[8]|RESULT[9]|RESULT[10]|RESULT[13]|RESULT[17]|RESULT[21]|RESULT[24]|RESULT[25]|RESULT[26]|RESULT[27];
    assign ALUC[0] = RESULT[2]|RESULT[3]|RESULT[5]|RESULT[7]|RESULT[8]|RESULT[11]|RESULT[14]|RESULT[20]|RESULT[24]|RESULT[25]|RESULT[26];
    

endmodule