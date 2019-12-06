`timescale 1ns / 1ps
module ddr2_r(
    // system signals
    input sys_rst,
    input clk_ref_i,
    input sys_clk_i,
    input [26:0] app_addr,
    input app_en,
    input app_wdf_wren,
    input app_wdf_end,
    input [2:0]app_cmd,
    input [127:0] app_wdf_data,
    output [127:0] app_rd_data,
    output app_rdy,
    output app_rd_data_end,
    output app_rd_data_valid,
    output app_wdf_rdy,
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
    output [0:0]            ddr2_odt
);
    parameter DQ_WIDTH          = 16;
    parameter ECC_TEST          = "OFF";
    parameter ADDR_WIDTH        = 27;
    parameter nCK_PER_CLK       = 4;   
    localparam DATA_WIDTH       = 16;
    localparam PAYLOAD_WIDTH    = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
    localparam APP_DATA_WIDTH   = 2 * nCK_PER_CLK * PAYLOAD_WIDTH;
    localparam APP_MASK_WIDTH   = APP_DATA_WIDTH / 8;    
    
    my_ddr ddr2_0 (
        // Memory interface ports
        .ddr2_cs_n                  (ddr2_cs_n),
        .ddr2_addr                  (ddr2_addr),
        .ddr2_ba                    (ddr2_ba),
        .ddr2_we_n                  (ddr2_we_n),
        .ddr2_ras_n                 (ddr2_ras_n),
        .ddr2_cas_n                 (ddr2_cas_n),
        .ddr2_ck_n                  (ddr2_ck_n),
        .ddr2_ck_p                  (ddr2_ck_p),
        .ddr2_cke                   (ddr2_cke),
        .ddr2_dq                    (ddr2_dq),
        .ddr2_dqs_n                 (ddr2_dqs_n),
        .ddr2_dqs_p                 (ddr2_dqs_p),
        .ddr2_dm                    (ddr2_dm),
        .ddr2_odt                   (ddr2_odt),
        // Application interface ports
        .app_addr                   (app_addr),
        .app_cmd                    (app_cmd),
        .app_en                     (app_en),
        .app_wdf_rdy                (app_wdf_rdy),
        .app_wdf_data               (app_wdf_data),
        .app_wdf_end                (app_wdf_end),
        .app_wdf_wren               (app_wdf_wren),
        .app_rd_data                (app_rd_data),
        .app_rd_data_end            (app_rd_data_end),
        .app_rd_data_valid          (app_rd_data_valid),
        .app_rdy                    (app_rdy),
        .app_sr_req                 (1'b0),
        .app_ref_req                (1'b0),
        .app_zq_req                 (1'b0),
        .app_wdf_mask               (16'h0000),
        .init_calib_complete        (init_calib_complete),
        // System Clock Ports
        .sys_clk_i                  (sys_clk_i),
        // Reference Clock Ports
        .clk_ref_i                  (clk_ref_i),
        .sys_rst                    (~sys_rst)
    );    
endmodule
