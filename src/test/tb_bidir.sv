// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2015-2016, Lars Asplund lars.anders.asplund@gmail.com

// You do not need to worry about adding vunit_defines.svh to your
// include path, VUnit will automatically do that for you if VUnit is
// correctly installed (and your python run-script is correct).
`include "vunit_defines.svh"

module tb_bidirec;
   localparam integer clk_period = 500; // ns

   logic clk;

   logic oe = 1'b0;
   wire [7:0] bidir;
   reg [7:0] in = '0;
   reg[7:0] out = '0;

   assign bidir = oe ? 8'bZ : out;

   `TEST_SUITE begin

      `TEST_CASE("test_aclr") begin
         // в начальный момент на выходе состояние x
         oe = 1'b0;
         #(clk_period * 1ns);

         out = 24;
         #(clk_period * 1ns);

         #(clk_period * 1ns);


         `CHECK_EQUAL(0, 0);  
      end

   end;

   `WATCHDOG(1ms);

   always begin
      #(clk_period/2 * 1ns);
      clk <= !clk;
   end

   bidir dut(.*);

endmodule