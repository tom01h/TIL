`timescale 1ns/1ns
module sim_top();

   reg clk, init, write, exec, outr, accr, execp;
   reg [15:0] wd, d;

   initial begin
      dst_buf.buff00[0] = 32'h0;
      dst_buf.buff01[0] = 32'h0;
//      dst_buf.buff10[0] = 32'h3f800000;
      dst_buf.buff10[0] = 32'h3f000000;
      dst_buf.buff11[0] = 32'h0;
   end

   initial begin
      #0;
      init = 1'b0;
      write = 1'b0;
      exec = 1'b0;
      outr = 1'b0;
      accr = 1'b0;
      execp = 1'b0;
      wd = 16'h0;
      d = 16'h0;
      #5;
      #10 init = 1'b1;
      #10;
      init = 1'b0;
      write = 1'b1;
      wd = 16'h3f80;
      #10;
      write = 1'b0;
      #10; /////////0///////////
      exec = 1'b1;
      d = 16'h3f80;
      #10; /////////1///////////
      exec = 1'b0;
      accr = 1'b1;
      #10; /////////2///////////
      accr = 1'b0;
      #10; /////////3///////////
      outr = 1'b1;
      #10; /////////4///////////
      outr = 1'b0;
      
      
      #100 $finish;
   end

   always begin
      clk=1;#5;
      clk=0;#5;
   end

   wire             signo;
   wire signed [9:0] expo;
   wire signed [31:0] addo;

   tiny_dnn_core tiny_dnn_core
     (
      .clk(clk),
      .init(init),
      .write(write),
      .bwrite(1'b0),
      .exec(exec),
      .outr(1'b0),
      .update(1'b1),
      .bias(1'b0),
      .ra(11'd0),
      .wa(11'd0),
      .d(d),
      .wd(wd),
      .signi(),
      .expi(),
      .addi(),
      .signo(signo),
      .expo(expo),
      .addo(addo)
      );

   dst_buf dst_buf
     (
      .clk(clk),
      .dst_v(1'b0),
      .dst_a(13'h0),
      .dst_d0(),
      .dst_d1(),
      .outr(outr),
      .accr(accr),
      .oa({execp,12'h0}),
      .signo(signo),
      .expo(expo),
      .addo(addo)
      );
endmodule
