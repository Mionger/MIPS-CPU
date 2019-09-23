`timescale 1ns / 1ps
module FA
(
	iA,
	iB,
	iC,
	oS,
	oP,
    oG
);

    input iA;
	input iB;
	input iC;

	output oS;
	output oP;
    output oG;

	assign oG=iA&iB;
	assign oP=iA|iB;
	assign oS=iA^iB^iC;
    
endmodule
