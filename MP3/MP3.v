module MP3
(
    CLK,

    RESET,

    MP3_RSET,
    MP3_CS,
    MP3_DCS,

    MP3_MOSI,
    MP3_MISO,
    MP3_SCLK,
    MP3_DREQ,
    
    ROTATION_SW,
    ROTATION_SIA,
    ROTATION_SIB,

    UART_RXD,

    SEG_DISPLAY_DOT,
    SEG_DISPLAY_SHF,
    SEG_DISPLAY_DO,

    LED,

    SWITCH,

    SD_CLK,
    SD_DI,
    SD_DO,
    SD_CS
);
    input CLK;

    input RESET;

    output reg MP3_RSET=1;
    output reg MP3_CS=1;
    output reg MP3_DCS=1;
    output reg MP3_MOSI=0;
    input MP3_MISO;
    output reg MP3_SCLK=0;
    input MP3_DREQ;

    input ROTATION_SW;
    input ROTATION_SIA;
    input ROTATION_SIB;

    input UART_RXD;

    output SEG_DISPLAY_DOT;
    output [7:0] SEG_DISPLAY_SHF;
    output [6:0] SEG_DISPLAY_DO;

    output [15:0] LED;

    input [14:0]SWITCH;

    input SD_DO;
    output SD_CLK;
    output SD_CS;
    output SD_DI;
    
    //分频
    wire clk_mp3;
    wire clk_cpu;
    wire clk_sd;
    Divider #(100) divider_mp3(CLK,clk_mp3);
    Divider #(8)   divider_cpu(CLK,clk_cpu);
    Divider #(2)   divider_sd(CLK, clk_sd );

    //IMEM
    wire [31:0]inst;
    wire [31:0]pc_real;
    reg [31:0]pc;
    imem myimem
    (
        .a(pc_real[12:2]),
        .spo(inst)
    );
    assign pc_real = pc - 32'h00400000;

    //CPU
    wire [31:0]pc_out;
    wire [31:0]addr;
    wire [31:0]cpu_data_in;
    wire [31:0]cpu_data_out;
    wire we;
    wire [3:0]current_state;
    wire [3:0]next_state;
    CPU cpu
    (
        clk_cpu,
        ~RESET,
        inst,
        pc_out,
        addr,
        cpu_data_in,
        cpu_data_out,
        we,
        current_state,
        next_state
    );
    always @(posedge clk_cpu or negedge RESET) begin
        if(~RESET) begin
            pc <= 32'h00400000;
        end
        else if(next_state == 4'b0001) begin
            pc <= pc_out;
        end
        else begin
            pc <= pc;
        end
    end

    //DMEM
    wire dmem_we;
    wire [31:0]dmem_out;
    dmem mydmem
    (
        .clk(clk_cpu),
        .we(dmem_we),
        .addr(addr[10:0]),
        .wdata(cpu_data_out),
        .data_out(dmem_out)
    );

    //命令
    integer cnt=0;
    integer cmd_cnt=0;
    parameter cmd_cnt_max=4;
    reg [31:0] next_cmd;
    reg [127:0] cmd_init={32'h02000804,32'h02000804,32'h020B0000,32'h020000800};
    reg [127:0] cmd={32'h02000804,32'h02000804,32'h020B0000,32'h020000800};
    
    //时间显示
    wire [2:0] sw_out;
    reg [2:0]mp3_sw;
    wire [15:0] time_sec;
    wire seg_we;
    Time_Cnt time_cnt(clk_mp3,pos[14:0]==0,time_sec);
    Seg_Display seg_display(CLK,cpu_data_out,SEG_DISPLAY_DO,SEG_DISPLAY_SHF,SEG_DISPLAY_DOT,seg_we);
    
    //蓝牙
    wire [2:0]bluetooth_prev;
    wire [2:0]bluetooth_next;
    wire bluetooth_up;
    wire bluetooth_down;
    wire [7:0]rxd_data;
    wire uart_rxd;
    Bluetooth bluetooth(CLK,RESET,UART_RXD,bluetooth_prev,bluetooth_next,bluetooth_up,bluetooth_down,rxd_data,sw_out);//
    
    //音量
    wire [15:0]vol_out;
    reg [15:0]mp3_vol; 
    wire [1:0]dir;
    wire [15:0]vol_de;
    Rotation rotation(clk_mp3,ROTATION_SIA,ROTATION_SIB,ROTATION_SW,dir);

    wire up;
    wire down;
    assign up  = bluetooth_up   | dir[1];
    assign down= bluetooth_down | dir[0];
    wire vol_we;
    Vol_Set vol_set
    (
        CLK,
        // clk_mp3,
        up,
        down,
        vol_out,
        vol_we,
        cpu_data_out
    );
    Vol_Decoder vol_decoder(mp3_vol,vol_de);
    
    // LED
    wire led_we;
    reg [15:0]led;
    assign LED = led;
    
    //切换
    reg [2:0] pre_sw=0;
    wire [2:0]prev;
    wire [2:0]next;
    assign prev=bluetooth_prev;
    assign next=bluetooth_next;
    SW_Set sw_set(clk_mp3,prev,next,sw_out);

    //SD卡
    wire [4095:0]sd_data_w;
    wire [4095:0]sd_data_r;
    wire sd_we;
    wire [31:0]sd_status;
    //0 init_ok;
    //1 err;
    //2 write_end;
    //3 read_end;
    wire [15:0]sd_out;
    sd_top sd
    (
        CLK,
        SD_DO,
        ~RESET,
        16'd0,
        SD_CLK,
        SD_DI,
        SD_CS,
        sd_out,
        sd_status[0],
        sd_status[1]
    );

    //接口
    INTERFACE_I interface_i
    (
        addr,
        dmem_out,
        {16'd0, vol_out},
        {16'd0, sw_out},
        {16'd0, vol_de},
        {13'd0, mp3_sw, time_sec},
        {24'd0, bluetooth_up, bluetooth_down, bluetooth_prev, bluetooth_next},
        {30'd0, dir[1], dir[0]},
        {29'd0, mp3_sw},
        {16'd0, RESET, SWITCH},
        {16'd0, mp3_vol},
        {16'd0, time_sec},
        {16'd0, sd_out},
        sd_status,
        cpu_data_in
    );
    wire mp3_vol_we;
    wire mp3_sw_we;
    INTERFACE_O interface_o
    (
        addr,
        we,
        dmem_we,
        mp3_vol_we,
        mp3_sw_we,
        led_we,
        seg_we,
        vol_we,
        sd_we,
        sd_buffer_we
    );
    // assign LED = {15'b0, dmem_we}; //暂时没有检测到，等待重新检测
    
    //读取数据
    wire [15:0] data0;
    wire [15:0] data1;
    wire [15:0] data2;
    wire [15:0] data3;
    wire [15:0] data4;
    wire [15:0] data5;
    wire [15:0] data6;
    reg [15:0] data;
    reg [20:0] pos=0;
    blk_mem_gen_0 music_0(.clka(CLK),.wea(0),.addra(pos[12:0]),.dina(0),.douta(data0));
    blk_mem_gen_1 music_1(.clka(CLK),.wea(0),.addra(pos[12:0]),.dina(0),.douta(data1));
    blk_mem_gen_2 music_2(.clka(CLK),.wea(0),.addra(pos[12:0]),.dina(0),.douta(data2));
    blk_mem_gen_3 music_3(.clka(CLK),.wea(0),.addra(pos[12:0]),.dina(0),.douta(data3));
    blk_mem_gen_4 music_4(.clka(CLK),.wea(0),.addra(pos[12:0]),.dina(0),.douta(data4));
    blk_mem_gen_5 music_5(.clka(CLK),.wea(0),.addra(pos[12:0]),.dina(0),.douta(data5));
    blk_mem_gen_6 music_6(.clka(CLK),.wea(0),.addra(pos[12:0]),.dina(0),.douta(data6));

    parameter INITIALIZE  = 3'd0;
    parameter SEND_CMD    = 3'd1;
    parameter CHECK       = 3'd2;
    parameter DATA_SEND   = 3'd3;
    parameter RSET_OVER   = 3'd4;
    parameter VOL_SET_PRE = 3'd5;
    parameter VOL_SET     = 3'd6;


    reg[2:0] state=0;
    always @(negedge CLK) begin
        if(mp3_vol_we) begin
            mp3_vol <= cpu_data_out[15:0];
        end
        else begin
            mp3_vol <= mp3_vol;
        end
    end
    always @(negedge CLK) begin
        if(mp3_sw_we) begin
            mp3_sw <= cpu_data_out[15:0];
        end
        else begin
            mp3_sw <= mp3_sw;
        end
    end
    always @(negedge CLK) begin
        if(led_we) begin
            led <= cpu_data_out[15:0];
        end
        else begin
            led <= led;
        end
    end
    always @(posedge clk_mp3) begin
        pre_sw  <= mp3_sw;
        if(~RESET || pre_sw!=mp3_sw) begin
            MP3_RSET<=0;
            cmd_cnt<=0;
            state<=RSET_OVER;
            cmd<=cmd_init;
            MP3_SCLK<=0;
            MP3_CS<=1;
            MP3_DCS<=1;
            cnt<=0;
            pos<=0;
        end
        else begin
            case(state)
            INITIALIZE:begin
                MP3_SCLK<=0;
                if(cmd_cnt>=cmd_cnt_max) begin
                    state<=CHECK;
                end
                else if(MP3_DREQ) begin
                    MP3_CS<=0;
                    cnt<=1;
                    state<=SEND_CMD;
                    MP3_MOSI<=cmd[127];
                    cmd<={cmd[126:0],cmd[127]};
                end
            end
            SEND_CMD:begin
                if(MP3_DREQ) begin
                    if(MP3_SCLK) begin
                        if(cnt<32)begin
                            cnt<=cnt+1;
                            MP3_MOSI<=cmd[127];
                            cmd<={cmd[126:0],cmd[127]};
                        end
                        else begin
                            MP3_CS<=1;
                            cnt<=0;
                            cmd_cnt<=cmd_cnt+1;
                            state<=INITIALIZE;
                        end
                    end
                    MP3_SCLK<=~MP3_SCLK;
                end
            end
            CHECK:begin
                if(mp3_vol[15:0]!=cmd_init[47:32]) begin
                    state<=VOL_SET_PRE;
                    next_cmd<={16'h020B,mp3_vol[15:0]};
                end
                else if(MP3_DREQ) begin
                    MP3_DCS<=0;
                    MP3_SCLK<=0;
                    state<=DATA_SEND;
                    case (mp3_sw)
                        3'd0:begin
                            data<={data0[14:0],data0[15]};
                            MP3_MOSI<=data0[15];
                        end
                        3'd1:begin
                            data<={data1[14:0],data1[15]};
                            MP3_MOSI<=data1[15];
                        end
                        3'd2:begin
                            data<={data2[14:0],data2[15]};
                            MP3_MOSI<=data2[15];
                        end
                        3'd3:begin
                            data<={data3[14:0],data3[15]};
                            MP3_MOSI<=data3[15];
                        end
                        3'd4:begin
                            data<={data4[14:0],data4[15]};
                            MP3_MOSI<=data4[15];
                        end
                        3'd5:begin
                            data<={data5[14:0],data5[15]};
                            MP3_MOSI<=data5[15];
                        end
                        3'd6:begin
                            data<={data6[14:0],data6[15]};
                            MP3_MOSI<=data6[15];
                        end 
                        default:begin
                            data<={data0[14:0],data0[15]};
                            MP3_MOSI<=data0[15];
                        end 
                    endcase
                    
                    cnt<=1;
                end
                cmd_init[47:32]<=mp3_vol;
            end
            DATA_SEND:begin 
                if(MP3_SCLK)begin
                    if(cnt<16)begin
                        cnt<=cnt+1;
                        MP3_MOSI<=data[15];
                        data<={data[14:0],data[15]};
                    end
                    else begin
                        MP3_DCS<=1;
                        pos<=pos+1;
                        state<=CHECK;
                    end
                end
                MP3_SCLK<=~MP3_SCLK;
            end
            RSET_OVER:begin
                if(cnt<1000000) begin
                    cnt<=cnt+1;
                end
                else begin
                    cnt<=0;
                    state<=INITIALIZE;
                    MP3_RSET<=1;
                end
            end
            VOL_SET_PRE:begin
                if(MP3_DREQ) begin
                    MP3_CS<=0;
                    cnt<=1;
                    state<=VOL_SET;
                    MP3_MOSI<=next_cmd[31];
                    next_cmd<={next_cmd[30:0],next_cmd[31]};
                end
            end
            VOL_SET:begin
                if(MP3_DREQ) begin
                    if(MP3_SCLK) begin
                        if(cnt<32)begin
                            cnt<=cnt+1;
                            MP3_MOSI<=next_cmd[31];
                            next_cmd<={next_cmd[30:0],next_cmd[31]};
                        end
                        else begin
                            MP3_CS<=1;
                            cnt<=0;
                            state<=CHECK;
                        end
                    end
                    MP3_SCLK<=~MP3_SCLK;
                end
            end
            endcase
        end
    end
endmodule



