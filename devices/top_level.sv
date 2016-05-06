module top_level(clk, ena, init, inSel, led, int_done, work_done);
//Верхний уровень иерархии: две систолы в сборе, загрузчик и автомат режима

parameter VECT_NUM = 36;
parameter VECT_LEN = 10;
parameter WORD_LEN = 6;
parameter SUM_LEN = 10;
parameter LBL_LEN = 14;
parameter K_NUM = 3;

input clk;
input ena; //команда на подсчет координат
input init; //команда на инициализацию

reg [WORD_LEN-1 : 0] inV [VECT_LEN-1 : 0]; //вход для вектора измерений

//отладочные выходы
reg [SUM_LEN-1 : 0] outS [K_NUM-1 : 0];
reg [LBL_LEN-1 : 0] outL [K_NUM-1 : 0]; //убрать

//выходы готовых координат
reg [LBL_LEN/2-1 : 0] x;
reg [LBL_LEN/2-1 : 0] y;

input reg inSel;
output reg [7 : 0] led;


output int_done; //инициализация готова
output work_done; //подсчет координат закончен

wire init_done;

//соединения между загрузчиком и систолами
wire [VECT_NUM-1 : 0] dclk;
wire enaV;
wire [LBL_LEN-1 : 0] label;
wire [WORD_LEN-1 :0] datavector [VECT_LEN-1 : 0];

//module db_rom (clk, reset, ena, datavector, label, dclk, enout, done);
db_rom #(WORD_LEN, LBL_LEN, VECT_LEN, VECT_NUM) db_rom_inst (clk, 
															!init, 
															init, 
															datavector, 
															label, 
															dclk, 
															enaV, 
															init_done);

															
//wire [LBL_LEN/2-1 : 0] x;
//wire [LBL_LEN/2-1 : 0] y;															
//module sm_knn (clk, dclk, enaV, inV, inL, outS, outL, x, y);
//wire [LBL_LEN-1 : 0] outL [K_NUM-1 : 0];
sm_knn #(VECT_NUM, VECT_LEN, WORD_LEN, SUM_LEN, LBL_LEN, K_NUM) sm_knn_inst (clk, 
																			dclk, 
																			//переключение входа извне на выход с загрузчика
																			(state == ST_Init || state == ST_UnInit_Idle)? enaV : ena, 
																			(state == ST_Init || state == ST_UnInit_Idle)? datavector : inV, 
																			label, 
																			outS, outL, 
																			x, y);  

reg [1 : 0] state;
parameter ST_UnInit_Idle = 2'd0, 
		  ST_Init = 2'd1,
		  ST_Init_Idle = 2'd2,
		  ST_Work = 2'd3;

reg [$clog2(VECT_LEN+VECT_NUM+2)-1 : 0] counter; //счетчик тактов
reg regdone;
  
always @(posedge clk) begin
	case (state)
		ST_UnInit_Idle: //простой без инициализации
			if (init) 
				state = ST_Init;
		
		ST_Init: //инициализация
			if (init_done) 
				state = ST_Init_Idle;
		
		ST_Init_Idle: //простой инициализированной системы
			if (ena) begin
				state = ST_Work;
				regdone <= 1'b0; //сброс флага готовности
				inV[VECT_LEN-1 : 0] = '{00, 01, 02, 03, 04, 05, 06, 07, 08, 09};
			end
				
		ST_Work: begin
			counter <= counter + 'b1;
			if (counter == VECT_LEN+VECT_NUM+K_NUM) begin //M+N+K //-такт на подсчет средних (как так получилось? - магия)
				state = ST_Init_Idle;
				regdone <= 1'b1;
			end
		end
	endcase		
end

assign int_done = (state != ST_Init && state != ST_UnInit_Idle);
assign work_done = regdone;
assign led = inSel ? x : y;

endmodule
