module sm_knn (clk, dclk, enaV, inV, inL, outS, outL, x, y);
//Сборка из суммирующей и сравнивающей систол и устройства подсчета средних координат

parameter VECT_NUM = 6;
parameter VECT_LEN = 4;
parameter WORD_LEN = 6;
parameter SUM_LEN = 10;
parameter LBL_LEN = 10;
parameter K_NUM = 5;

input clk;
input enaV; //разрешение записи в регистр аргумента суммирующей систолы
input[VECT_NUM-1 : 0] dclk; //определитель вектора для инициализации
input [WORD_LEN-1 : 0] inV [VECT_LEN-1 : 0]; //вход для аргумента
input [LBL_LEN-1 : 0] inL; //вход для метки

//отладочные выходы
output [SUM_LEN-1 : 0] outS [K_NUM-1 : 0]; //выход минимальных сумм
output [LBL_LEN-1 : 0] outL [K_NUM-1 : 0]; //выход соответстующих меток

output [LBL_LEN/2-1 : 0] x;
output [LBL_LEN/2-1 : 0] y;

//module sm_systole(clk, dclk, enaV, inV, inL, outS, outL);
wire [SUM_LEN-1 : 0] woutS [VECT_NUM-1 : 0]; //провода соединения систол друг с другом
wire [LBL_LEN-1 : 0] woutL [VECT_NUM-1 : 0];

sm_systole #(SUM_LEN,WORD_LEN,LBL_LEN,VECT_NUM,VECT_LEN) sm_sys_inst (clk, dclk, enaV, inV, inL, woutS, woutL);

//module cmp_systole (clk, inS, inL, outS, outL);
wire [LBL_LEN-1 : 0] koutL [K_NUM-1 : 0]; //провод соединения с вычислителем средних

cmp_systole #(SUM_LEN, LBL_LEN, K_NUM, VECT_NUM) cmp_sys_inst (clk, woutS, woutL, outS, koutL);

assign outL = koutL; 

pos_finder #(LBL_LEN, K_NUM) pos_fnd_inst (clk, koutL, x, y);

endmodule
