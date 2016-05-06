module sm_systole(clk, dclk, enaV, inV, inL, outS, outL);

parameter SUM_LEN = 10;
parameter WORD_LEN = 6;
parameter LBL_LEN = 10;
parameter VECT_NUM = 6;
parameter VECT_LEN = 4;

input clk;

input [VECT_NUM-1 : 0] dclk; //input for select vector during initialization
input [WORD_LEN-1 : 0] inV [VECT_LEN-1 : 0]; //input for argument-vector
input [LBL_LEN-1 : 0] inL; //input for label setup during initialization

output [SUM_LEN-1 : 0] outS [VECT_NUM-1 : 0]; //sum outputs for vectors
output [LBL_LEN-1 : 0] outL [VECT_NUM-1 : 0]; //label outputs for vectors

input enaV; //enabling argument changes

reg [WORD_LEN-1 : 0] arg [VECT_LEN-1 : 0]; //registers with vector-argument

always @(posedge clk) begin
	if (enaV == 1) 
		arg <= inV; //if argument changing enabled, write to argument
end

generate
	genvar i;
	
	//module sm_col(clk, dclk, inV, inL, outV, outS, outL);
	for (i = 0; i < VECT_NUM; i = i + 1) begin : COL
		wire [WORD_LEN-1 : 0] yconn [VECT_LEN-1 : 0]; //horizontal connections between columns

		if (i == 0)
			sm_col #(VECT_LEN, WORD_LEN, SUM_LEN, LBL_LEN) col_inst (clk, dclk[i], arg, inL, yconn, outS[i], outL[i]);	
		else
			sm_col #(VECT_LEN, WORD_LEN, SUM_LEN, LBL_LEN) col_inst (clk, dclk[i], COL[i-1].yconn, inL, yconn, outS[i], outL[i]);
	end	
endgenerate


endmodule
