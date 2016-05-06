module pos_core (clk, inL, inXPrev, inYPrev, outXSum, outYSum);

parameter LBL_LEN = 10;
parameter CSUM_LEN = 7;

input clk;
input [LBL_LEN-1 : 0] inL;
input [CSUM_LEN-1 : 0] inXPrev;
input [CSUM_LEN-1 : 0] inYPrev;

output [CSUM_LEN-1 : 0] outXSum;
output [CSUM_LEN-1 : 0] outYSum;

reg [CSUM_LEN-1 : 0] xsum;
reg [CSUM_LEN-1 : 0] ysum;

always @(posedge clk) begin
	xsum <= inXPrev + inL[LBL_LEN-1 : LBL_LEN/2]; //first part of label
	ysum <= inYPrev + inL[LBL_LEN/2-1 : 0]; //second part of label
end

assign outXSum = xsum;
assign outYSum = ysum;
 
endmodule
