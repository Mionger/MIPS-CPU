`timescale 1ns / 1ps
module DDR_Buffer
(
	input clk,
	input reset,
	
	input [4095:0] data_FromCon,//control给buffer传的4096位数�?
	output reg [4095:0] data_ToCon,//buffer给control传的4096位数�?
	output reg [127:0] data_ToDDR,//buffer给ddr传的128位数�?
	input [127:0] data_FromDDR,//ddr给buffer�?128位数�?
	
	input [31:0] addr_FromControl,//control给buffer传的32位地址，其中包含了页地址
	output [23:0] addr_ToDDR,//给ddr的地�?
	
	input we_ConToBuffer,//控制器给buffer的信号，给buffer传数�?
	input we_BufferToCon,//控制器给buffer的信号，从buffer读数�?
	input we_BufferToDDR,//控制器给buffer的信号，要求buffer给ddr送数�?
	input we_DDRToBuffer,//控制器给buffer的信号，要求buffer从ddr读数�?
	
	output reg we_ToDDR,//buffer给ddr的写使能
	output reg re_ToDDR,//buffer给ddr的读使能
	
	input sig_DDRWriteEnd,//ddr给buffer的写好的信号
	input sig_DDRReadEnd,//ddr给buffer的可读的信号
	
	output reg sig_BufferWriteOK,//buffer给control的写好的信号
	output reg sig_BufferReadOK,//buffer给control的可读的信号
	output reg sig_DDRWriteOK,//buffer给control的表示ddr写好了的信号
	output reg sig_DDRReadOK,//buffer给control的表示从ddr读完了的信号
	output [6:0]state
);
	reg [4095:0] dataTemp;
	
	reg [5:0] countAddr=6'b0;//给ddr�?128位数据的地址计数�?
	assign addr_ToDDR={addr_FromControl[27:9],countAddr[5:0]};
	
	
	parameter INIT  = 7'd1;
    parameter IDLE  = 7'd2;
	
    parameter READ_CON = 7'd3;
	parameter READ_CON_WAIT=7'd17;
	parameter READ_CON_END=7'd16;
	
    parameter WRITE_FROMCON = 7'd4;
	parameter WRITE_FROMCON_WAIT = 7'd7;
	parameter WRITE_FROMCON_END = 7'd10;

	parameter WRITE_BUFFERTODDR= 7'd5;
	parameter WRITE_BUFFERTODDR_WAIT = 7'd8;
	parameter WRITE_BUFFERTODDR_ADDADDR = 7'd14;
	parameter WRITE_BUFFERTODDR_END = 7'd11;

	parameter WRITE_DDRTOBUFFER= 7'd6;
	parameter WRITE_DDRTOBUFFER_WAIT = 7'd9;
	parameter WRITE_DDRTOBUFFER_ADDADDR = 7'd15;
	parameter WRITE_DDRTOBUFFER_END = 7'd12;
	
    parameter END= 7'd13;
    
	//reg writeFromConEnd=1'b0;
	
	reg [6:0]current_state = INIT;
    reg [6:0]next_state = INIT;
	assign state = current_state;
	always @(posedge clk or posedge reset)
		begin
            if(reset) 
				begin
					current_state<=INIT;					
				end
			else
				begin
					current_state<=next_state;
				end
        end
	
	always @(*)
		begin
			case(current_state)
				INIT:
					begin
						next_state=IDLE;
					end
				IDLE:
					begin
						if(we_ConToBuffer)
							begin
								next_state=WRITE_FROMCON;
							end
						else if(we_BufferToCon)
							begin
								next_state=READ_CON;
							end
						else if(we_BufferToDDR)
							begin
								next_state=WRITE_BUFFERTODDR;
							end
						else if(we_DDRToBuffer)
							begin
								next_state=WRITE_DDRTOBUFFER;
							end
						else
							begin
								next_state=IDLE;
							end
					end
				WRITE_FROMCON:
					begin
						next_state=WRITE_BUFFERTODDR_END;
					end
				WRITE_FROMCON_END:
					begin
						if(we_ConToBuffer)
							begin
								next_state=WRITE_FROMCON_END;
							end
						else
							begin
								next_state=IDLE;
							end
					end
				READ_CON:
					begin
						next_state=READ_CON_END;
					end
				READ_CON_END:
					begin
						if(we_BufferToCon)
							begin
								next_state=READ_CON;
							end
						else
							begin
								next_state=IDLE;
							end
					end
				WRITE_BUFFERTODDR:
					begin
						next_state=WRITE_BUFFERTODDR_WAIT;
					end
				WRITE_BUFFERTODDR_WAIT:
					begin
						if(sig_DDRWriteEnd)
							begin
								next_state=WRITE_BUFFERTODDR_ADDADDR;
							end
						else
							begin
								next_state=WRITE_BUFFERTODDR_WAIT;
							end
					end
				WRITE_BUFFERTODDR_ADDADDR:
					begin
						if(countAddr>=6'd32)
							begin
								next_state=WRITE_BUFFERTODDR_END;
							end
						else
							begin
								next_state=WRITE_BUFFERTODDR;
							end
					end
				WRITE_BUFFERTODDR_END:
					begin
						if(we_BufferToDDR)
							next_state=WRITE_BUFFERTODDR_END;
						else
							next_state=IDLE;
					end
				WRITE_DDRTOBUFFER:
					begin
						next_state=WRITE_DDRTOBUFFER_WAIT;
					end
				WRITE_DDRTOBUFFER_WAIT:
					begin
						if(sig_DDRReadEnd)
							begin
								next_state=WRITE_DDRTOBUFFER_ADDADDR;	
							end
						else
							begin
								next_state=WRITE_DDRTOBUFFER_WAIT;
							end
					end
				WRITE_DDRTOBUFFER_ADDADDR:
					begin
						if(countAddr>=6'd32)
							begin
								next_state=WRITE_DDRTOBUFFER_END;
							end
						else
							begin
								next_state=WRITE_DDRTOBUFFER;
							end
					end
				WRITE_DDRTOBUFFER_END:
					begin
						if(we_DDRToBuffer)
							next_state=WRITE_DDRTOBUFFER_END;
						else
							next_state=IDLE;
					end
				default:
					begin
						next_state=INIT;
					end
			endcase
		end
	//---------------------------------------------------
	always @(*)
		begin
			case(current_state)
				INIT:
					begin
						dataTemp=4096'b0;
						countAddr=6'b0;
					end
				IDLE:
					begin
						countAddr=6'b0;
					end
				WRITE_FROMCON:
					begin
						dataTemp=data_FromCon;
					end
				READ_CON:
					begin
						data_ToCon=dataTemp;
					end
				WRITE_BUFFERTODDR:
					begin
						data_ToDDR[0]<=dataTemp[{countAddr,6'd127}];
						data_ToDDR[1]<=dataTemp[{countAddr,6'd126}];
						data_ToDDR[2]<=dataTemp[{countAddr,6'd125}];
						data_ToDDR[3]<=dataTemp[{countAddr,6'd124}];
						data_ToDDR[4]<=dataTemp[{countAddr,6'd123}];
						data_ToDDR[5]<=dataTemp[{countAddr,6'd122}];
						data_ToDDR[6]<=dataTemp[{countAddr,6'd121}];
						data_ToDDR[7]<=dataTemp[{countAddr,6'd120}];
						data_ToDDR[8]<=dataTemp[{countAddr,6'd119}];
						data_ToDDR[9]<=dataTemp[{countAddr,6'd118}];
						data_ToDDR[10]<=dataTemp[{countAddr,6'd117}];
						data_ToDDR[11]<=dataTemp[{countAddr,6'd116}];
						data_ToDDR[12]<=dataTemp[{countAddr,6'd115}];
						data_ToDDR[13]<=dataTemp[{countAddr,6'd114}];
						data_ToDDR[14]<=dataTemp[{countAddr,6'd113}];
						data_ToDDR[15]<=dataTemp[{countAddr,6'd112}];
						data_ToDDR[16]<=dataTemp[{countAddr,6'd111}];
						data_ToDDR[17]<=dataTemp[{countAddr,6'd110}];
						data_ToDDR[18]<=dataTemp[{countAddr,6'd119}];
						data_ToDDR[19]<=dataTemp[{countAddr,6'd108}];
						data_ToDDR[20]<=dataTemp[{countAddr,6'd107}];
						data_ToDDR[21]<=dataTemp[{countAddr,6'd106}];
						data_ToDDR[22]<=dataTemp[{countAddr,6'd105}];
						data_ToDDR[23]<=dataTemp[{countAddr,6'd104}];
						data_ToDDR[24]<=dataTemp[{countAddr,6'd103}];
						data_ToDDR[25]<=dataTemp[{countAddr,6'd102}];
						data_ToDDR[26]<=dataTemp[{countAddr,6'd101}];
						data_ToDDR[27]<=dataTemp[{countAddr,6'd100}];
						data_ToDDR[28]<=dataTemp[{countAddr,6'd99}];
						data_ToDDR[29]<=dataTemp[{countAddr,6'd98}];
						data_ToDDR[30]<=dataTemp[{countAddr,6'd97}];
						data_ToDDR[31]<=dataTemp[{countAddr,6'd96}];
						data_ToDDR[32]<=dataTemp[{countAddr,6'd95}];
						data_ToDDR[33]<=dataTemp[{countAddr,6'd94}];
						data_ToDDR[34]<=dataTemp[{countAddr,6'd93}];
						data_ToDDR[35]<=dataTemp[{countAddr,6'd92}];
						data_ToDDR[36]<=dataTemp[{countAddr,6'd91}];
						data_ToDDR[37]<=dataTemp[{countAddr,6'd90}];
						data_ToDDR[38]<=dataTemp[{countAddr,6'd89}];
						data_ToDDR[39]<=dataTemp[{countAddr,6'd88}];
						data_ToDDR[40]<=dataTemp[{countAddr,6'd87}];
						data_ToDDR[41]<=dataTemp[{countAddr,6'd86}];
						data_ToDDR[42]<=dataTemp[{countAddr,6'd85}];
						data_ToDDR[43]<=dataTemp[{countAddr,6'd84}];
						data_ToDDR[44]<=dataTemp[{countAddr,6'd83}];
						data_ToDDR[45]<=dataTemp[{countAddr,6'd82}];
						data_ToDDR[46]<=dataTemp[{countAddr,6'd81}];
						data_ToDDR[47]<=dataTemp[{countAddr,6'd80}];
						data_ToDDR[48]<=dataTemp[{countAddr,6'd79}];
						data_ToDDR[49]<=dataTemp[{countAddr,6'd78}];
						data_ToDDR[50]<=dataTemp[{countAddr,6'd77}];
						data_ToDDR[51]<=dataTemp[{countAddr,6'd76}];
						data_ToDDR[52]<=dataTemp[{countAddr,6'd75}];
						data_ToDDR[53]<=dataTemp[{countAddr,6'd74}];
						data_ToDDR[54]<=dataTemp[{countAddr,6'd73}];
						data_ToDDR[55]<=dataTemp[{countAddr,6'd72}];
						data_ToDDR[56]<=dataTemp[{countAddr,6'd71}];
						data_ToDDR[57]<=dataTemp[{countAddr,6'd70}];
						data_ToDDR[58]<=dataTemp[{countAddr,6'd69}];
						data_ToDDR[59]<=dataTemp[{countAddr,6'd68}];
						data_ToDDR[60]<=dataTemp[{countAddr,6'd67}];
						data_ToDDR[61]<=dataTemp[{countAddr,6'd66}];
						data_ToDDR[62]<=dataTemp[{countAddr,6'd65}];
						data_ToDDR[63]<=dataTemp[{countAddr,6'd64}];
						data_ToDDR[64]<=dataTemp[{countAddr,6'd63}];
						data_ToDDR[65]<=dataTemp[{countAddr,6'd62}];
						data_ToDDR[66]<=dataTemp[{countAddr,6'd61}];
						data_ToDDR[67]<=dataTemp[{countAddr,6'd60}];
						data_ToDDR[68]<=dataTemp[{countAddr,6'd59}];
						data_ToDDR[69]<=dataTemp[{countAddr,6'd58}];
						data_ToDDR[70]<=dataTemp[{countAddr,6'd57}];
						data_ToDDR[71]<=dataTemp[{countAddr,6'd56}];
						data_ToDDR[72]<=dataTemp[{countAddr,6'd55}];
						data_ToDDR[73]<=dataTemp[{countAddr,6'd54}];
						data_ToDDR[74]<=dataTemp[{countAddr,6'd53}];
						data_ToDDR[75]<=dataTemp[{countAddr,6'd52}];
						data_ToDDR[76]<=dataTemp[{countAddr,6'd51}];
						data_ToDDR[77]<=dataTemp[{countAddr,6'd50}];
						data_ToDDR[78]<=dataTemp[{countAddr,6'd49}];
						data_ToDDR[79]<=dataTemp[{countAddr,6'd48}];
						data_ToDDR[80]<=dataTemp[{countAddr,6'd47}];
						data_ToDDR[81]<=dataTemp[{countAddr,6'd46}];
						data_ToDDR[82]<=dataTemp[{countAddr,6'd45}];
						data_ToDDR[83]<=dataTemp[{countAddr,6'd44}];
						data_ToDDR[84]<=dataTemp[{countAddr,6'd43}];
						data_ToDDR[85]<=dataTemp[{countAddr,6'd42}];
						data_ToDDR[86]<=dataTemp[{countAddr,6'd41}];
						data_ToDDR[87]<=dataTemp[{countAddr,6'd40}];
						data_ToDDR[88]<=dataTemp[{countAddr,6'd39}];
						data_ToDDR[89]<=dataTemp[{countAddr,6'd38}];
						data_ToDDR[90]<=dataTemp[{countAddr,6'd37}];
						data_ToDDR[91]<=dataTemp[{countAddr,6'd36}];
						data_ToDDR[92]<=dataTemp[{countAddr,6'd35}];
						data_ToDDR[93]<=dataTemp[{countAddr,6'd34}];
						data_ToDDR[94]<=dataTemp[{countAddr,6'd33}];
						data_ToDDR[95]<=dataTemp[{countAddr,6'd32}];
						data_ToDDR[96]<=dataTemp[{countAddr,6'd31}];
						data_ToDDR[97]<=dataTemp[{countAddr,6'd30}];
						data_ToDDR[98]<=dataTemp[{countAddr,6'd29}];
						data_ToDDR[99]<=dataTemp[{countAddr,6'd28}];
						data_ToDDR[100]<=dataTemp[{countAddr,6'd27}];
						data_ToDDR[101]<=dataTemp[{countAddr,6'd26}];
						data_ToDDR[102]<=dataTemp[{countAddr,6'd25}];
						data_ToDDR[103]<=dataTemp[{countAddr,6'd24}];
						data_ToDDR[104]<=dataTemp[{countAddr,6'd23}];
						data_ToDDR[105]<=dataTemp[{countAddr,6'd22}];
						data_ToDDR[106]<=dataTemp[{countAddr,6'd21}];
						data_ToDDR[107]<=dataTemp[{countAddr,6'd20}];
						data_ToDDR[108]<=dataTemp[{countAddr,6'd19}];
						data_ToDDR[109]<=dataTemp[{countAddr,6'd18}];
						data_ToDDR[110]<=dataTemp[{countAddr,6'd17}];
						data_ToDDR[111]<=dataTemp[{countAddr,6'd16}];
						data_ToDDR[112]<=dataTemp[{countAddr,6'd15}];
						data_ToDDR[113]<=dataTemp[{countAddr,6'd14}];
						data_ToDDR[114]<=dataTemp[{countAddr,6'd13}];
						data_ToDDR[115]<=dataTemp[{countAddr,6'd12}];
						data_ToDDR[116]<=dataTemp[{countAddr,6'd11}];
						data_ToDDR[117]<=dataTemp[{countAddr,6'd10}];
						data_ToDDR[118]<=dataTemp[{countAddr,6'd9}];
						data_ToDDR[119]<=dataTemp[{countAddr,6'd8}];
						data_ToDDR[120]<=dataTemp[{countAddr,6'd7}];
						data_ToDDR[121]<=dataTemp[{countAddr,6'd6}];
						data_ToDDR[122]<=dataTemp[{countAddr,6'd5}];
						data_ToDDR[123]<=dataTemp[{countAddr,6'd4}];
						data_ToDDR[124]<=dataTemp[{countAddr,6'd3}];
						data_ToDDR[125]<=dataTemp[{countAddr,6'd2}];
						data_ToDDR[126]<=dataTemp[{countAddr,6'd1}];
						data_ToDDR[127]<=dataTemp[{countAddr,6'd0}];						
					end
				WRITE_BUFFERTODDR_END:
					begin
						countAddr=countAddr+1'b1;
						if(countAddr>=6'd32)
							begin
								countAddr=6'd0;
							end
					end
				WRITE_DDRTOBUFFER_WAIT:
					begin
						dataTemp[{countAddr,6'd127}]<=data_FromDDR[0];
						dataTemp[{countAddr,6'd126}]<=data_FromDDR[1];
						dataTemp[{countAddr,6'd125}]<=data_FromDDR[2];
						dataTemp[{countAddr,6'd124}]<=data_FromDDR[3];
						dataTemp[{countAddr,6'd123}]<=data_FromDDR[4];
						dataTemp[{countAddr,6'd122}]<=data_FromDDR[5];
						dataTemp[{countAddr,6'd121}]<=data_FromDDR[6];
						dataTemp[{countAddr,6'd120}]<=data_FromDDR[7];
						dataTemp[{countAddr,6'd119}]<=data_FromDDR[8];
						dataTemp[{countAddr,6'd118}]<=data_FromDDR[9];
						dataTemp[{countAddr,6'd117}]<=data_FromDDR[10];
						dataTemp[{countAddr,6'd116}]<=data_FromDDR[11];
						dataTemp[{countAddr,6'd115}]<=data_FromDDR[12];
						dataTemp[{countAddr,6'd114}]<=data_FromDDR[13];
						dataTemp[{countAddr,6'd113}]<=data_FromDDR[14];
						dataTemp[{countAddr,6'd112}]<=data_FromDDR[15];
						dataTemp[{countAddr,6'd111}]<=data_FromDDR[16];
						dataTemp[{countAddr,6'd110}]<=data_FromDDR[17];
						dataTemp[{countAddr,6'd119}]<=data_FromDDR[18];
						dataTemp[{countAddr,6'd108}]<=data_FromDDR[19];
						dataTemp[{countAddr,6'd107}]<=data_FromDDR[20];
						dataTemp[{countAddr,6'd106}]<=data_FromDDR[21];
						dataTemp[{countAddr,6'd105}]<=data_FromDDR[22];
						dataTemp[{countAddr,6'd104}]<=data_FromDDR[23];
						dataTemp[{countAddr,6'd103}]<=data_FromDDR[24];
						dataTemp[{countAddr,6'd102}]<=data_FromDDR[25];
						dataTemp[{countAddr,6'd101}]<=data_FromDDR[26];
						dataTemp[{countAddr,6'd100}]<=data_FromDDR[27];
						dataTemp[{countAddr,6'd99}]<=data_FromDDR[28];
						dataTemp[{countAddr,6'd98}]<=data_FromDDR[29];
						dataTemp[{countAddr,6'd97}]<=data_FromDDR[30];
						dataTemp[{countAddr,6'd96}]<=data_FromDDR[31];
						dataTemp[{countAddr,6'd95}]<=data_FromDDR[32];
						dataTemp[{countAddr,6'd94}]<=data_FromDDR[33];
						dataTemp[{countAddr,6'd93}]<=data_FromDDR[34];
						dataTemp[{countAddr,6'd92}]<=data_FromDDR[35];
						dataTemp[{countAddr,6'd91}]<=data_FromDDR[36];
						dataTemp[{countAddr,6'd90}]<=data_FromDDR[37];
						dataTemp[{countAddr,6'd89}]<=data_FromDDR[38];
						dataTemp[{countAddr,6'd88}]<=data_FromDDR[39];
						dataTemp[{countAddr,6'd87}]<=data_FromDDR[40];
						dataTemp[{countAddr,6'd86}]<=data_FromDDR[41];
						dataTemp[{countAddr,6'd85}]<=data_FromDDR[42];
						dataTemp[{countAddr,6'd84}]<=data_FromDDR[43];
						dataTemp[{countAddr,6'd83}]<=data_FromDDR[44];
						dataTemp[{countAddr,6'd82}]<=data_FromDDR[45];
						dataTemp[{countAddr,6'd81}]<=data_FromDDR[46];
						dataTemp[{countAddr,6'd80}]<=data_FromDDR[47];
						dataTemp[{countAddr,6'd79}]<=data_FromDDR[48];
						dataTemp[{countAddr,6'd78}]<=data_FromDDR[49];
						dataTemp[{countAddr,6'd77}]<=data_FromDDR[50];
						dataTemp[{countAddr,6'd76}]<=data_FromDDR[51];
						dataTemp[{countAddr,6'd75}]<=data_FromDDR[52];
						dataTemp[{countAddr,6'd74}]<=data_FromDDR[53];
						dataTemp[{countAddr,6'd73}]<=data_FromDDR[54];
						dataTemp[{countAddr,6'd72}]<=data_FromDDR[55];
						dataTemp[{countAddr,6'd71}]<=data_FromDDR[56];
						dataTemp[{countAddr,6'd70}]<=data_FromDDR[57];
						dataTemp[{countAddr,6'd69}]<=data_FromDDR[58];
						dataTemp[{countAddr,6'd68}]<=data_FromDDR[59];
						dataTemp[{countAddr,6'd67}]<=data_FromDDR[60];
						dataTemp[{countAddr,6'd66}]<=data_FromDDR[61];
						dataTemp[{countAddr,6'd65}]<=data_FromDDR[62];
						dataTemp[{countAddr,6'd64}]<=data_FromDDR[63];
						dataTemp[{countAddr,6'd63}]<=data_FromDDR[64];
						dataTemp[{countAddr,6'd62}]<=data_FromDDR[65];
						dataTemp[{countAddr,6'd61}]<=data_FromDDR[66];
						dataTemp[{countAddr,6'd60}]<=data_FromDDR[67];
						dataTemp[{countAddr,6'd59}]<=data_FromDDR[68];
						dataTemp[{countAddr,6'd58}]<=data_FromDDR[69];
						dataTemp[{countAddr,6'd57}]<=data_FromDDR[70];
						dataTemp[{countAddr,6'd56}]<=data_FromDDR[71];
						dataTemp[{countAddr,6'd55}]<=data_FromDDR[72];
						dataTemp[{countAddr,6'd54}]<=data_FromDDR[73];
						dataTemp[{countAddr,6'd53}]<=data_FromDDR[74];
						dataTemp[{countAddr,6'd52}]<=data_FromDDR[75];
						dataTemp[{countAddr,6'd51}]<=data_FromDDR[76];
						dataTemp[{countAddr,6'd50}]<=data_FromDDR[77];
						dataTemp[{countAddr,6'd49}]<=data_FromDDR[78];
						dataTemp[{countAddr,6'd48}]<=data_FromDDR[79];
						dataTemp[{countAddr,6'd47}]<=data_FromDDR[80];
						dataTemp[{countAddr,6'd46}]<=data_FromDDR[81];
						dataTemp[{countAddr,6'd45}]<=data_FromDDR[82];
						dataTemp[{countAddr,6'd44}]<=data_FromDDR[83];
						dataTemp[{countAddr,6'd43}]<=data_FromDDR[84];
						dataTemp[{countAddr,6'd42}]<=data_FromDDR[85];
						dataTemp[{countAddr,6'd41}]<=data_FromDDR[86];
						dataTemp[{countAddr,6'd40}]<=data_FromDDR[87];
						dataTemp[{countAddr,6'd39}]<=data_FromDDR[88];
						dataTemp[{countAddr,6'd38}]<=data_FromDDR[89];
						dataTemp[{countAddr,6'd37}]<=data_FromDDR[90];
						dataTemp[{countAddr,6'd36}]<=data_FromDDR[91];
						dataTemp[{countAddr,6'd35}]<=data_FromDDR[92];
						dataTemp[{countAddr,6'd34}]<=data_FromDDR[93];
						dataTemp[{countAddr,6'd33}]<=data_FromDDR[94];
						dataTemp[{countAddr,6'd32}]<=data_FromDDR[95];
						dataTemp[{countAddr,6'd31}]<=data_FromDDR[96];
						dataTemp[{countAddr,6'd30}]<=data_FromDDR[97];
						dataTemp[{countAddr,6'd29}]<=data_FromDDR[98];
						dataTemp[{countAddr,6'd28}]<=data_FromDDR[99];
						dataTemp[{countAddr,6'd27}]<=data_FromDDR[100];
						dataTemp[{countAddr,6'd26}]<=data_FromDDR[101];
						dataTemp[{countAddr,6'd25}]<=data_FromDDR[102];
						dataTemp[{countAddr,6'd24}]<=data_FromDDR[103];
						dataTemp[{countAddr,6'd23}]<=data_FromDDR[104];
						dataTemp[{countAddr,6'd22}]<=data_FromDDR[105];
						dataTemp[{countAddr,6'd21}]<=data_FromDDR[106];
						dataTemp[{countAddr,6'd20}]<=data_FromDDR[107];
						dataTemp[{countAddr,6'd19}]<=data_FromDDR[108];
						dataTemp[{countAddr,6'd18}]<=data_FromDDR[109];
						dataTemp[{countAddr,6'd17}]<=data_FromDDR[110];
						dataTemp[{countAddr,6'd16}]<=data_FromDDR[111];
						dataTemp[{countAddr,6'd15}]<=data_FromDDR[112];
						dataTemp[{countAddr,6'd14}]<=data_FromDDR[113];
						dataTemp[{countAddr,6'd13}]<=data_FromDDR[114];
						dataTemp[{countAddr,6'd12}]<=data_FromDDR[115];
						dataTemp[{countAddr,6'd11}]<=data_FromDDR[116];
						dataTemp[{countAddr,6'd10}]<=data_FromDDR[117];
						dataTemp[{countAddr,6'd9}]<=data_FromDDR[118];
						dataTemp[{countAddr,6'd8}]<=data_FromDDR[119];
						dataTemp[{countAddr,6'd7}]<=data_FromDDR[120];
						dataTemp[{countAddr,6'd6}]<=data_FromDDR[121];
						dataTemp[{countAddr,6'd5}]<=data_FromDDR[122];
						dataTemp[{countAddr,6'd4}]<=data_FromDDR[123];
						dataTemp[{countAddr,6'd3}]<=data_FromDDR[124];
						dataTemp[{countAddr,6'd2}]<=data_FromDDR[125];
						dataTemp[{countAddr,6'd1}]<=data_FromDDR[126];
						dataTemp[{countAddr,6'd0}]<=data_FromDDR[127];
					end
				WRITE_DDRTOBUFFER_END:
					begin
						countAddr=countAddr+1'b1;
						if(countAddr>=6'd32)
							begin
								countAddr=6'd0;
							end
					end
				default:
					begin
						//do nothing here
					end
			endcase
		end
	//------------------------------------------------------------------------
	always @(*)
		begin
			case(current_state)
				INIT:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				IDLE:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				WRITE_FROMCON:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				WRITE_FROMCON_END:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				READ_CON:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				READ_CON_END:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				WRITE_BUFFERTODDR:
					begin
						we_ToDDR=1'b1;
						re_ToDDR=1'b0;
					end
				WRITE_BUFFERTODDR_WAIT:
					begin
						we_ToDDR=1'b1;
						re_ToDDR=1'b0;
					end
				WRITE_BUFFERTODDR_END:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				WRITE_DDRTOBUFFER:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b1;
					end
				WRITE_DDRTOBUFFER_WAIT:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b1;
					end
				WRITE_DDRTOBUFFER_END:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
				default:
					begin
						we_ToDDR=1'b0;
						re_ToDDR=1'b0;
					end
			endcase
		end	
	//---------------------------------------------------------
	always @(*)
		begin
			case(current_state)
				INIT:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_FROMCON:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_FROMCON_END:
					begin
						sig_BufferWriteOK=1'b1;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				READ_CON:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				READ_CON_END:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b1;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_BUFFERTODDR:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_BUFFERTODDR_WAIT:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_BUFFERTODDR_ADDADDR:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_BUFFERTODDR_END:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b1;
						sig_DDRReadOK=1'b0;
					end
				WRITE_DDRTOBUFFER:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_DDRTOBUFFER_WAIT:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b0;
					end
				WRITE_DDRTOBUFFER_ADDADDR:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b1;
					end
				WRITE_DDRTOBUFFER_END:
					begin
						sig_BufferWriteOK=1'b0;
						sig_BufferReadOK=1'b0;
						sig_DDRWriteOK=1'b0;
						sig_DDRReadOK=1'b1;
					end
				default:
					begin
						//do nothing
					end
			endcase
		end	
endmodule
