module INTERFACE_I
(
    ADDR,
    DMEM_OUT,
    VOL_OUT,
    SW_OUT,
    VOL_ENCODE,
    SW_TIME,
    BLUETOOTH_OUT,
    ROTATION_OUT,
    MP3_SW_OUT,
    SWITCH_OUT,
    MP3_VOL_OUT,
    TIME_OUT,
    SD_OUT,
    SD_STATUS,
    DATA_R
);
    input [31:0]ADDR;
    input [31:0]DMEM_OUT;
    input [31:0]VOL_OUT;
    input [31:0]SW_OUT;
    input [31:0]VOL_ENCODE;
    input [31:0]SW_TIME;
    input [31:0]BLUETOOTH_OUT;
    input [31:0]ROTATION_OUT;
    input [31:0]MP3_SW_OUT;
    input [31:0]SWITCH_OUT;
    input [31:0]MP3_VOL_OUT;
    input [31:0]TIME_OUT;
    input [31:0]SD_OUT;
    input [31:0]SD_STATUS;

    output reg [31:0]DATA_R;

    always @(*) begin
        //外设
        if(ADDR[11]==1'b1)begin
            case (ADDR[11:0])
                12'h800:DATA_R <= VOL_OUT; 
                12'h808:DATA_R <= SW_OUT;
                12'h810:DATA_R <= VOL_ENCODE;
                12'h814:DATA_R <= SW_TIME;
                12'h820:DATA_R <= BLUETOOTH_OUT;
                12'h824:DATA_R <= ROTATION_OUT;
                12'h828:DATA_R <= MP3_SW_OUT;
                12'h82c:DATA_R <= SWITCH_OUT;
                12'h830:DATA_R <= MP3_VOL_OUT;
                12'h834:DATA_R <= TIME_OUT;
                12'h838:DATA_R <= SD_OUT;
                12'h83c:DATA_R <= SD_STATUS;
                default:DATA_R <= DMEM_OUT;
            endcase
        end
        //DMEM
        else begin
            DATA_R <= DMEM_OUT;
        end
    end


endmodule