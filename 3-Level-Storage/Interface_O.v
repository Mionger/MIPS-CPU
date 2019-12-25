module INTERFACE_O
(
    ADDR,
    WE,
    DMEM_WE,
    MP3_VOL_WE,
    MP3_SW_WE,
    LED_WE,
    SEG_WE,
    VOL_WE,
    SD_WE,
    SD_BUFFER_WE
);
    input [31:0]ADDR;
    input WE;

    output reg DMEM_WE;
    output reg MP3_VOL_WE;
    output reg MP3_SW_WE;
    output reg LED_WE;
    output reg SEG_WE;
    output reg VOL_WE;
    output reg SD_WE;
    output reg SD_BUFFER_WE;

    always @(*) begin
        // 外设
        if(ADDR[11]==1'b1)begin
            case (ADDR[11:0])
                // MP3_VOL
                12'h804:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= WE;
                    MP3_SW_WE <= 1'b0;
                    LED_WE <= 1'b0;
                    SEG_WE <= 1'b0;
                    VOL_WE <= 1'b0;
                    SD_BUFFER_WE <= 1'b0;
                    SD_WE <= 1'b0;
                end
                // MP3_SW
                12'h80c:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= 1'b0;
                    MP3_SW_WE <= WE;
                    LED_WE <= 1'b0;
                    SEG_WE <= 1'b0;
                    VOL_WE <= 1'b0;
                    SD_BUFFER_WE <= 1'b0;
                    SD_WE <= 1'b0;
                end
                // LED
                12'h818:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= 1'b0;
                    MP3_SW_WE <= 1'b0;
                    LED_WE <= WE;
                    SEG_WE <= 1'b0;
                    VOL_WE <= 1'b0;
                    SD_BUFFER_WE <= 1'b0;
                    SD_WE <= 1'b0;
                end
                // SEG
                12'h81c:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= 1'b0;
                    MP3_SW_WE <= 1'b0;
                    LED_WE <= 1'b0;
                    SEG_WE <= WE;
                    VOL_WE <= 1'b0;
                    SD_BUFFER_WE <= 1'b0;
                    SD_WE <= 1'b0;
                end
                // VOL
                12'h840:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= 1'b0;
                    MP3_SW_WE <= 1'b0;
                    LED_WE <= 1'b0;
                    SEG_WE <= 1'b0;
                    VOL_WE <= WE;
                    SD_BUFFER_WE <= 1'b0;
                    SD_WE <= 1'b0;
                end
                // SD_BUFFER
                12'h844:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= 1'b0;
                    MP3_SW_WE <= 1'b0;
                    LED_WE <= 1'b0;
                    SEG_WE <= 1'b0;
                    VOL_WE <= 1'b0;
                    SD_BUFFER_WE <= WE;
                    SD_WE <= 1'b0;
                end
                // SD
                12'h848:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= 1'b0;
                    MP3_SW_WE <= 1'b0;
                    LED_WE <= 1'b0;
                    SEG_WE <= 1'b0;
                    VOL_WE <= 1'b0;
                    SD_BUFFER_WE <= 1'b0;
                    SD_WE <= WE;
                end
                default:begin
                    DMEM_WE <= 1'b0;
                    MP3_VOL_WE <= 1'b0;
                    MP3_SW_WE <= 1'b0;
                    LED_WE <= 1'b0;
                    SEG_WE <= 1'b0;
                    VOL_WE <= 1'b0;
                    SD_BUFFER_WE <= 1'b0;
                    SD_WE <= 1'b0;
                end
            endcase
        end
        // DMEM
        else begin
            DMEM_WE <= WE;
            MP3_VOL_WE <= 1'b0;
            MP3_SW_WE <= 1'b0;
            LED_WE <= 1'b0;
            SEG_WE <= 1'b0;
            VOL_WE <= 1'b0;
            SD_BUFFER_WE <= 1'b0;
            SD_WE <= 1'b0;
        end
    end

endmodule