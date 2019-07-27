module IR
(
    INSTR,
    RSC,
    RTC,
    RDC,
    SA,
    IMME,
    INDEX,
    HEAD,
    RESULT
);

    input [31:0]INSTR;

    output [4:0]RSC;
    output [4:0]RTC;
    output [4:0]RDC;
    output [4:0]SA;
    output [15:0]IMME;
    output [25:0]INDEX;
    output [3:0]HEAD;
    output [53:0]RESULT;

    reg [4:0]RSC;
    reg [4:0]RTC;
    reg [4:0]RDC;
    reg [4:0]SA;
    reg [15:0]IMME;
    reg [25:0]INDEX;
    reg [3:0]HEAD;
    reg [53:0]RESULT;

    wire [5:0]op;
    wire [5:0]func;
    assign op   = INSTR[31:26];
    assign func = INSTR[5:0];

    parameter ADD   = 54'b000000000000000000000000000000000000000000000000000001;
    parameter ADDU  = 54'b000000000000000000000000000000000000000000000000000010;
    parameter SUB   = 54'b000000000000000000000000000000000000000000000000000100;
    parameter SUBU  = 54'b000000000000000000000000000000000000000000000000001000;
    parameter AND   = 54'b000000000000000000000000000000000000000000000000010000;
    parameter OR    = 54'b000000000000000000000000000000000000000000000000100000;
    parameter XOR   = 54'b000000000000000000000000000000000000000000000001000000;
    parameter NOR   = 54'b000000000000000000000000000000000000000000000010000000;
    parameter SLT   = 54'b000000000000000000000000000000000000000000000100000000;
    parameter SLTU  = 54'b000000000000000000000000000000000000000000001000000000;
    parameter SLL   = 54'b000000000000000000000000000000000000000000010000000000;
    parameter SRL   = 54'b000000000000000000000000000000000000000000100000000000;
    parameter SRA   = 54'b000000000000000000000000000000000000000001000000000000;
    parameter SLLV  = 54'b000000000000000000000000000000000000000010000000000000;
    parameter SRLV  = 54'b000000000000000000000000000000000000000100000000000000;
    parameter SRAV  = 54'b000000000000000000000000000000000000001000000000000000;
    parameter JR    = 54'b000000000000000000000000000000000000010000000000000000;
    parameter ADDI  = 54'b000000000000000000000000000000000000100000000000000000;
    parameter ADDIU = 54'b000000000000000000000000000000000001000000000000000000;
    parameter ANDI  = 54'b000000000000000000000000000000000010000000000000000000;
    parameter ORI   = 54'b000000000000000000000000000000000100000000000000000000;
    parameter XORI  = 54'b000000000000000000000000000000001000000000000000000000;
    parameter LW    = 54'b000000000000000000000000000000010000000000000000000000;
    parameter SW    = 54'b000000000000000000000000000000100000000000000000000000;
    parameter BEQ   = 54'b000000000000000000000000000001000000000000000000000000;
    parameter BNE   = 54'b000000000000000000000000000010000000000000000000000000;
    parameter SLTI  = 54'b000000000000000000000000000100000000000000000000000000;
    parameter SLTIU = 54'b000000000000000000000000001000000000000000000000000000;
    parameter LUI   = 54'b000000000000000000000000010000000000000000000000000000;
    parameter J     = 54'b000000000000000000000000100000000000000000000000000000;
    parameter JAL   = 54'b000000000000000000000001000000000000000000000000000000;
    always @(*) begin
        case(op)
            // R-tye
            6'b0000:begin
                case (func)
                    // ADD
                    6'b100000:begin
                        RESULT = ADD;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // ADDU
                    6'b100001:begin
                        RESULT = ADDU;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // SUB
                    6'b100010:begin
                        RESULT = SUB;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // SUBU
                    6'b100011:begin
                        RESULT = SUBU;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // AND
                    6'b100100:begin
                        RESULT = AND;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // OR
                    6'b100101:begin
                        RESULT = OR;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // XOR
                    6'b100110:begin
                        RESULT = XOR;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // NOR
                    6'b100111:begin
                        RESULT = NOR;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // SLT
                    6'b101010:begin
                        RESULT = SLT;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // SLTU
                    6'b101011:begin
                        RESULT = SLTU;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // SLL
                    6'b000000:begin
                        RESULT = SLL;
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                        SA  = INSTR[10:6];
                    end 
                    // SRL
                    6'b000010:begin
                        RESULT = SRL;
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                        SA  = INSTR[10:6];
                    end 
                    // SRA
                    6'b000011:begin
                        RESULT = SRA;
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                        SA  = INSTR[10:6];
                    end 
                    // SLLV
                    6'b000100:begin
                        RESULT = SLLV;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // SRLV
                    6'b000110:begin
                        RESULT = SRLV;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // SRAV
                    6'b000111:begin
                        RESULT = SRAV;
                        RSC = INSTR[25:21];
                        RTC = INSTR[20:16];
                        RDC = INSTR[15:11];
                    end 
                    // JR
                    6'b001000:begin
                        RESULT = JR;
                        RSC = INSTR[25:21];
                        RDC = 5'b00000;
                    end 
                endcase
            end 
            // ADDI
            6'b001000:begin
                RESULT = ADDI;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // ADDIU
            6'b001001:begin
                RESULT = ADDIU;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // ANDI
            6'b001100:begin
                RESULT = ANDI;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // ORI
            6'b001101:begin
                RESULT = ORI;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // XORI
            6'b001110:begin
                RESULT = XORI;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // LW
            6'b100011:begin
                RESULT = LW;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // SW
            6'b101011:begin
                RESULT = SW;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // BEQ
            6'b000100:begin
                RESULT = BEQ;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                RDC  = 5'b00000;
                IMME = INSTR[15:0];
            end
            // BNE
            6'b000101:begin
                RESULT = BNE;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                RDC  = 5'b00000;
                IMME = INSTR[15:0];
            end
            // SLTI
            6'b001010:begin
                RESULT = SLTI;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // SLTIU
            6'b001011:begin
                RESULT = SLTIU;
                RSC  = INSTR[25:21];
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // LUI
            6'b001111:begin
                RESULT = LUI;
                RTC  = INSTR[20:16];
                IMME = INSTR[15:0];
            end
            // J
            6'b000010:begin
                RESULT = J;
                INDEX = INSTR[25:0];
                HEAD  = INSTR[31:28];
                RDC   = 5'b00000;
            end
            //JAL
            6'b000011:begin
                RESULT = JAL;
                INDEX = INSTR[25:0];
                RDC   = 5'b11111;
                HEAD  = INSTR[31:28];
            end
        endcase
    end
endmodule