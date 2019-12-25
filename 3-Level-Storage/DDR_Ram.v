`timescale 1ns / 1ps
module DDR2_Ram
(
    input clk200,//利用倍频ip核生成
    input clk333,//利用倍频ip核生成
    input reset,
    input we,
    input re,
    input [23:0]addr,
    input [127:0]wdata,
    output reg [127:0]rdata,
    output reg wend,
    output reg rend,

    // DDR2 chip signals
    inout [15:0]            ddr2_dq,
    inout [1:0]             ddr2_dqs_n,
    inout [1:0]             ddr2_dqs_p,
    output [12:0]           ddr2_addr,
    output [2:0]            ddr2_ba,
    output                  ddr2_ras_n,
    output                  ddr2_cas_n,
    output                  ddr2_we_n,
    output [0:0]            ddr2_ck_p,
    output [0:0]            ddr2_ck_n,
    output [0:0]            ddr2_cke,
    output [0:0]            ddr2_cs_n,
    output [1:0]            ddr2_dm,
    output [0:0]            ddr2_odt,

    output [2:0] state
);

    //标准工作频率 200Mhz 333Mhz
    // wire clk200, clk250, clk333;
    // clk_wiz_0 cw0(.clk_in1(clk100), .clk_out1(clk200), .clk_out2(clk250), .clk_out3(clk333));

    //ddr ip核接口，信号和指令
    wire [127:0]odata;
    wire app_rdy;
    wire app_rd_data_end;
    wire app_rd_data_valid;
    wire app_wdf_rdy;
    reg [2:0]cmd = 3'b1; //write0 read1
    reg app_en = 1'b0;
    reg app_wdf_wren = 1'b0;
    reg app_wdf_end = 1'b0;

    //状态机状态
    parameter INIT = 3'b000;
    parameter IDLE = 3'b001;
    parameter WRITE = 3'b011;
    parameter WRITE_WAIT = 3'b010;
    parameter WRITE_END = 3'b110;
    parameter READ = 3'b111;
    parameter READ_WAIT = 3'b101;
    parameter READ_END = 3'b100;

    //状态转移
    reg [2:0]current_state = INIT;
    reg [2:0]next_state = INIT;
    assign state = current_state;

    reg init_cnt_en = 1'b0; // 由状态机提供
    reg [23:0]init_cnt = 24'b0;
    always @(posedge clk333 or posedge reset) begin
        if(reset) begin
            init_cnt <= 24'b0;
        end else begin
            if(init_cnt_en) begin
                if(init_cnt[23]) begin
                    init_cnt <= init_cnt;
                end else begin
                    init_cnt <= init_cnt + 1'b1;
                end
            end else begin
                init_cnt <= 24'b0;
            end
        end
    end

    reg exe_cnt_en = 1'b0; // 由状态机提供
    reg [16:0]exe_cnt = 17'b0;
    always @(posedge clk333 or posedge reset) begin
        if(reset) begin
            exe_cnt <= 17'b0;
        end else begin
            if(exe_cnt_en) begin
                if(exe_cnt[16]) begin
                    exe_cnt <= exe_cnt;
                end else begin
                    exe_cnt <= exe_cnt + 1'b1;
                end
            end else begin
                exe_cnt <= 17'b0;
            end
        end
    end

    reg wait_cnt_en = 1'b0; // 由状态机提供
    reg [16:0]wait_cnt = 17'b0;
    always @(posedge clk333 or posedge reset) begin
        if(reset) begin
            wait_cnt <= 17'b0;
        end else begin
            if(wait_cnt_en) begin
                if(wait_cnt[16]) begin
                    wait_cnt <= wait_cnt;
                end else begin
                    wait_cnt <= wait_cnt + 1'b1;
                end
            end else begin
                wait_cnt <= 17'b0;
            end
        end
    end

    always @(negedge clk333) begin
        if(current_state == READ && app_rd_data_valid) begin
            rdata <= odata;
        end else begin
            rdata <= rdata;
        end
    end

    always @(posedge clk333) begin
        current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            INIT: begin
                if(init_cnt[23]) begin
                    next_state = IDLE;
                end else begin
                    next_state = INIT;
                end
            end
            IDLE: begin
                if(re) begin
                    next_state = READ;
                end else if(we) begin
                    next_state = WRITE;
                end else begin
                    next_state = IDLE;
                end
            end
            WRITE: begin
                if(exe_cnt[16]) begin
                    next_state = WRITE_WAIT;
                end else begin
                    next_state = WRITE;
                end
            end
            WRITE_WAIT: begin
                if(wait_cnt[16]) begin
                    next_state = WRITE_END;
                end else begin
                    next_state = WRITE_WAIT;
                end
            end
            WRITE_END: begin
                if(we) begin 
                    next_state = WRITE_END;
                end else begin
                    next_state = IDLE;
                end
            end
            READ: begin
                if(exe_cnt[16]) begin
                    next_state = READ_WAIT;
                end else begin
                    next_state = READ;
                end
            end
            READ_WAIT: begin
                if(wait_cnt[16]) begin
                    next_state = READ_END;
                end else begin
                    next_state = READ_WAIT;
                end
            end
            READ_END: begin
                if(re) begin 
                    next_state = READ_END;
                end else begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = INIT;
            end
        endcase
    end

    always @(*) begin
        case(current_state)
            INIT: begin
                init_cnt_en = 1'b1;
                exe_cnt_en = 1'b0;
                wait_cnt_en = 1'b0;
            end
            WRITE: begin
                init_cnt_en = 1'b0;
                exe_cnt_en = 1'b1;
                wait_cnt_en = 1'b0;
            end
            WRITE_WAIT: begin
                init_cnt_en = 1'b0;
                exe_cnt_en = 1'b0;
                wait_cnt_en = 1'b1;
            end
            READ: begin
                init_cnt_en = 1'b0;
                exe_cnt_en = 1'b1;
                wait_cnt_en = 1'b0;
            end
            READ_WAIT: begin
                init_cnt_en = 1'b0;
                exe_cnt_en = 1'b0;
                wait_cnt_en = 1'b1;
            end
            default: begin
                init_cnt_en = 1'b0;
                exe_cnt_en = 1'b0;
                wait_cnt_en = 1'b0;
            end
        endcase
    end

    // reg [2:0]cmd = 3'b1; //write0 read1
    // reg app_en = 1'b0;
    // reg app_wdf_wren = 1'b0;
    // reg app_wdf_end = 1'b0;
    always @(*) begin
        case(current_state)
            WRITE: begin
                cmd = 3'b0;
                if(app_rdy && app_wdf_rdy) begin
                    app_en = 1'b1;
                    app_wdf_wren = 1'b1;
                    app_wdf_end = 1'b1;
                end else begin
                    app_en = 1'b0;
                    app_wdf_wren = 1'b0;
                    app_wdf_end = 1'b0;
                end
            end
            READ: begin
                cmd = 3'b1; 
                app_wdf_wren = 1'b0;
                app_wdf_end = 1'b0;
                if(app_rdy) begin
                    app_en = 1'b1;
                end else begin
                    app_en = 1'b0;
                end

            end
            default: begin
                cmd = 3'b1;
                app_wdf_wren = 1'b0;
                app_wdf_end = 1'b0;
                app_en = 1'b0;
            end
        endcase
    end

    always @(*) begin
        case(current_state)
            WRITE_END: begin
                wend = 1'b1;
                rend = 1'b0;
            end
            READ_END: begin
                wend = 1'b0;
                rend = 1'b1;
            end
            default: begin
                wend = 1'b0;
                rend = 1'b0;
            end
        endcase
    end

    ddr2_r dr(
        // system signals
        reset,
        clk200,
        clk333,
        {addr, 3'b0}, //input [26:0] app_addr,
        app_en, //input app_en,
        app_wdf_wren, //input app_wdf_wren,
        app_wdf_end, //input app_wdf_end,
        cmd, //input [2:0]app_cmd,
        wdata, //input [127:0] app_wdf_data,
        odata, //output [127:0] app_rd_data,
        app_rdy, //output app_rdy,
        app_rd_data_end, //output app_rd_data_end,
        app_rd_data_valid, //output app_rd_data_valid,
        app_wdf_rdy, //output app_wdf_rdy
        // DDR2 chip signals
        ddr2_dq, //inout [15:0]            ddr2_dq,
        ddr2_dqs_n, //inout [1:0]             ddr2_dqs_n,
        ddr2_dqs_p, //inout [1:0]             ddr2_dqs_p,
        ddr2_addr, //output [12:0]           ddr2_addr,
        ddr2_ba, //output [2:0]            ddr2_ba,
        ddr2_ras_n, //output                  ddr2_ras_n,
        ddr2_cas_n, //output                  ddr2_cas_n,
        ddr2_we_n, //output                  ddr2_we_n,
        ddr2_ck_p, //output [0:0]            ddr2_ck_p,
        ddr2_ck_n, //output [0:0]            ddr2_ck_n,
        ddr2_cke, //output [0:0]            ddr2_cke,
        ddr2_cs_n, //output [0:0]            ddr2_cs_n,
        ddr2_dm, //output [1:0]            ddr2_dm,
        ddr2_odt //output [0:0]            ddr2_odt
    );
endmodule
