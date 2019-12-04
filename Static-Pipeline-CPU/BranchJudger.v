module BranchJudger
(
    rs_data,
    rt_data,
    branch_ena,
    id_branch
);
    input [31:0]rs_data;
    input [31:0]rt_data;
    input [3:0]branch_ena;
    output reg id_branch;

    always @(*) begin
        case (branch_ena)
            //JR
            4'b0000:begin
                id_branch <= 1'b1;
            end 
            //J
            4'b0001:begin
                id_branch <= 1'b1;
            end 
            //JAL
            4'b0010:begin
                id_branch <= 1'b1;
            end 
            //BEQ
            4'b0011:begin
                if (rs_data == rt_data) begin
                    id_branch <= 1'b1;
                end 
                else begin
                    id_branch <= 1'b0;
                end
            end 
            //BNE
            4'b0100:begin
                if (rs_data != rt_data) begin
                    id_branch <= 1'b1;
                end 
                else begin
                    id_branch <= 1'b0;
                end
            end 
            //BGEZ
            4'b0101:begin
                if (rs_data > 32'd0) begin
                    id_branch <= 1'b1;
                end 
                else begin
                    id_branch <= 1'b0;
                end
            end 
            //JALR
            4'b0110:begin
                id_branch <= 1'b1;
            end 
            //BREAK
            4'b0111:begin
                id_branch <= 1'b1;
            end 
            //SYSCALL
            4'b1000:begin
                id_branch <= 1'b1;
            end 
            //ERET
            4'b1001:begin
                id_branch <= 1'b1;
            end 
            //TEQ
            4'b1010:begin
                if (rs_data == rt_data) begin
                    id_branch <= 1'b1;
                end 
                else begin
                    id_branch <= 1'b0;
                end
            end 
            default:begin
                id_branch <= 1'b0;
            end 
        endcase
    end

endmodule