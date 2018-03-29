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

	// шина чтения / записи
	reg [15:0] data_bus;

	// команды индикации
	reg  [15:0] com_ind;

	// сигнал сброса (активный 1)
	wire aclr = !iRes;	

	// сигнал выбора микросхемы (активный 1)
	wire cs = (iCS == CS);

	initial begin
		test_en	 = 1'b0;
		test_clk = 1'b0;
		test_cnt = 1'b0;
		com_ind  = 16'h0000;
		data_bus = 16'h0000;
	end

	// двунаправленная шина данных
	assign bD = (iRd || !cs) ? 16'bZ : data_bus;  
	
	// Тестовый сигнал
	assign test = (iBl && test_en) ? test_clk : 1'b0;	
	
	// сигнал выбора микросхемы (активный)
	assign oCS = !cs;

	// индикация команд
	assign oComInd = ~com_ind;
	
	// чтение данных
	always @ (cs or iA or iRd or iWr or aclr) begin : data_rw
		if (cs) begin
			if (iRd == 1'b0) begin
				data_bus <= read(iA);
			end
			else if (iWr == 1'b0) begin
				write(iA);
			end
		end

		if (aclr) begin
			test_en <= 1'b0;
			com_ind <= 16'b0;
		end
	end
	
	// чтение данных 
	function [15:0] read;
	input [1:0] adr;
	begin
		case(adr)
			2'b00: begin
				read[07:0] = (~iCom[3:0] << 4) + iCom[3:0];
				read[15:8] = (~iCom[7:4] << 4) + iCom[7:4];
			end
			2'b01: begin
				read[07:0] = (~iCom[11:8] << 4) + iCom[11:8];
				read[15:8] = (~iCom[15:12] << 4) + iCom[15:12];
			end
			2'b10: begin
				read = com_ind;
			end
			2'b11: begin
				read = (PASSWORD << 8) + (VERSION << 1) + test_en;
			end
		endcase
	end
	endfunction

	// запись внутренних регистров
	task write;
	input [1:0] adr;
	begin
		case (adr)
			2'b10: com_ind <= bD;
			2'b11: test_en <= bD[0];
		endcase
	end
	endtask
 
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