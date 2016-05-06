module sm_col(clk, dclk, inV, inL, outV, outS, outL);
//Vector of sum cores with register for label 

parameter VECT_LEN = 4; 
parameter WORD_LEN = 6;	  
parameter SUM_LEN = 10;	
parameter LBL_LEN = 10;   

input clk; 	
input dclk;	//write enable

input  [WORD_LEN-1 : 0] inV [VECT_LEN-1 : 0]; //input for other vector for initialize (if dclk) or compare
input  [LBL_LEN-1 : 0] inL;	//input for label initialization
output [WORD_LEN-1 : 0] outV [VECT_LEN-1 : 0]; //wire for copy inV signal to output
output [SUM_LEN-1 : 0] outS; //output with sum of differences between this vector's elements and inV's elements

output	[LBL_LEN-1 : 0] outL; //output for label
reg	[LBL_LEN-1 : 0] label; 	//label register

always @(posedge clk) begin
	if (dclk == 1)
		label <= inL; //label init
end


generate
	genvar i;
	
	for (i = 0; i < VECT_LEN; i = i+1) begin : ROW 
		wire [SUM_LEN-1 : 0] conn; //vertical connections
		if (i == 0)
			sm_core #(SUM_LEN, WORD_LEN) sm_inst(inV[i], 'b0, outV[i], conn, clk, dclk); //if sum core on the top, then set top input value to 0
		else 
			sm_core #(SUM_LEN, WORD_LEN) sm_inst(inV[i], ROW[i-1].conn, outV[i], conn, clk, dclk);
	end
endgenerate

assign outS = ROW[VECT_LEN-1].conn; //sum output from bottom sum core
assign outL = label; //output for stored label

endmodule
