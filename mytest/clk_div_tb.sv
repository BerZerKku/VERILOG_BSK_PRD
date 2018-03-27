`timescale 10 ns / 1 ns

module test;

reg clk, aclr; // reset, clk, wr;
//reg [7:0]wdata;
wire outclock; //[7:0] data_cnt;

//������������� ��������� ������������ ������
clk_div #(2_000_000, 250_000) clkdiv8(clk, aclr, outclock); 

//���������� ������ �������� �������
always
  #25 clk = ~clk;

//�� ������ �������...

initial
begin
  clk = 1;
  aclr = 1;

// ������� �����
  #250 aclr = 0; 

// �������� �����
  #1700 aclr = 1;

// ������� �����
  #1000 aclr = 0;

//����� ������������� "50"
//  #50; 

//���� ������ �������� ������� � ����� ����� ��� ������ ������ ������
//  @(posedge clk) 
//  #0
//    begin
//      aclr = 0;
//      en = 1;
//    end

//�� ���������� ������ ������� ������ ������
//  @(posedge clk)
//  #0
//    begin
//      aclr = 1;
//      en = 0;
//    end
end 

//����������� ��������� � ������ ������� "400"
initial
begin
  #4000 $finish;
end

//������� ���� VCD ��� ������������ ������� ��������
initial
begin
  $dumpfile("out.vcd");
  $dumpvars(0,test);
//  $monitor($stime,, aclr,, clk,,, outclock); 
end

//��������� �� ���������� ��������� �������
//initial 
//$monitor($stime,, aclr,, clk,,, outclock); 

endmodule