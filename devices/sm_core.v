module sm_core (inV, inS, outV, outS, clk, dclk);
//Sum core

parameter SUM_LEN = 10;
parameter WORD_LEN = 6;

input clk;

input  [WORD_LEN-1 : 0] inV; //left arg input
input  [SUM_LEN-1 : 0] inS;	//sum input from top
output [WORD_LEN-1 : 0] outV; //right arg outpu
output [SUM_LEN-1 : 0] outS; //sum output to bottom

reg  [WORD_LEN-1 : 0] stor; //reg for stored value
reg  [SUM_LEN-1 : 0] rgS; //sum register
wire [WORD_LEN : 0] absstor; //wire for absolute value


assign absstor = (stor > inV)?(stor - inV):(inV - stor); 


always @(posedge clk) begin
	//write to sum register sum from top with absolute value of different between stored and arg values
	rgS <= absstor + inS;
end

assign outV = inV; 
assign outS = rgS;


input dclk; //initialization enabled input

always @(posedge clk) begin
	if (dclk == 1)
		stor <= inV; //store value from left output
end

endmodule
