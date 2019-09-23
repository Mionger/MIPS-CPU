module Vol_Set
(
    CLK,
    LEFT,
    RIGHT,
    VOL,
    WE,
    R
);
    input CLK;
    input LEFT;
    input RIGHT;
    input [15:0]R;
    input WE;
    output reg [15:0]VOL;

    integer vol_delay=0;
    always @(negedge CLK) begin
        if(WE)begin
            vol_delay<=10000000;
            VOL <= R;
        end
        else begin
            if(vol_delay==0) begin
                if(LEFT) begin
                    vol_delay<=10000000;
                    VOL<=(VOL==16'h0000)?16'h0000:(VOL-16'h1010);
                end
                else if(RIGHT) begin
                    vol_delay <= 10000000;
                    VOL<=(VOL==16'hf0f0)?16'hf0f0:(VOL+16'h1010);
                end
            end
            else begin
                vol_delay<=vol_delay-1;
            end
        end
    end
    
endmodule