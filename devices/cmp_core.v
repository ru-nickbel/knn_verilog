module cmp_core(clk, inSA, inLA, inSB, inLB, outSMIN, outLMIN, outSMAX, outLMAX);
//Copmparity core

parameter SUM_LEN = 10;
parameter LBL_LEN = 10;

input clk;

input [SUM_LEN-1 : 0] inSA; //left sum and label
input [LBL_LEN-1 : 0] inLA;
input [SUM_LEN-1 : 0] inSB; //top sum and label
input [LBL_LEN-1 : 0] inLB;

output [SUM_LEN-1 : 0] outSMIN; //bottom 
output [LBL_LEN-1 : 0] outLMIN;
output [SUM_LEN-1 : 0] outSMAX; //right
output [LBL_LEN-1 : 0] outLMAX;

reg [SUM_LEN-1 : 0] dXMIN;
assign outSMIN = dXMIN;

reg [LBL_LEN-1 : 0] dLMIN;
assign outLMIN = dLMIN;

reg [SUM_LEN-1 : 0] dXMAX;
assign outSMAX = dXMAX;

reg [LBL_LEN-1 : 0] dLMAX;
assign outLMAX = dLMAX;

always @(posedge clk)
begin
	if (inSA > inSB)
	begin
		dXMAX = inSA;
		dLMAX = inLA;
		
		dXMIN = inSB;
		dLMIN = inLB;
	end 
	else
	begin
		dXMAX = inSB;
		dLMAX = inLB;
		
		dXMIN = inSA;
		dLMIN = inLA;
	end
end
endmodule
