`timescale 1ns / 1ps
module Cache_Controller
(
    clk,
    reset,
    state,

    cache_data_write,
    cache_we,
    cache_write_buffer_end,
    cache_page,

    data_to_cache,
    addr_to_cache
    we_to_cache
);
    input clk;
    input reset;
    input [4095:0]cache_data_write;
    input cache_we;
    input [1:0]cache_page;
    
    output [2:0]state;
    output cache_write_buffer_end;
    output [31:0]data_to_cache;
    output [8:0]addr_to_cache;
    output we_to_cache;

    reg cache_write_buffer_end;//
    reg we_to_cache;//

    reg [31:0]data_to_cache;
    reg [8:0]addr_to_cache;

    parameter IDLE = 3'd0;
    parameter PREPARE_ADDR = 3'd1;
    parameter PREPARE_DATA = 3'd2;
    parameter WRITE = 3'd3;
    parameter WRITE_END = 3'd4;
    reg [2:0]current_state = IDLE;
    reg [2:0]next_state = IDLE;
    assign state = current_state;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    reg [7:0]cnt;
    always @(*) begin
        case (current_state)
            IDLE: begin
                if(cache_we)begin
                    next_state <= TO_WRITE;
                    cnt <= 8'd0;
                end
                else begin
                    next_state <= IDLE;
                    cnt <= 8'd0;
                end
            end 
            PREPARE_ADDR: begin
                next_state <= PREPARE_DATA;
            end
            PREPARE_DATA: begin
                next_state <= WRITE;
            end
            WRITE: begin
                cnt <= cnt + 8'd1;
                if(cnt==8'd128)begin
                    next_state <= WRITE_END;
                end
                else begin
                    next_state <= PREPARE_ADDR;
                end
            end
            WRITE_END: begin
                next_state <= IDLE;
            end
            default:begin
                next_state <= IDLE;
            end 
        endcase
    end

    always @(*) begin
        case (current_state)
            WRITE_END: begin
                cache_write_buffer_end <= 1'b1;
            end 
            default: begin
                cache_write_buffer_end <= 1'b0;
            end 
        endcase
    end

    always @(*) begin
        case (current_state)
            WRITE: begin
                we_to_cache <= 1'b1;
            end 
            default: begin
                we_to_cache <= 1'b0;
            end 
        endcase
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                addr_to_cache <= 9'd0;
            end
            PREPARE_ADDR: begin
                addr_to_cache <= {cache_page,cnt[6:0]};
            end 
            default: begin
                addr_to_cache <= addr_to_cache;
            end 
        endcase
    end

    always @(*) begin
        case (current_state)
            PREPARE_DATA: begin
                case (cnt[6:0])
                    7'd0:begin
                        data_to_cache <= cache_data_write[31:0];
                    end
                    7'd1:begin
                        data_to_cache <= cache_data_write[63:32];
                    end
                    7'd2:begin
                        data_to_cache <= cache_data_write[95:64];
                    end
                    7'd3:begin
                        data_to_cache <= cache_data_write[127:96];
                    end
                    7'd4:begin
                        data_to_cache <= cache_data_write[159:128];
                    end
                    7'd5:begin
                        data_to_cache <= cache_data_write[191:160];
                    end
                    7'd6:begin
                        data_to_cache <= cache_data_write[223:192];
                    end
                    7'd7:begin
                        data_to_cache <= cache_data_write[255:224];
                    end
                    7'd8:begin
                        data_to_cache <= cache_data_write[287:256];
                    end
                    7'd9:begin
                        data_to_cache <= cache_data_write[319:288];
                    end
                    7'd10:begin
                        data_to_cache <= cache_data_write[351:320];
                    end
                    7'd11:begin
                        data_to_cache <= cache_data_write[383:352];
                    end
                    7'd12:begin
                        data_to_cache <= cache_data_write[415:384];
                    end
                    7'd13:begin
                        data_to_cache <= cache_data_write[447:416];
                    end
                    7'd14:begin
                        data_to_cache <= cache_data_write[479:448];
                    end
                    7'd15:begin
                        data_to_cache <= cache_data_write[511:480];
                    end
                    7'd16:begin
                        data_to_cache <= cache_data_write[543:512];
                    end
                    7'd17:begin
                        data_to_cache <= cache_data_write[575:544];
                    end
                    7'd18:begin
                        data_to_cache <= cache_data_write[607:576];
                    end
                    7'd19:begin
                        data_to_cache <= cache_data_write[639:608];
                    end
                    7'd20:begin
                        data_to_cache <= cache_data_write[671:640];
                    end
                    7'd21:begin
                        data_to_cache <= cache_data_write[703:672];
                    end
                    7'd22:begin
                        data_to_cache <= cache_data_write[735:704];
                    end
                    7'd23:begin
                        data_to_cache <= cache_data_write[767:736];
                    end
                    7'd24:begin
                        data_to_cache <= cache_data_write[799:768];
                    end
                    7'd25:begin
                        data_to_cache <= cache_data_write[831:800];
                    end
                    7'd26:begin
                        data_to_cache <= cache_data_write[863:832];
                    end
                    7'd27:begin
                        data_to_cache <= cache_data_write[895:864];
                    end
                    7'd28:begin
                        data_to_cache <= cache_data_write[927:896];
                    end
                    7'd29:begin
                        data_to_cache <= cache_data_write[959:928];
                    end
                    7'd30:begin
                        data_to_cache <= cache_data_write[991:960];
                    end
                    7'd31:begin
                        data_to_cache <= cache_data_write[1023:992];
                    end
                    7'd32:begin
                        data_to_cache <= cache_data_write[1055:1024];
                    end
                    7'd33:begin
                        data_to_cache <= cache_data_write[1087:1056];
                    end
                    7'd34:begin
                        data_to_cache <= cache_data_write[1119:1088];
                    end
                    7'd35:begin
                        data_to_cache <= cache_data_write[1151:1120];
                    end
                    7'd36:begin
                        data_to_cache <= cache_data_write[1183:1152];
                    end
                    7'd37:begin
                        data_to_cache <= cache_data_write[1215:1184];
                    end
                    7'd38:begin
                        data_to_cache <= cache_data_write[1247:1216];
                    end
                    7'd39:begin
                        data_to_cache <= cache_data_write[1279:1248];
                    end
                    7'd40:begin
                        data_to_cache <= cache_data_write[1311:1280];
                    end
                    7'd41:begin
                        data_to_cache <= cache_data_write[1343:1312];
                    end
                    7'd42:begin
                        data_to_cache <= cache_data_write[1375:1344];
                    end
                    7'd43:begin
                        data_to_cache <= cache_data_write[1407:1376];
                    end
                    7'd44:begin
                        data_to_cache <= cache_data_write[1439:1408];
                    end
                    7'd45:begin
                        data_to_cache <= cache_data_write[1471:1440];
                    end
                    7'd46:begin
                        data_to_cache <= cache_data_write[1503:1472];
                    end
                    7'd47:begin
                        data_to_cache <= cache_data_write[1535:1504];
                    end
                    7'd48:begin
                        data_to_cache <= cache_data_write[1567:1536];
                    end
                    7'd49:begin
                        data_to_cache <= cache_data_write[1599:1568];
                    end
                    7'd50:begin
                        data_to_cache <= cache_data_write[1631:1600];
                    end
                    7'd51:begin
                        data_to_cache <= cache_data_write[1663:1632];
                    end
                    7'd52:begin
                        data_to_cache <= cache_data_write[1695:1664];
                    end
                    7'd53:begin
                        data_to_cache <= cache_data_write[1727:1696];
                    end
                    7'd54:begin
                        data_to_cache <= cache_data_write[1759:1728];
                    end
                    7'd55:begin
                        data_to_cache <= cache_data_write[1791:1760];
                    end
                    7'd56:begin
                        data_to_cache <= cache_data_write[1823:1792];
                    end
                    7'd57:begin
                        data_to_cache <= cache_data_write[1855:1824];
                    end
                    7'd58:begin
                        data_to_cache <= cache_data_write[1887:1856];
                    end
                    7'd59:begin
                        data_to_cache <= cache_data_write[1919:1888];
                    end
                    7'd60:begin
                        data_to_cache <= cache_data_write[1951:1920];
                    end
                    7'd61:begin
                        data_to_cache <= cache_data_write[1983:1952];
                    end
                    7'd62:begin
                        data_to_cache <= cache_data_write[2015:1984];
                    end
                    7'd63:begin
                        data_to_cache <= cache_data_write[2047:2016];
                    end
                    7'd64:begin
                        data_to_cache <= cache_data_write[2079:2048];
                    end
                    7'd65:begin
                        data_to_cache <= cache_data_write[2111:2080];
                    end
                    7'd66:begin
                        data_to_cache <= cache_data_write[2143:2112];
                    end
                    7'd67:begin
                        data_to_cache <= cache_data_write[2175:2144];
                    end
                    7'd68:begin
                        data_to_cache <= cache_data_write[2207:2176];
                    end
                    7'd69:begin
                        data_to_cache <= cache_data_write[2239:2208];
                    end
                    7'd70:begin
                        data_to_cache <= cache_data_write[2271:2240];
                    end
                    7'd71:begin
                        data_to_cache <= cache_data_write[2303:2272];
                    end
                    7'd72:begin
                        data_to_cache <= cache_data_write[2335:2304];
                    end
                    7'd73:begin
                        data_to_cache <= cache_data_write[2367:2336];
                    end
                    7'd74:begin
                        data_to_cache <= cache_data_write[2399:2368];
                    end
                    7'd75:begin
                        data_to_cache <= cache_data_write[2431:2400];
                    end
                    7'd76:begin
                        data_to_cache <= cache_data_write[2463:2432];
                    end
                    7'd77:begin
                        data_to_cache <= cache_data_write[2495:2464];
                    end
                    7'd78:begin
                        data_to_cache <= cache_data_write[2527:2496];
                    end
                    7'd79:begin
                        data_to_cache <= cache_data_write[2559:2528];
                    end
                    7'd80:begin
                        data_to_cache <= cache_data_write[2591:2560];
                    end
                    7'd81:begin
                        data_to_cache <= cache_data_write[2623:2592];
                    end
                    7'd82:begin
                        data_to_cache <= cache_data_write[2655:2624];
                    end
                    7'd83:begin
                        data_to_cache <= cache_data_write[2687:2656];
                    end
                    7'd84:begin
                        data_to_cache <= cache_data_write[2719:2688];
                    end
                    7'd85:begin
                        data_to_cache <= cache_data_write[2751:2720];
                    end
                    7'd86:begin
                        data_to_cache <= cache_data_write[2783:2752];
                    end
                    7'd87:begin
                        data_to_cache <= cache_data_write[2815:2784];
                    end
                    7'd88:begin
                        data_to_cache <= cache_data_write[2847:2816];
                    end
                    7'd89:begin
                        data_to_cache <= cache_data_write[2879:2848];
                    end
                    7'd90:begin
                        data_to_cache <= cache_data_write[2911:2880];
                    end
                    7'd91:begin
                        data_to_cache <= cache_data_write[2943:2912];
                    end
                    7'd92:begin
                        data_to_cache <= cache_data_write[2975:2944];
                    end
                    7'd93:begin
                        data_to_cache <= cache_data_write[3007:2976];
                    end
                    7'd94:begin
                        data_to_cache <= cache_data_write[3039:3008];
                    end
                    7'd95:begin
                        data_to_cache <= cache_data_write[3071:3040];
                    end
                    7'd96:begin
                        data_to_cache <= cache_data_write[3103:3072];
                    end
                    7'd97:begin
                        data_to_cache <= cache_data_write[3135:3104];
                    end
                    7'd98:begin
                        data_to_cache <= cache_data_write[3167:3136];
                    end
                    7'd99:begin
                        data_to_cache <= cache_data_write[3199:3168];
                    end
                    7'd100:begin
                        data_to_cache <= cache_data_write[3231:3200];
                    end
                    7'd101:begin
                        data_to_cache <= cache_data_write[3263:3232];
                    end
                    7'd102:begin
                        data_to_cache <= cache_data_write[3295:3264];
                    end
                    7'd103:begin
                        data_to_cache <= cache_data_write[3327:3296];
                    end
                    7'd104:begin
                        data_to_cache <= cache_data_write[3359:3328];
                    end
                    7'd105:begin
                        data_to_cache <= cache_data_write[3391:3360];
                    end
                    7'd106:begin
                        data_to_cache <= cache_data_write[3423:3392];
                    end
                    7'd107:begin
                        data_to_cache <= cache_data_write[3455:3424];
                    end
                    7'd108:begin
                        data_to_cache <= cache_data_write[3487:3456];
                    end
                    7'd109:begin
                        data_to_cache <= cache_data_write[3519:3488];
                    end
                    7'd110:begin
                        data_to_cache <= cache_data_write[3551:3520];
                    end
                    7'd111:begin
                        data_to_cache <= cache_data_write[3583:3552];
                    end
                    7'd112:begin
                        data_to_cache <= cache_data_write[3615:3584];
                    end
                    7'd113:begin
                        data_to_cache <= cache_data_write[3647:3616];
                    end
                    7'd114:begin
                        data_to_cache <= cache_data_write[3679:3648];
                    end
                    7'd115:begin
                        data_to_cache <= cache_data_write[3711:3680];
                    end
                    7'd116:begin
                        data_to_cache <= cache_data_write[3743:3712];
                    end
                    7'd117:begin
                        data_to_cache <= cache_data_write[3775:3744];
                    end
                    7'd118:begin
                        data_to_cache <= cache_data_write[3807:3776];
                    end
                    7'd119:begin
                        data_to_cache <= cache_data_write[3839:3808];
                    end
                    7'd120:begin
                        data_to_cache <= cache_data_write[3871:3840];
                    end
                    7'd121:begin
                        data_to_cache <= cache_data_write[3903:3872];
                    end
                    7'd122:begin
                        data_to_cache <= cache_data_write[3935:3904];
                    end
                    7'd123:begin
                        data_to_cache <= cache_data_write[3967:3936];
                    end
                    7'd124:begin
                        data_to_cache <= cache_data_write[3999:3968];
                    end
                    7'd125:begin
                        data_to_cache <= cache_data_write[4031:4000];
                    end
                    7'd126:begin
                        data_to_cache <= cache_data_write[4063:4032];
                    end
                    7'd127:begin
                        data_to_cache <= cache_data_write[4095:4064];
                    end
                endcase
            end 
            default: begin
                data_to_cache <= data_to_cache;
            end
        endcase
    end
endmodule
