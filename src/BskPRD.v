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
	output wire oTest,			// тестовый сигнал (частота)

	output wire [15:0] debug	// выход отладки
);

	// тактовая частота
	localparam CLOCK_IN 	= 'd2_000_000;	

	// частота тестового сигнала
	localparam TEST_FREQ	= 'd250_000;	

	// счетчик делителя для получения тестового сигнала				
	localparam TEST_CNT_MAX = CLOCK_IN / TEST_FREQ / 2;

	// количество бит для счетчика тестовго сигнала	
	localparam TEST_CNT_WIDTH = $clog2(TEST_CNT_MAX);	

	// разрешение передачи тестового сигнала (активный 1)
	reg test_en;	// 1 - разрешение передачи сигнала на выход

	// тестовый сигнал (частота)
	reg test_clk;	

	// счетчик для форимрования тестового сигнала
	reg [TEST_CNT_WIDTH-1:0] test_cnt;	  

	// шина чтения / записи
	wire [15:0] data_bus;

	// команды
	reg [15:0] com;

	// команды индикации
	reg [15:0] com_ind;

	// сигнал сброса (активный 1)
	wire aclr = !iRes;	

	// сигнал выбора микросхемы (активный 1)
	wire cs = (iCS == CS);

	// набор сигналов для считывания
	wire [15:0] in0, in1, in3; 

	initial begin
		test_en	 = 1'b0;
		test_clk = 1'b0;
		test_cnt = 1'b0;
		com_ind  = 16'h0000;
		com = 16'h0000;
	end 
	
	// Тестовый сигнал
	assign oTest = (iBl && test_en) ? test_clk : 1'b0;	
	
	// сигнал выбора микросхемы (активный 1)
	assign oCS = !cs;

	// индикация команд 
	assign oComInd = ~com_ind;

	// двунаправленная шина данных
	assign bD = (iRd || !cs) ? 16'bZ : data_bus; 

	// набор сигналов для считывания с адреса 'b00
	assign in0[7:0] = (~com[3:0] << 4) + com[3:0]; 
	assign in0[15:8] = (~com[7:4] << 4) + com[7:4];

	// набор сигналов для считывания с адреса 'b01
	assign in1[7:0] = (~com[11:8] << 4) + com[11:8]; 
	assign in1[15:8] = (~com[15:12] << 4) + com[15:12];

	// набор сигналов для считывания c адреса 'b11
	assign in3 = (PASSWORD << 8) + (VERSION << 1) + test_en;

	// шина чтения
	assign data_bus = (iA == 2'b00) ? in0 :
					  (iA == 2'b01) ? in1 :
					  (iA == 2'b10) ? com_ind : in3;
					  				  	
	// сигналы отладки
	assign debug = 16'h0000;				  

	// чтение данных 
	always @ (cs or iRd  or iA or aclr)	begin : data_read
		if (aclr) begin
			com <= 16'h0000;
		end
		else begin
			com <= iCom;
		end
	end

	// запись внутренних регистров
	always @ (posedge iWr or posedge aclr) begin : data_write
		if (aclr) begin
			com_ind <= 16'h0000;
			test_en <= 1'b0;
		end
		else if (cs && iWr) begin
			case (iA)
				2'b10: com_ind <= bD;
				2'b11: test_en <= bD[0];
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