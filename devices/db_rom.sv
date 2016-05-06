module db_rom (clk, reset, ena, datavector, label, dclk, enout, done);
//Память векторов + память соответствующих меток + автомат загрузки

parameter WORD_LEN = 6; 
parameter LBL_LEN = 10; 
parameter VECT_LEN = 4; 
parameter VECT_NUM = 35; //???????????

input clk;
input ena; //разрешение выдачи
input reset; //сброс 
output [LBL_LEN-1 : 0] label; //выход метки
output [WORD_LEN-1 :0] datavector [VECT_LEN-1 : 0]; //выход вектора
output [VECT_NUM-1 : 0] dclk; //выход разрешения записи в колонку
output enout; //выход разрешения записи в регистр
output done; //выход флага окончания работы загрузчика

           
(*ramstyle = "M9K"*) reg [WORD_LEN-1 : 0] memdata [0 : VECT_LEN*VECT_NUM-1]; //регистр отгрузки вектора из памяти
 
(*ramstyle = "M9K"*) reg [LBL_LEN-1 : 0] memlabel [0 : VECT_NUM-1]; //регистр отгрузки метки из памяти


initial begin	
	//инициализация ROM из файлов
	$readmemh("memory.data", memdata);
	$readmemh("memory.label", memlabel);
end

reg [$clog2(VECT_NUM)-1 : 0] addrLabel;  //адресный регистр для памяти меток
reg [VECT_LEN-1 : 0] cnt; //счетчик тактов

reg [WORD_LEN-1 : 0] outData [VECT_LEN-1 : 0]; //регистр отгрузки вектора в систолу
assign datavector = outData;

reg [LBL_LEN-1 : 0] outLabel; //регистр отгрузки метки в систолу
assign label = outLabel;

reg [VECT_NUM-1 : 0] dreg; //сдвиговый регистр с разрешениями

reg [1 : 0] state; //регистр состояния автомата загрузки
parameter ST_Idle = 2'd0,
		  ST_Extract = 2'd1,
		  ST_PrePull = 2'd2,
		  ST_Pull = 2'd3;

always @(posedge clk) begin
	case (state)
		ST_Idle: begin //простой
			addrLabel <= 'b0;
			cnt <= 'b0;
			
			if (!reset && ena)
				state = ST_Extract;
		end
		
		ST_Extract: begin //извлечение вектора из памяти
			if (cnt == VECT_LEN) begin
				state = ST_PrePull;
			end
			else begin
				if (cnt == 0)
					outLabel <= memlabel[addrLabel]; //вывод метки
				outData[cnt] <= memdata[VECT_LEN*addrLabel + cnt]; //вывод элемента вектора			
			end	
			cnt <= cnt + 'b1; //счетчик элементов вектора
		end
		
		ST_PrePull: begin //подготовка к отгрузке в систолу
			dreg = 'b1 << addrLabel; //выставление разрешения
			addrLabel <= addrLabel + 'b1; //смена адреса метки на будущее
			cnt <= 'b0;
			state = ST_Pull;
		end
		
		ST_Pull: begin //отгрузка в систолу
			if (addrLabel == VECT_NUM)
				state = ST_Idle;
			else
				state = ST_Extract;
			dreg <= 'b0;
		end	
	endcase		
end

assign done = state == ST_Idle; //если простаиваем - значит все готово
assign enout = (state == ST_PrePull) || (state == ST_Pull); //запись в регистр систолы только в состояниях отгрузки и подготовки к отгрузке
assign dclk = dreg;


endmodule
