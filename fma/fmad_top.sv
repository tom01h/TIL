typedef struct packed {
   logic       en;
   logic [26:0] req_in_1;
   logic [26:0] req_in_2;
} mulit;

typedef struct packed {
   logic [53:0] out;
} mulot;

typedef struct packed {
   logic       en;
   logic       sub;
   logic [1:0] cin;
   logic [79:0] req_in_0;
   logic [79:0] req_in_1;
   logic [79:0] req_in_2;
   logic [31:0] aln0;
   logic [31:0] aln1;
   logic [31:0] aln2;
   logic [31:0] aln3;
} addit;

typedef struct packed {
   logic [65:64] cout;
   logic [81:0]  out;
} addot;

typedef struct packed {
   logic       en;
   logic [47:0] acc0, acc1, acc2, acc3;
   logic [5:0]  sft0, sft1, sft2, sft3;
} sftit;

typedef struct packed {
   logic [48:0] aln0, aln1, aln2, aln3;
} sftot;

typedef struct packed {
   logic [52:0] fracz;
   logic signed [12:0] expd;
} selit;

typedef struct packed {
   logic [47:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7;
   logic [5:0]  sft0, sft1, sft2, sft3, sft4, sft5, sft6, sft7;
} selot;

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

   mulit muli00,muli01;
   mulot mulo00,mulo01;
   mulit muli10,muli11;
   mulot mulo10,mulo11;
   sftit sfti00,sfti01;
   sftot sfto00,sfto01;
   sftit sfti10,sfti11;
   sftot sfto10,sfto11;
   selit seli0, seli1;
   selot selo0, selo1;
   addit addi10,addi11;
   addot addo10,addo11;
   addit addi20,addi21;
   addot addo20,addo21;

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
      .muli00(muli00),
      .mulo00(mulo00),
      .muli01(muli01),
      .mulo01(mulo01),
      .muli10(muli10),
      .mulo10(mulo10),
      .muli11(muli11),
      .mulo11(mulo11),
      .sfti00(sfti00),
      .sfto00(sfto00),
      .sfti01(sfti01),
      .sfto01(sfto01),
      .sfti10(sfti10),
      .sfto10(sfto10),
      .sfti11(sfti11),
      .sfto11(sfto11),
      .seli0(seli0),
      .selo0(selo0),
      .seli1(seli1),
      .selo1(selo1),
      .addi10(addi10),
      .addo10(addo10),
      .addi11(addi11),
      .addo11(addo11),
      .addi20(addi20),
      .addo20(addo20),
      .addi21(addi21),
      .addo21(addo21)
      );

endmodule

module mul
  (
   input logic         clk,
   input logic         en,
   output logic [53:0] out,
   input logic [26:0]  req_in_1,
   input logic [26:0]  req_in_2,
   output              mulit muli,
   input               mulot mulo
   );

   mul0 mul0
     (
      .clk(clk),
      .en(en),
      .out(out[53:0]),
      .req_in_1(req_in_1[26:0]),
      .req_in_2(req_in_2[26:0])
   );

endmodule

module add
  (
   input logic          clk,
   input logic          en,
   output logic [65:64] cout,
   output logic [81:0]  out,
   input logic          sub,
   input logic [1:0]    cin,
   input logic [79:0]   req_in_0,
   input logic [79:0]   req_in_1,
   input logic [79:0]   req_in_2,
   input logic [31:0]   aln0,
   input logic [31:0]   aln1,
   input logic [31:0]   aln2,
   input logic [31:0]   aln3,
   output               addit addi,
   input                addot addo
   );

   add0 add0
     (
      .clk(clk),
      .en(en),
      .cout(cout[65:64]),
      .out(out[81:0]),
      .sub(sub),
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
   input logic         en,
   input logic [47:0]  acc0, acc1, acc2, acc3,
   input logic [5:0]   sft0, sft1, sft2, sft3,
   output logic [48:0] aln0, aln1, aln2, aln3,
   output              sftit sfti,
   input               sftot sfto
   );

   alnsft0 alnsft0
     (
      .clk(clk),   .en(en),
      .acc0(acc0), .acc1(acc1), .acc2(acc2), .acc3(acc3),
      .sft0(sft0), .sft1(sft1), .sft2(sft2), .sft3(sft3),
      .aln0(aln0), .aln1(aln1), .aln2(aln2), .aln3(aln3)
      );

endmodule

module alnseld
  (
   input logic               en,
   input logic [52:0]        fracz,
   input logic signed [12:0] expd,
   output logic [47:0]       acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7,
   output logic [5:0]        sft0, sft1, sft2, sft3, sft4, sft5, sft6, sft7,
   output                    selit seli,
   input                     selot selo
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
