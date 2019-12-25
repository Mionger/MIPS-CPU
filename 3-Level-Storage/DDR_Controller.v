`timescale 1ns / 1ps
module DDR_Controller
(
	input clk,
	input reset,
	
	input [4095:0] data_FromSD,//从SD来的数据
	output reg [4095:0] data_ToCache,//给cache的数�?
	input [4095:0] data_FromDDRBuffer,//给buffer的数�?
	output reg [4095:0] data_ToDDRBuffer,//从buffer读来的数�?
	
	input [31:0] addr_FromCache,//从cache来的数据地址
	output [31:0] addr_ToBuffer,//传给buffer的数据地址
	
	//以下4个为外界给control的ena控制信号
	input sig_ReadFromSD,//要求control从SD读数�?
	input sig_WriteToBuffer,//要求control向buffer写数�?
	input sig_ReadFromBuffer,//要求control从buffer读数�?
	input sig_WriteToCache,//要求control传数据给cache
	
	//以下4个为buffer给control的信�?
	input sig_FromBufferWriteOK,//buffer告诉control他写好了
	input sig_FromBufferReadOK,//buffer可读�?
	input sig_FromDDRWriteOK,//buffer已经写好ddr�?
	input sig_FromDDRReadOK,//buffer已经从ddr那里读完数据�?
	
	//control给buffer的ena使能
	output reg we_ConToBuffer,//buffer的读使能
	output reg re_ConFromBuffer,//buffer的写使能
	output reg we_BufferToDDR,//要求buffer给ddr的写使能
	output reg we_DDRToBuffer,//要求buffer向ddr的读使能
	
	//control给外界的信号
	output reg sig_ReadSD_OK,//读好sd的数据了
	output reg sig_WriteBuffer_OK,//写好buffer�?
	output reg sig_ReadBuffer_OK,//从buffer中读完了
	output reg sig_SendToCache_OK,//给cache的数据准备好�?
	output [6:0]state
);
	reg [4095:0] dataTemp;
	
	parameter INIT  = 7'd1;
    parameter IDLE  = 7'd2;
	
    parameter READ_SD = 7'd3;
    parameter READ_SD_END = 7'd4;
	
	parameter WRITE_TOBUFFER= 7'd5;
	parameter WRITE_TOBUFFER_WAIT= 7'd6;
	parameter WRITE_BUFFERTODDR=7'd14;
	parameter WRITE_BUFFERTODDR_WAIT=7'd15;
	parameter WRITE_TOBUFFER_END = 7'd7;
	
	parameter READ_FROMBUFFER = 7'd8;
	parameter READ_BUFFERFROMDDR=7'd16;
	parameter READ_BUFFERFROMDDR_WAIT=7'd17;
	parameter READ_FROMBUFFER_WAIT = 7'd9;
	parameter READ_FROMBUFFER_END = 7'd10;
	
	parameter WRITE_TOCACHE = 7'd11;
	parameter WRITE_TOCACHE_WAIT = 7'd12;
    parameter WRITE_TOCACHE_END = 7'd13;
	
	reg [6:0]current_state = INIT;
    reg [6:0]next_state = INIT;
	assign state = current_state;
	//--------------------------------------------------------------
	assign addr_ToBuffer=addr_FromCache;
	//--------------------------------------------------------------
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
	//------------------------------------------------------------
	always @(*)
		begin
			case(current_state)
				INIT:
					begin
						next_state=IDLE;
					end
				IDLE:
					begin
						if(sig_ReadFromSD)
							begin
								next_state=READ_SD;
							end
						else if(sig_WriteToBuffer)
							begin
								next_state=WRITE_TOBUFFER;
							end
						else if(sig_ReadFromBuffer)
							begin
								next_state=READ_FROMBUFFER;
							end
						else if(sig_WriteToCache)
							begin
								next_state=WRITE_TOCACHE;
							end
						else
							begin
								next_state=IDLE;
							end
					end
				READ_SD:
					begin
						next_state=READ_SD_END;
					end
				READ_SD_END:
					begin
						if(sig_ReadFromSD)
							next_state=READ_SD_END;
						else
							next_state=IDLE;
					end
				WRITE_TOBUFFER:
					begin
						next_state=WRITE_TOBUFFER_WAIT;
					end
				WRITE_TOBUFFER_WAIT:
					begin
						if(sig_FromBufferWriteOK)
							next_state=WRITE_BUFFERTODDR;
						else
							next_state=WRITE_TOBUFFER_WAIT;
					end
				WRITE_BUFFERTODDR:
					begin
						next_state=WRITE_BUFFERTODDR_WAIT;
					end
				WRITE_BUFFERTODDR_WAIT:
					begin
						if(sig_FromDDRWriteOK)
							next_state=WRITE_TOBUFFER_END;
						else
							next_state=WRITE_BUFFERTODDR_WAIT;
					end
				WRITE_TOBUFFER_END:
					begin
						if(sig_WriteToBuffer)
							next_state=WRITE_TOBUFFER_END;
						else
							next_state=IDLE;
					end
				READ_FROMBUFFER:
					begin
						next_state=READ_BUFFERFROMDDR;
					end
				READ_BUFFERFROMDDR:
					begin
						next_state=READ_BUFFERFROMDDR_WAIT;
					end
				READ_BUFFERFROMDDR_WAIT:
					begin
						if(sig_FromDDRReadOK)
							next_state=READ_BUFFERFROMDDR_WAIT;
						else
							next_state=READ_FROMBUFFER_WAIT;
					end
				READ_FROMBUFFER_WAIT:
					begin
						next_state=READ_FROMBUFFER_END;
					end
				READ_FROMBUFFER_END:
					begin
						if(sig_ReadFromBuffer)
							next_state=READ_FROMBUFFER_END;
						else
							next_state=IDLE;
					end
				WRITE_TOCACHE:
					begin
						next_state=WRITE_TOCACHE_WAIT;
					end
				WRITE_TOCACHE_WAIT:
					begin
						next_state=WRITE_TOCACHE_END;
					end
				WRITE_TOCACHE_END:
					begin
						if(sig_WriteToCache)
							next_state=WRITE_TOCACHE_END;
						else
							next_state=IDLE;
					end
				default:
					begin
						next_state=INIT;
					end
			endcase
		end
	//-----------------------------------------------------------------
	always @(*)
		begin
			case(current_state)
				READ_SD:
					begin
						dataTemp=data_FromSD;
					end
				WRITE_TOBUFFER:
					begin
						data_ToDDRBuffer=dataTemp;
					end
				WRITE_TOBUFFER_WAIT:
					begin
						data_ToDDRBuffer=dataTemp;
					end
				READ_FROMBUFFER:
					begin
						dataTemp=data_FromDDRBuffer;
					end
				READ_FROMBUFFER_WAIT:
					begin
						dataTemp=data_FromDDRBuffer;
					end
				WRITE_TOCACHE:
					begin
						data_ToCache=dataTemp;
					end
				WRITE_TOCACHE_WAIT:
					begin
						data_ToCache=dataTemp;
					end
				default:
					begin
						
					end
			endcase
		end
	//----------------------------------------------------------
	always @(*)
		begin
			case(current_state)
				INIT:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				IDLE:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				READ_SD:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				READ_SD_END:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				WRITE_TOBUFFER:
					begin
						we_ConToBuffer=1'b1;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				WRITE_TOBUFFER_WAIT:
					begin
						we_ConToBuffer=1'b1;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				WRITE_BUFFERTODDR:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b1;
						we_DDRToBuffer=1'b0;
					end
				WRITE_BUFFERTODDR_WAIT:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b1;
						we_DDRToBuffer=1'b0;
					end
				WRITE_TOBUFFER_END:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				READ_FROMBUFFER:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b1;
					end
				READ_BUFFERFROMDDR:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b1;
					end
				READ_BUFFERFROMDDR_WAIT:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b1;
					end
				READ_FROMBUFFER_WAIT:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b1;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				READ_FROMBUFFER_END:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				WRITE_TOCACHE:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				WRITE_TOCACHE_WAIT:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				WRITE_TOCACHE_END:
					begin
						we_ConToBuffer=1'b0;
						re_ConFromBuffer=1'b0;
						we_BufferToDDR=1'b0;
						we_DDRToBuffer=1'b0;
					end
				default:
					begin
						
					end
			endcase
		end
	//-------------------------------------------------------
	always @(*)
		begin
			case(current_state)
				INIT:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				IDLE:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				READ_SD:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				READ_SD_END:
					begin
						sig_ReadSD_OK=1'b1;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_TOBUFFER:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_TOBUFFER_WAIT:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_BUFFERTODDR:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_BUFFERTODDR_WAIT:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_TOBUFFER_END:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b1;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				READ_FROMBUFFER:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				READ_BUFFERFROMDDR:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				READ_BUFFERFROMDDR_WAIT:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				READ_FROMBUFFER_WAIT:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				READ_FROMBUFFER_END:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b1;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_TOCACHE:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_TOCACHE_WAIT:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b0;
					end
				WRITE_TOCACHE_END:
					begin
						sig_ReadSD_OK=1'b0;
						sig_WriteBuffer_OK=1'b0;
						sig_ReadBuffer_OK=1'b0;
						sig_SendToCache_OK=1'b1;
					end
				default:
					begin
						
					end
			endcase
		end
	
endmodule