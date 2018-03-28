// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2015-2016, Lars Asplund lars.anders.asplund@gmail.com

// You do not need to worry about adding vunit_defines.svh to your
// include path, VUnit will automatically do that for you if VUnit is
// correctly installed (and your python run-script is correct).
`include "vunit_defines.svh"

module tb_BskPRD;
   localparam integer clk_period = 500; // ns

   localparam VERSION = 7'h25;
   localparam PASSWORD = 8'hA4;
   localparam CS = 4'b1011;


   wire [15:0] bD;      // шина данных
   reg iRd;             // сигнал чтения (активный 0)
   reg iWr;             // сигнал записи (активный 0)
   reg iRes;            // сигнал сброса (активный 0)
   reg iBl;             // сигнал блокирования (активный 0)
   reg iDevice;         // ???
   reg clk;             // тактовая частота
   reg [1:0] iA;        // шина адреса
   reg [3:0] iCS;       // сигнал выбора микросхемы   
   
   reg  [15:0] iCom;    // вход команд
   wire [15:0] oComInd; // выход индикации команд (активный 0)
   wire oCS;            // выход адреса микросхемы (активный 0)
   wire test;           // тестовый сигнал (частота)

   reg [15:0] data_bus;

   assign bD = (iRd == 0'b0) ? 16'hZZZZ : data_bus; 

   `TEST_SUITE begin

      `TEST_SUITE_SETUP begin
         iCS = 4'b0000;
         iA = 2'b00;
         iBl = 1'b0;
         iRes = 1'b0;
         iWr = 1'b1;
         iRd = 1'b1;
         iCom = 16'hAA55;
         #(1ns);
         $display("Running test suite setup code");
      end

/*
      `TEST_CASE("test_cs") begin : test_cs
         iCS = 4'b0000;
         #(100ps);
         `CHECK_EQUAL(oCS, 1);

         iCS = 4'b1111;
         #(100ps);
         `CHECK_EQUAL(oCS, 1);

         iCS = CS;
         #(100ps);
         `CHECK_EQUAL(oCS, 0);

         iCS = 4'b1111;
         #(100ps);
         `CHECK_EQUAL(oCS, 1);
      end
*/

      `TEST_CASE("test_read") begin : test_read
         #(100ps);
         iCS = CS;
         iA = 2'b11;
         iWr = 1'b1;
         iRd = 1'b0;
         #(100ps);
         `CHECK_EQUAL(oCS, 0);
         $display("%h", bD);

         iA = 2'b01;
         #(100ps);
         $display("%h", bD);

         iCom = 16'h1111;
         #(100ps);
         $display("%h", bD);
         `CHECK_EQUAL(bD, 16'hFF);


      end

   end;

   `WATCHDOG(1ms);

   always begin
      #(clk_period/2 * 1ns);
      clk <= !clk;
   end

   BskPRD #(.VERSION(VERSION), .PASSWORD(PASSWORD), .CS(CS)) dut(.*);

endmodule