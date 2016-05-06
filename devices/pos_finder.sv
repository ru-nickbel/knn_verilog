module pos_finder(clk, inL, x, y);
//Вычислитель средних координат на основе К меток

parameter LBL_LEN = 10;
parameter K_NUM = 5;




input clk;

//Входы для меток
input [LBL_LEN-1 : 0] inL [K_NUM-1 : 0];

//Выходные координаты
output [LBL_LEN/2-1 : 0] x;
output [LBL_LEN/2-1 : 0] y;


genvar i;

generate
//module pos_core (clk, inL, inXPrev, inYPrev, outXSum, outYSum);
	for (i = 0; i < K_NUM; i = i + 1) begin: SUM
	
			wire [$clog2((2**(LBL_LEN/2)-1)*K_NUM)-1 : 0] xconn;
			wire [$clog2((2**(LBL_LEN/2)-1)*K_NUM)-1 : 0] yconn;
			pos_core #(LBL_LEN, $clog2((2**(LBL_LEN/2)-1)*K_NUM)) csm_inst(clk, inL[i], (i==0)? 0 : SUM[i-1].xconn, (i==0)? 0 : SUM[i-1].yconn, xconn, yconn);
	end

	
endgenerate

assign x = SUM[K_NUM-1].xconn/K_NUM;
assign y = SUM[K_NUM-1].yconn/K_NUM;
endmodule
