interface mul_if;
   logic       en;
   logic [31:0] req_in_1;
   logic [31:0] req_in_2;
   logic [63:0] out;
endinterface

interface add_if;
   logic        en;
   logic [3:0]  sub;
   logic [1:0]  cin;
   logic [79:0] req_in_0;
   logic [79:0] req_in_1;
   logic [79:0] req_in_2;
   logic [31:0] aln0;
   logic [31:0] aln1;
   logic [31:0] aln2;
   logic [31:0] aln3;
   logic [65:64] cout;
   logic [81:0]  out;
   logic [31:0]  out0;
   logic [31:0]  out1;
   logic [31:0]  out2;
   logic [31:0]  out3;
endinterface

interface alnsft_if;
   logic       en0;
   logic [3:0] en1;
   logic [47:0] acc0, acc1, acc2, acc3;
   logic [5:0]  sft0, sft1, sft2, sft3;
   logic [47:0] acc0o, acc1o, acc2o, acc3o;
   logic [48:0] aln0, aln1, aln2, aln3;
endinterface

interface alnseld_if;
   logic       en;
   logic [52:0] fracz;
   logic signed [12:0] expd;
   logic [47:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7;
   logic [5:0]  sft0, sft1, sft2, sft3, sft4, sft5, sft6, sft7;
endinterface

module fma
  (
   input logic         clk,
   input logic         reset,
   input logic         req,
   input integer       req_command,
   input logic [63:0]  x,
   input logic [63:0]  y,
   input logic [63:0]  z,
   output logic [63:0] rslt,
   output logic [4:0]  flag
   );

   mul_if mul_if00,mul_if01,mul_if10,mul_if11;
   alnsft_if alnsft_if00,alnsft_if01,alnsft_if10,alnsft_if11;
   alnseld_if alnseld_if0, alnseld_if1;
   add_if add_if10,add_if11,add_if20,add_if21;

   fmad fmad
     (
      .clk(clk),
      .reset(reset),
      .req(req),
      .req_command(req_command),
      .x(x[63:0]),
      .y(y[63:0]),
      .z(z[63:0]),
      .rslt(rslt[63:0]),
      .flag(flag[4:0]),
      .mul_if00(mul_if00),
      .mul_if01(mul_if01),
      .mul_if10(mul_if10),
      .mul_if11(mul_if11),
      .alnsft_if00(alnsft_if00),
      .alnsft_if01(alnsft_if01),
      .alnsft_if10(alnsft_if10),
      .alnsft_if11(alnsft_if11),
      .alnseld_if0(alnseld_if0),
      .alnseld_if1(alnseld_if1),
      .add_if10(add_if10),
      .add_if11(add_if11),
      .add_if20(add_if20),
      .add_if21(add_if21)
      );

endmodule

module mul
  (
   input logic         clk,
   input integer       req_command,
   input logic         en,
   output logic [63:0] out,
   input logic [31:0]  req_in_1,
   input logic [31:0]  req_in_2,
   mul_if mul
   );

   mul0 mul0
     (
      .clk(clk),
      .req_command(req_command),
      .en(en),
      .out(out[63:0]),
      .req_in_1(req_in_1[31:0]),
      .req_in_2(req_in_2[31:0])
   );

endmodule

module add
  (
   input logic          clk,
   input logic          en,
   output logic [65:64] cout,
   output logic [81:0]  out,
   output logic [31:0]  out0,
   output logic [31:0]  out1,
   output logic [31:0]  out2,
   output logic [31:0]  out3,
   input logic [3:0]    sub,
   input logic [1:0]    cin,
   input logic [79:0]   req_in_0,
   input logic [79:0]   req_in_1,
   input logic [79:0]   req_in_2,
   input logic [31:0]   aln0,
   input logic [31:0]   aln1,
   input logic [31:0]   aln2,
   input logic [31:0]   aln3,
   add_if add
   );

   add0 add0
     (
      .clk(clk),
      .en(en),
      .cout(cout[65:64]),
      .out(out[81:0]),
      .out0(out0[31:0]),
      .out1(out1[31:0]),
      .out2(out2[31:0]),
      .out3(out3[31:0]),
      .sub(sub[3:0]),
      .cin(cin[1:0]),
      .req_in_0(req_in_0[79:0]),
      .req_in_1(req_in_1[79:0]),
      .req_in_2(req_in_2[79:0]),
      .aln0(aln0[31:0]),
      .aln1(aln1[31:0]),
      .aln2(aln2[31:0]),
      .aln3(aln3[31:0])
   );

endmodule

module alnsft
  (
   input logic         clk,
   input logic         reset,
   input integer       req_command,
   input logic         en0,
   input logic [3:0]   en1,
   input logic [47:0]  acc0,  acc1,  acc2,  acc3,
   input logic [5:0]   sft0,  sft1,  sft2,  sft3,
   output logic [47:0] acc0o, acc1o, acc2o, acc3o,
   output logic [48:0] aln0,  aln1,  aln2,  aln3,
   alnsft_if asft
   );

   alnsft0 alnsft0
     (
      .clk(clk),    .reset(reset),
      .req_command(req_command),
      .en0(en0),    .en1(en1),
      .acc0(acc0),  .acc1(acc1),  .acc2(acc2),  .acc3(acc3),
      .sft0(sft0),  .sft1(sft1),  .sft2(sft2),  .sft3(sft3),
      .acc0o(acc0o),.acc1o(acc1o),.acc2o(acc2o),.acc3o(acc3o),
      .aln0(aln0),  .aln1(aln1),  .aln2(aln2),  .aln3(aln3)
      );

endmodule

module alnseld
  (
   input logic               en,
   input logic [52:0]        fracz,
   input logic signed [12:0] expd,
   output logic [47:0]       acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7,
   output logic [5:0]        sft0, sft1, sft2, sft3, sft4, sft5, sft6, sft7,
   alnseld_if asel
   );

   alnseld0 alnseld0
     (
      .fracz(fracz[52:0]),      .expd(expd),
      .acc0(acc0), .acc1(acc1), .acc2(acc2), .acc3(acc3),
      .acc4(acc4), .acc5(acc5), .acc6(acc6), .acc7(acc7),
      .sft0(sft0), .sft1(sft1), .sft2(sft2), .sft3(sft3),
      .sft4(sft4), .sft5(sft5), .sft6(sft6), .sft7(sft7)
   );
endmodule
