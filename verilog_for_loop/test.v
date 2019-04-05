`timescale 1ns/1ns

module test
  (
   );

   reg clk;
   reg rst;
   reg start;
   wire run;
   wire last;
   wire [31:0] wa, ia;

   always begin
      clk=1'b1; #5;
      clk=1'b0; #5;
   end

   initial begin
      rst = 1'b1;
      start = 1'b0;
      repeat(10) @(posedge clk);
      rst = 1'b0;
      repeat(3) @(posedge clk);
      start = 1'b1;
      repeat(1) @(posedge clk);
      start = 1'b0;
      @(posedge clk);
      wait(last==1'b1);
      repeat(10) @(posedge clk);
      $finish;
   end

   top top
     (
      .clk(clk),
      .rst(rst),
      .start(start),
      .last(last),
      .wa(wa),
      .ia(ia)
      );

endmodule
