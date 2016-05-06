module cmp_systole (clk, inS, inL, outS, outL);
//Систола сравнени¤

parameter SUM_LEN = 10;
parameter LBL_LEN = 10;
parameter K_NUM = 5;
parameter VECT_NUM = 15;

input clk;

input [SUM_LEN-1 : 0] inS [VECT_NUM-1 : 0]; //входы сумм
input [LBL_LEN-1 : 0] inL [VECT_NUM-1 : 0]; //входы меток

output [SUM_LEN-1 : 0] outS [K_NUM-1 : 0]; //выходы сумм
output [LBL_LEN-1 : 0] outL [K_NUM-1 : 0]; //выходы меток


genvar i, k;
//A - hor, B -vert, min - hor, max - vert
generate
	//module cmp_core(clk, inSA, inLA, inSB, inLB, outSMIN, outLMIN, outSMAX, outLMAX);
	for (k = 0; k < K_NUM; k = k + 1) begin : KROW
		wire [SUM_LEN-1 : 0] xmaxout [VECT_NUM-1 : 0]; //провода дл¤ максимумов (вертикаль)
		wire [LBL_LEN-1 : 0] lmaxout [VECT_NUM-1 : 0];
		
		for (i = k; i < VECT_NUM; i = i + 1) begin : KCOL
			wire [SUM_LEN-1 : 0] xminout; //провода дл¤ минимумов (горизонталь)
			wire [LBL_LEN-1 : 0] lminout;
			cmp_core #(SUM_LEN, LBL_LEN) cmp_inst (clk, 
						(i==k)? 2**SUM_LEN-1 : KCOL[i-1].xminout, (i==k)? 0 : KCOL[i-1].lminout, //крайний слева или нет
						(k==0)? inS[i] : KROW[k-1].xmaxout[i], (k==0)?  inL[i] : KROW[k-1].lmaxout[i], //верхний р¤д или нет 
						(i==VECT_NUM-1)? outS[k] : xminout, (i==VECT_NUM-1)? outL[k] : lminout, //крайний справа или нет
						xmaxout[i], lmaxout[i]
					);
		end		
	end
endgenerate

endmodule
