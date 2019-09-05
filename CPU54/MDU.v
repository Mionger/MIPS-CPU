// 乘除法器
`timescale 1ns / 1ps
// 有符号乘法
module MULT
(
    A,
    B,
    R
);
    input [31:0]A;
    input [31:0]B;

    output [63:0]R;

    wire [63:0]p0_0;
    wire [63:0]p0_1;
    wire [63:0]p0_2;
    wire [63:0]p0_3;
    wire [63:0]p0_4;
    wire [63:0]p0_5;
    wire [63:0]p0_6;
    wire [63:0]p0_7;
    wire [63:0]p0_8;
    wire [63:0]p0_9;
    wire [63:0]p0_10;
    wire [63:0]p0_11;
    wire [63:0]p0_12;
    wire [63:0]p0_13;
    wire [63:0]p0_14;
    wire [63:0]p0_15;
    wire [63:0]p0_16;
    wire [63:0]p0_17;
    wire [63:0]p0_18;
    wire [63:0]p0_19;
    wire [63:0]p0_20;
    wire [63:0]p0_21;
    wire [63:0]p0_22;
    wire [63:0]p0_23;
    wire [63:0]p0_24;
    wire [63:0]p0_25;
    wire [63:0]p0_26;
    wire [63:0]p0_27;
    wire [63:0]p0_28;
    wire [63:0]p0_29;
    wire [31:0]p0_30;
    wire [31:0]p0_31;
    wire [63:0]p1_0;
    wire [63:0]p1_1;
    wire [63:0]p1_2;
    wire [63:0]p1_3;
    wire [63:0]p1_4;
    wire [63:0]p1_5;
    wire [63:0]p1_6;
    wire [63:0]p1_7;
    wire [63:0]p1_8;
    wire [63:0]p1_9;
    wire [63:0]p1_10;
    wire [63:0]p1_11;
    wire [63:0]p1_12;
    wire [63:0]p1_13;
    wire [63:0]p1_14;
    wire [63:0]p1_15;
    wire [31:0]p1_t;
    wire p1_c;
    wire highest_0;
    wire highest_1;
    wire [63:0]p2_0;
    wire [63:0]p2_1;
    wire [63:0]p2_2;
    wire [63:0]p2_3;
    wire [63:0]p2_4;
    wire [63:0]p2_5;
    wire [63:0]p2_6;
    wire [63:0]p2_7;
    wire [63:0]p3_0;
    wire [63:0]p3_1;
    wire [63:0]p3_2;
    wire [63:0]p3_3;
    wire [63:0]p4_0;
    wire [63:0]p4_1;

    wire [63:0]temp;

    assign p0_0  = B[0] ? {{32{A[31]}},A[31:0]}       : 64'b0;
    assign p0_1  = B[1] ? {{31{A[31]}},A[31:0], 1'b0} : 64'b0;
    assign p0_2  = B[2] ? {{30{A[31]}},A[31:0], 2'b0} : 64'b0;
    assign p0_3  = B[3] ? {{29{A[31]}},A[31:0], 3'b0} : 64'b0;
    assign p0_4  = B[4] ? {{28{A[31]}},A[31:0], 4'b0} : 64'b0;
    assign p0_5  = B[5] ? {{27{A[31]}},A[31:0], 5'b0} : 64'b0;
    assign p0_6  = B[6] ? {{26{A[31]}},A[31:0], 6'b0} : 64'b0;
    assign p0_7  = B[7] ? {{25{A[31]}},A[31:0], 7'b0} : 64'b0;
    assign p0_8  = B[8] ? {{24{A[31]}},A[31:0], 8'b0} : 64'b0;
    assign p0_9  = B[9] ? {{23{A[31]}},A[31:0], 9'b0} : 64'b0;
    assign p0_10 = B[10]? {{22{A[31]}},A[31:0],10'b0} : 64'b0;
    assign p0_11 = B[11]? {{21{A[31]}},A[31:0],11'b0} : 64'b0;
    assign p0_12 = B[12]? {{20{A[31]}},A[31:0],12'b0} : 64'b0;
    assign p0_13 = B[13]? {{19{A[31]}},A[31:0],13'b0} : 64'b0;
    assign p0_14 = B[14]? {{18{A[31]}},A[31:0],14'b0} : 64'b0;
    assign p0_15 = B[15]? {{17{A[31]}},A[31:0],15'b0} : 64'b0;
    assign p0_16 = B[16]? {{16{A[31]}},A[31:0],16'b0} : 64'b0;
    assign p0_17 = B[17]? {{15{A[31]}},A[31:0],17'b0} : 64'b0;
    assign p0_18 = B[18]? {{14{A[31]}},A[31:0],18'b0} : 64'b0;
    assign p0_19 = B[19]? {{13{A[31]}},A[31:0],19'b0} : 64'b0;
    assign p0_20 = B[20]? {{12{A[31]}},A[31:0],20'b0} : 64'b0;
    assign p0_21 = B[21]? {{11{A[31]}},A[31:0],21'b0} : 64'b0;
    assign p0_22 = B[22]? {{10{A[31]}},A[31:0],22'b0} : 64'b0;
    assign p0_23 = B[23]? {{ 9{A[31]}},A[31:0],23'b0} : 64'b0;
    assign p0_24 = B[24]? {{ 8{A[31]}},A[31:0],24'b0} : 64'b0;
    assign p0_25 = B[25]? {{ 7{A[31]}},A[31:0],25'b0} : 64'b0;
    assign p0_26 = B[26]? {{ 6{A[31]}},A[31:0],26'b0} : 64'b0;
    assign p0_27 = B[27]? {{ 5{A[31]}},A[31:0],27'b0} : 64'b0;
    assign p0_28 = B[28]? {{ 4{A[31]}},A[31:0],28'b0} : 64'b0;
    assign p0_29 = B[29]? {{ 3{A[31]}},A[31:0],29'b0} : 64'b0;
    assign p0_30 = B[30]? {    A[31]  ,A[31:1]      } : 32'b0;
    assign p0_31 = B[31]?     ~A                      : 32'b0;
    
    Adder_64bits adder_1_0 (p0_0 ,p0_1 ,1'b0,p1_0 ,);
    Adder_64bits adder_1_1 (p0_2 ,p0_3 ,1'b0,p1_1 ,);
    Adder_64bits adder_1_2 (p0_4 ,p0_5 ,1'b0,p1_2 ,);
    Adder_64bits adder_1_3 (p0_6 ,p0_7 ,1'b0,p1_3 ,);
    Adder_64bits adder_1_4 (p0_8 ,p0_9 ,1'b0,p1_4 ,);
    Adder_64bits adder_1_5 (p0_10,p0_11,1'b0,p1_5 ,);
    Adder_64bits adder_1_6 (p0_12,p0_13,1'b0,p1_6 ,);
    Adder_64bits adder_1_7 (p0_14,p0_15,1'b0,p1_7 ,);
    Adder_64bits adder_1_8 (p0_16,p0_17,1'b0,p1_8 ,);
    Adder_64bits adder_1_9 (p0_18,p0_19,1'b0,p1_9 ,);
    Adder_64bits adder_1_10(p0_20,p0_21,1'b0,p1_10,);
    Adder_64bits adder_1_11(p0_22,p0_23,1'b0,p1_11,);
    Adder_64bits adder_1_12(p0_24,p0_25,1'b0,p1_12,);
    Adder_64bits adder_1_13(p0_26,p0_27,1'b0,p1_13,);
    Adder_64bits adder_1_14(p0_28,p0_29,1'b0,p1_14,);
    Adder_32bits adder_1_15(p0_30,p0_31,B[31],p1_t ,p1_c);
    assign highest_0=A[31]&B[30];
    assign highest_1=(~A[31])&B[31];
    assign p1_15={highest_0^highest_1^p1_c,p1_t[31:0],A[0]&B[30],30'b0};

    Adder_64bits adder_2_0(p1_0 ,p1_1 ,1'b0,p2_0,);
    Adder_64bits adder_2_1(p1_2 ,p1_3 ,1'b0,p2_1,);
    Adder_64bits adder_2_2(p1_4 ,p1_5 ,1'b0,p2_2,);
    Adder_64bits adder_2_3(p1_6 ,p1_7 ,1'b0,p2_3,);
    Adder_64bits adder_2_4(p1_8 ,p1_9 ,1'b0,p2_4,);
    Adder_64bits adder_2_5(p1_10,p1_11,1'b0,p2_5,);
    Adder_64bits adder_2_6(p1_12,p1_13,1'b0,p2_6,);
    Adder_64bits adder_2_7(p1_14,p1_15,1'b0,p2_7,);

    Adder_64bits adder_3_0(p2_0,p2_1,1'b0,p3_0,);
    Adder_64bits adder_3_1(p2_2,p2_3,1'b0,p3_1,);
    Adder_64bits adder_3_2(p2_4,p2_5,1'b0,p3_2,);
    Adder_64bits adder_3_3(p2_6,p2_7,1'b0,p3_3,);

    Adder_64bits adder_4_0(p3_0,p3_1,1'b0,p4_0,);
    Adder_64bits adder_4_1(p3_2,p3_3,1'b0,p4_1,);

    Adder_64bits adder_5_0(p4_0,p4_1,1'b0,temp,);

    assign R = temp;
endmodule

// 无符号乘法
module MULTU
(
    A,
    B,
    R
);
    input [31:0]A;
    input [31:0]B;

    output [63:0]R;
    
    wire [63:0]p0_0;
    wire [63:0]p0_1;
    wire [63:0]p0_2;
    wire [63:0]p0_3;
    wire [63:0]p0_4;
    wire [63:0]p0_5;
    wire [63:0]p0_6;
    wire [63:0]p0_7;
    wire [63:0]p0_8;
    wire [63:0]p0_9;
    wire [63:0]p0_10;
    wire [63:0]p0_11;
    wire [63:0]p0_12;
    wire [63:0]p0_13;
    wire [63:0]p0_14;
    wire [63:0]p0_15;
    wire [63:0]p0_16;
    wire [63:0]p0_17;
    wire [63:0]p0_18;
    wire [63:0]p0_19;
    wire [63:0]p0_20;
    wire [63:0]p0_21;
    wire [63:0]p0_22;
    wire [63:0]p0_23;
    wire [63:0]p0_24;
    wire [63:0]p0_25;
    wire [63:0]p0_26;
    wire [63:0]p0_27;
    wire [63:0]p0_28;
    wire [63:0]p0_29;
    wire [63:0]p0_30;
    wire [63:0]p0_31;
    wire [63:0]p1_0;
    wire [63:0]p1_1;
    wire [63:0]p1_2;
    wire [63:0]p1_3;
    wire [63:0]p1_4;
    wire [63:0]p1_5;
    wire [63:0]p1_6;
    wire [63:0]p1_7;
    wire [63:0]p1_8;
    wire [63:0]p1_9;
    wire [63:0]p1_10;
    wire [63:0]p1_11;
    wire [63:0]p1_12;
    wire [63:0]p1_13;
    wire [63:0]p1_14;
    wire [63:0]p1_15;
    wire [63:0]p2_0;
    wire [63:0]p2_1;
    wire [63:0]p2_2;
    wire [63:0]p2_3;
    wire [63:0]p2_4;
    wire [63:0]p2_5;
    wire [63:0]p2_6;
    wire [63:0]p2_7;
    wire [63:0]p3_0;
    wire [63:0]p3_1;
    wire [63:0]p3_2;
    wire [63:0]p3_3;
    wire [63:0]p4_0;
    wire [63:0]p4_1;

    wire [63:0]temp;

    assign p0_0  = B[0] ? {32'b0,A[31:0]      } : 64'b0;
    assign p0_1  = B[1] ? {31'b0,A[31:0], 1'b0} : 64'b0;
    assign p0_2  = B[2] ? {30'b0,A[31:0], 2'b0} : 64'b0;
    assign p0_3  = B[3] ? {29'b0,A[31:0], 3'b0} : 64'b0;
    assign p0_4  = B[4] ? {28'b0,A[31:0], 4'b0} : 64'b0;
    assign p0_5  = B[5] ? {27'b0,A[31:0], 5'b0} : 64'b0;
    assign p0_6  = B[6] ? {26'b0,A[31:0], 6'b0} : 64'b0;
    assign p0_7  = B[7] ? {25'b0,A[31:0], 7'b0} : 64'b0;
    assign p0_8  = B[8] ? {24'b0,A[31:0], 8'b0} : 64'b0;
    assign p0_9  = B[9] ? {23'b0,A[31:0], 9'b0} : 64'b0;
    assign p0_10 = B[10]? {22'b0,A[31:0],10'b0} : 64'b0;
    assign p0_11 = B[11]? {21'b0,A[31:0],11'b0} : 64'b0;
    assign p0_12 = B[12]? {20'b0,A[31:0],12'b0} : 64'b0;
    assign p0_13 = B[13]? {19'b0,A[31:0],13'b0} : 64'b0;
    assign p0_14 = B[14]? {18'b0,A[31:0],14'b0} : 64'b0;
    assign p0_15 = B[15]? {17'b0,A[31:0],15'b0} : 64'b0;
    assign p0_16 = B[16]? {16'b0,A[31:0],16'b0} : 64'b0;
    assign p0_17 = B[17]? {15'b0,A[31:0],17'b0} : 64'b0;
    assign p0_18 = B[18]? {14'b0,A[31:0],18'b0} : 64'b0;
    assign p0_19 = B[19]? {13'b0,A[31:0],19'b0} : 64'b0;
    assign p0_20 = B[20]? {12'b0,A[31:0],20'b0} : 64'b0;
    assign p0_21 = B[21]? {11'b0,A[31:0],21'b0} : 64'b0;
    assign p0_22 = B[22]? {10'b0,A[31:0],22'b0} : 64'b0;
    assign p0_23 = B[23]? { 9'b0,A[31:0],23'b0} : 64'b0;
    assign p0_24 = B[24]? { 8'b0,A[31:0],24'b0} : 64'b0;
    assign p0_25 = B[25]? { 7'b0,A[31:0],25'b0} : 64'b0;
    assign p0_26 = B[26]? { 6'b0,A[31:0],26'b0} : 64'b0;
    assign p0_27 = B[27]? { 5'b0,A[31:0],27'b0} : 64'b0;
    assign p0_28 = B[28]? { 4'b0,A[31:0],28'b0} : 64'b0;
    assign p0_29 = B[29]? { 3'b0,A[31:0],29'b0} : 64'b0;
    assign p0_30 = B[30]? { 2'b0,A[31:0],30'b0} : 64'b0;
    assign p0_31 = B[31]? { 1'b0,A[31:0],31'b0} : 64'b0;
    
    Adder_64bits adder_1_0 (p0_0 ,p0_1 ,1'b0,p1_0 ,);
    Adder_64bits adder_1_1 (p0_2 ,p0_3 ,1'b0,p1_1 ,);
    Adder_64bits adder_1_2 (p0_4 ,p0_5 ,1'b0,p1_2 ,);
    Adder_64bits adder_1_3 (p0_6 ,p0_7 ,1'b0,p1_3 ,);
    Adder_64bits adder_1_4 (p0_8 ,p0_9 ,1'b0,p1_4 ,);
    Adder_64bits adder_1_5 (p0_10,p0_11,1'b0,p1_5 ,);
    Adder_64bits adder_1_6 (p0_12,p0_13,1'b0,p1_6 ,);
    Adder_64bits adder_1_7 (p0_14,p0_15,1'b0,p1_7 ,);
    Adder_64bits adder_1_8 (p0_16,p0_17,1'b0,p1_8 ,);
    Adder_64bits adder_1_9 (p0_18,p0_19,1'b0,p1_9 ,);
    Adder_64bits adder_1_10(p0_20,p0_21,1'b0,p1_10,);
    Adder_64bits adder_1_11(p0_22,p0_23,1'b0,p1_11,);
    Adder_64bits adder_1_12(p0_24,p0_25,1'b0,p1_12,);
    Adder_64bits adder_1_13(p0_26,p0_27,1'b0,p1_13,);
    Adder_64bits adder_1_14(p0_28,p0_29,1'b0,p1_14,);
    Adder_64bits adder_1_15(p0_30,p0_31,1'b0,p1_15,);

    Adder_64bits adder_2_0(p1_0 ,p1_1 ,1'b0,p2_0,);
    Adder_64bits adder_2_1(p1_2 ,p1_3 ,1'b0,p2_1,);
    Adder_64bits adder_2_2(p1_4 ,p1_5 ,1'b0,p2_2,);
    Adder_64bits adder_2_3(p1_6 ,p1_7 ,1'b0,p2_3,);
    Adder_64bits adder_2_4(p1_8 ,p1_9 ,1'b0,p2_4,);
    Adder_64bits adder_2_5(p1_10,p1_11,1'b0,p2_5,);
    Adder_64bits adder_2_6(p1_12,p1_13,1'b0,p2_6,);
    Adder_64bits adder_2_7(p1_14,p1_15,1'b0,p2_7,);

    Adder_64bits adder_3_0(p2_0,p2_1,1'b0,p3_0,);
    Adder_64bits adder_3_1(p2_2,p2_3,1'b0,p3_1,);
    Adder_64bits adder_3_2(p2_4,p2_5,1'b0,p3_2,);
    Adder_64bits adder_3_3(p2_6,p2_7,1'b0,p3_3,);

    Adder_64bits adder_4_0(p3_0,p3_1,1'b0,p4_0,);
    Adder_64bits adder_4_1(p3_2,p3_3,1'b0,p4_1,);

    Adder_64bits adder_5_0(p4_0,p4_1,1'b0,temp,);

    assign R = temp;
endmodule

// 无符号除法
module DIVU
(
    DIVIDEND, 
    DIVISOR, 
    START, 
    CLK, 
    RST, 
    Q, 
    R, 
    BUSY
);
    input [31:0]DIVIDEND;
    input [31:0]DIVISOR;
    input START;
    input CLK;
    input RST;
    
    output [31:0]Q;
    output [31:0]R;
    output BUSY;

    reg [31:0]Q = 32'b0;
    reg [31:0]R = 32'b0;
    reg BUSY;

    reg [5:0]counter = 6'b0;
    reg [31:0]reg_q;
    reg [31:0]reg_r;
    reg [31:0]reg_divisor;
    reg r_sign;

    wire [31:0]to_add;
    wire [32:0]sub_add; 
    wire carry_out;
    assign to_add = r_sign? reg_divisor: ~reg_divisor;
    Adder_32bits get_sub_add({reg_r[30:0], reg_q[31]}, to_add, ~r_sign, sub_add[31:0], carry_out);
    assign sub_add[32] = carry_out ^ reg_r[31] ^ ~r_sign;

    wire [31:0]r_divisor;
    Adder_32bits add_r_divisor(reg_r, reg_divisor, 1'b0, r_divisor,);

    always @(negedge CLK or posedge RST) begin
        if(RST)begin
            counter <= 6'b0;
            BUSY    <= 1'b0;
        end
        else begin
            if(START)begin
                counter     <= 6'b0;
                reg_q       <= DIVIDEND;
                r_sign      <= 1'b0;
                reg_r       <= 32'b0;
                reg_divisor <= DIVISOR;
                BUSY        <= 1'b1;
            end
            else begin
                if(BUSY) begin
                    counter     <= counter + 1'b1;
                    reg_q       <= {reg_q[30:0], ~sub_add[32]};
                    r_sign      <= sub_add[32];
                    reg_r       <= sub_add[31:0];
                    reg_divisor <= reg_divisor;
                    if(counter == 6'd32) begin
                        Q    <= reg_q;
                        R    <= r_sign? r_divisor: reg_r;
                        BUSY <= 1'b0;
                    end 
                    else begin
                        Q    <= Q;
                        R    <= R;
                        BUSY <= 1'b1;
                    end
                end
                else begin
                    BUSY <= 1'b0;
                end
            end
        end
    end  
endmodule

// 有符号除法
module DIV
(
    DIVIDEND,
    DIVISOR, 
    START, 
    CLK, 
    RST, 
    Q, 
    R, 
    BUSY
);
    input [31:0]DIVIDEND;
    input [31:0]DIVISOR;
    input START;
    input CLK;
    input RST;
    output [31:0]Q;
    output [31:0]R;
    output BUSY;

    reg BUSY;
    reg [4:0]counter;
    reg [31:0]reg_q;
    reg [31:0]reg_r;
    reg [31:0]reg_divisor;
    reg r_sign;
    reg q_sign;

    wire [31:0]dividend_abs;
    wire [31:0]divisor_abs;
    wire [31:0]r_abs;
    wire [32:0]sub_add;

    assign dividend_abs = DIVIDEND[31]? (~DIVIDEND + 1'b1): DIVIDEND;
    assign divisor_abs = DIVISOR[31]? (~DIVISOR + 1'b1): DIVISOR;
    assign r_abs = r_sign? (reg_r + reg_divisor): reg_r;
    assign sub_add = r_sign? ({reg_r, reg_q[31]} + {1'b0, reg_divisor}): ({reg_r, reg_q[31]} - {1'b0, reg_divisor}); 

    always @(posedge CLK or posedge RST) begin
        if(RST) begin
            counter <= 5'b0;
            BUSY <= 1'b0;
        end 
        else begin
            if(START) begin
                q_sign <= DIVIDEND[31] ^ DIVISOR[31];
                reg_r <= 32'b0;
                reg_q <= dividend_abs;
                reg_divisor <= divisor_abs;
                r_sign <= 1'b0;
                counter <= 5'b0;
                BUSY <= 1'b1;
            end 
            else begin
                if(BUSY) begin
                    reg_r <= sub_add[31:0];
                    r_sign <= sub_add[32];
                    reg_q <= {reg_q[30:0], ~sub_add[32]};
                    counter <= counter + 1'b1;
                    if(counter == 5'd31) begin
                        BUSY <= 1'b0;
                    end 
                    else begin
                        BUSY <= 1'b1;
                    end
                end 
                else begin
                    BUSY <= 1'b0;
                end
            end
        end
    end

    assign Q= q_sign?(~reg_q + 1'b1) :reg_q;
    assign R= DIVIDEND[31]? (~r_abs + 1'b1):r_abs;
endmodule

module MDU
(
    CLK, 
    A, 
    B, 
    MDUC, 
    START, 
    BUSY, 
    R1, 
    R2
);
    input CLK;
    input [31:0]A;
    input [31:0]B;
    input [1:0]MDUC;
    input START;
    output BUSY;
    output [31:0]R1;
    output [31:0]R2;

    reg BUSY;
    reg [31:0]R1;
    reg [31:0]R2;
    reg [31:0]a_reg;
    reg [31:0]b_reg;

    reg div_start = 1'b0;
    reg div_reset = 1'b0;
    wire [31:0]div_q;
    wire [31:0]div_r;
    wire div_busy;
    DIV div(a_reg, b_reg, div_start, CLK, div_reset, div_q, div_r, div_busy);

    reg divu_start = 1'b0;
    reg divu_reset = 1'b0;
    wire [31:0]divu_q;
    wire [31:0]divu_r;
    wire divu_busy;
    DIVU divu(a_reg, b_reg, divu_start, CLK, divu_reset, divu_q, divu_r, divu_busy);

    wire [63:0]mult_result;
    MULT mult(a_reg, b_reg, mult_result);

    wire [63:0]multu_result;
    MULTU multu(a_reg, b_reg, multu_result);
    
    parameter IDLE = 4'b0000;
    parameter READ = 4'b0001;
    parameter MULT = 4'b0011;
    parameter MULTU = 4'b0010;
    parameter DIV = 4'b0110;
    parameter DIVWAIT = 4'b0111;
    parameter DIVU = 4'b0101;
    parameter DIVUWAIT = 4'b0100;
    parameter WRITE = 4'b1100;

    reg [3:0]current_state = IDLE;
    reg [3:0]next_state;

    always @(posedge CLK) begin
        current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            IDLE: begin
                if(START) begin
                    next_state = READ;
                end 
                else begin
                    next_state = IDLE;
                end
            end
            READ: begin
                case(MDUC)
                    2'b00: next_state = MULT;
                    2'b01: next_state = MULTU;
                    2'b10: next_state = DIV;
                    2'b11: next_state = DIVU;
                endcase
            end
            MULT: begin
                next_state = WRITE;
            end
            MULTU: begin
                next_state = WRITE;
            end
            DIV: begin
                next_state = DIVWAIT;
            end
            DIVU: begin
                next_state = DIVUWAIT;
            end
            DIVWAIT: begin
                if(div_busy) begin
                    next_state = DIVWAIT;
                end 
                else begin
                    next_state = WRITE;
                end
            end
            DIVUWAIT: begin
                if(divu_busy) begin
                    next_state = DIVUWAIT;
                end 
                else begin
                    next_state = WRITE;
                end
            end
            WRITE: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(negedge CLK) begin
        case(current_state)
            READ: begin
                a_reg <= A;
                b_reg <= B;
            end
            default: begin
                a_reg <= a_reg;
                b_reg <= b_reg;
            end
        endcase
    end

    always @(negedge CLK) begin
        if(current_state == IDLE) begin
            div_reset <= 1'b1;
            divu_reset <= 1'b1;
        end 
        else begin
            divu_reset <= 1'b0;
            div_reset <= 1'b0;
        end
    end
    always @(negedge CLK) begin
        case(current_state)
            DIV: begin
                div_start = 1'b1;
                divu_start = 1'b0;
            end
            DIVU: begin
                divu_start = 1'b1;
                div_start = 1'b0;
            end
            default: begin
                divu_start = 1'b0;
                div_start = 1'b0;
            end
        endcase
    end

    always @(negedge CLK) begin
        case(current_state)
            WRITE: begin
                case(MDUC)
                    2'b00: begin
                        R1 <= mult_result[63:32];
                        R2 <= mult_result[31:0];
                    end
                    2'b01: begin
                        R1 <= multu_result[63:32];
                        R2 <= multu_result[31:0];
                    end
                    2'b10: begin
                        R1 <= div_r;
                        R2 <= div_q;
                    end
                    2'b11: begin
                        R1 <= divu_r;
                        R2 <= divu_q;
                    end
                endcase
            end
            default: begin
                R1 <= R1;
                R2 <= R2;
            end
        endcase
    end

    always @(negedge CLK) begin
        case(current_state)
            IDLE: BUSY <= 1'b0;
            default: BUSY <= 1'b1;
        endcase
    end
endmodule








