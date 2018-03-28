module BskPRD # (
	parameter [6:0]	VERSION 	= 7'h25,		// версия прошивки
	parameter [7:0]	PASSWORD	= 8'hA4,		// пароль
	parameter [3:0]	CS			= 4'b1011		// адрес микросхемы
) (
	inout  wire [15:0] bD,		// шина данных
	input  wire iRd,			// сигнал чтения (активный 0)
	input  wire iWr,			// сигнал записи (активный 0)
	input  wire iRes,			// сигнал сброса (активный 0)
	input  wire iBl,			// сигнал блокирования (активный 0)
	input  wire iDevice,		// ???
	input  wire clk,			// тактовая частота
	input  wire [1:0] iA,		// шина адреса
	input  wire [3:0] iCS,		// сигнал выбора микросхемы	
	
	input  reg  [15:0] iCom,	// вход команд
	output wire [15:0] oComInd,	// выход индикации команд (активный 0)
	output wire oCS,			// выход адреса микросхемы (активный 0)
	output wire test			// тестовый сигнал (частота)
);

	// тактовая частота
	localparam CLOCK_IN 	= 'd2_000_000;	

	// параметры для формирования частоты тестового сигнала
	localparam TEST_FREQ	= 'd250_000;					// частота тестового сигнала
	localparam TEST_CNT_MAX = CLOCK_IN / TEST_FREQ / 2;		// счетчик делителя для получения тестового сигнала
	localparam TEST_CNT_WIDTH = $clog2(TEST_CNT_MAX);		// количество бит для счетчика тестовго сигнала

	// регистры для формирования частоты тестового сигнала
	reg test_en;	// 1 - разрешение передачи сигнала на выход
	reg test_clk;	// сфорированная частота тестового сигнала
	reg [TEST_CNT_WIDTH-1:0] test_cnt;	  

	// сигнал сброса (активный 1)
	wire aclr = !iRes;	

	// сигнал выбора микросхемы (активный 1)
	wire cs = (iCS == CS);

	// шина чтения / записи
	reg [15:0] data_bus;

	// команды индикации
	reg  [15:0] com_ind;	
		
	initial begin
		test_en	 = 1'b0;
		test_clk = 1'b0;
		test_cnt = 1'b0;
		com_ind  = 16'b0;
		data_bus = 16'hAA;
	end

	// двунаправленная шина данных
	// assign bD = (iRd || !cs) ? {16'bZ} : data_bus;  
	assign bD = (iRd) ? 16'bZ : data_bus;  
	
	// Тестовый сигнал
	assign test = (iBl && test_en) ? test_clk : 1'b0;	
	
	// Сигнал выбора микросхемы
	assign oCS = !cs;

	// индикация команд
	assign oComInd = ~com_ind;
	
	// чтение данных
	always @ (iA or cs or iRd or iWr) begin : data_rw
		if (aclr) begin
			test_en <= 1'b0;
			com_ind <= 16'b0;
		end
		else if (cs) begin
			case(iA)
				2'b00: begin
					if (iRd == 1'b0) begin
						data_bus[03:00] <=  iCom[3:0];
						data_bus[07:04] <= ~iCom[3:0];
						data_bus[11:08] <=  iCom[7:4];
						data_bus[15:12] <= ~iCom[7:4];
					end
				end
				2'b01: begin
					if (iRd == 1'b0) begin
						data_bus[03:00] <=  iCom[11:08];
						data_bus[07:04] <= ~iCom[11:08];
						data_bus[11:08] <=  iCom[15:12];
						data_bus[15:12] <= ~iCom[15:12];
					end
				end
				2'b10: begin
					if (iRd == 1'b0) begin
						data_bus <= com_ind;
					end
					else if (iWr == 1'b0) begin
						com_ind <= bD;
					end
				end
				2'b11: begin
					if (iRd == 1'b0) begin
						data_bus[0]    <= test_en; 
		 				data_bus[7:1]  <= VERSION; 
		 				data_bus[15:8] <= PASSWORD; 
					end
					else if (iWr == 1'b0) begin
						test_en <= bD[0];
					end
				end
			endcase
		end
	end
	
	// формирование частоты для тестового сигнала
	always @ (posedge clk or posedge aclr) begin : generate_test_clk
		if (aclr) begin
			test_cnt <= 0;
			test_clk <= 1'b0;
		end
		else if (test_cnt == 0) begin
			test_cnt <= TEST_CNT_MAX - 1;
			test_clk <= ~test_clk;
		end
		else begin
			test_cnt <= test_cnt - 1'b1;
		end	
	end

endmodule