`timescale 10 ns / 1 ns

module test;

reg clk, aclr; // reset, clk, wr;
//reg [7:0]wdata;
wire outclock; //[7:0] data_cnt;

//устанавливаем экземпл€р тестируемого модул€
clk_div #(2_000_000, 250_000) clkdiv8(clk, aclr, outclock); 

//моделируем сигнал тактовой частоты
always
  #25 clk = ~clk;

//от начала времени...

initial
begin
  clk = 1;
  aclr = 1;

// убираем сброс
  #250 aclr = 0; 

// включаем сброс
  #1700 aclr = 1;

// убираем сброс
  #1000 aclr = 0;

//пауза длительностью "50"
//  #50; 

//ждем фронта тактовой частоты и сразу после нее подаем сигнал записи
//  @(posedge clk) 
//  #0
//    begin
//      aclr = 0;
//      en = 1;
//    end

//по следующему фронту снимаем сигнал записи
//  @(posedge clk)
//  #0
//    begin
//      aclr = 1;
//      en = 0;
//    end
end 

//заканчиваем симул€цию в момент времени "400"
initial
begin
  #4000 $finish;
end

//создаем файл VCD дл€ последующего анализа сигналов
initial
begin
  $dumpfile("out.vcd");
  $dumpvars(0,test);
//  $monitor($stime,, aclr,, clk,,, outclock); 
end

//наблюдаем на некоторыми сигналами системы
//initial 
//$monitor($stime,, aclr,, clk,,, outclock); 

endmodule