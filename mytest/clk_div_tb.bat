iverilog -o qqq clk_div.sv clk_div_tb.sv
if %errorlevel% == 0 vvp qqq
pause
:: comment