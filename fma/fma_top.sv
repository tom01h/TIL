typedef struct packed {
   logic       en;
   logic [31:0] req_in_1;
   logic [31:0] req_in_2;
} mulit;

typedef struct packed {
   logic [63:0] out;
} mulot;

typedef struct packed {
   logic       en;
   logic [3:0] sub;
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
   logic [31:0]  out0;
   logic [31:0]  out1;
   logic [31:0]  out2;
   logic [31:0]  out3;
} addot;

typedef struct packed {
   logic       en0;
   logic [3:0] en1;
   logic [47:0] acc0, acc1, acc2, acc3;
   logic [5:0]  sft0, sft1, sft2, sft3;
} sftit;

typedef struct packed {
   logic [47:0] acc0o, acc1o, acc2o, acc3o;
   logic [48:0] aln0, aln1, aln2, aln3;
} sftot;

typedef struct packed {
   logic       en;
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
   input logic [31:0]  w,
   output logic [31:0] acc0, acc1, acc2, acc3,
   output logic [ 9:0] exp0, exp1, exp2, exp3,
   output logic [63:0] rslt,
   output logic [4:0]  flag
   );

   logic [63:0]        rsltd;
   logic [4:0]         flagd;
   logic [63:0]        rslts;
   logic [4:0]         flags;

   always_comb begin
      if(req_command==0)begin
         rslt = rslts;
         flag = flags;
      end else begin
         rslt = rsltd;
         flag = flagd;
      end
   end

   mulit muli00,muli01;
   mulot mulo00,mulo01;
   mulit muli10,muli11;
   mulot mulo10,mulo11;
   mulit mulis0,mulis1;
   mulot mulos0,mulos1;
   mulit muli0;
   mulot mulo0;
   mulit mulib0;
   mulot mulob0;

   always_comb begin
      if(muli00.en)begin
         mulis0 = muli00;
         mulis1 = muli01;
      end else if(muli10.en)begin
         mulis0 = muli10;
         mulis1 = muli11;
      end else if(muli0.en)begin
         mulis0 = muli0;
         mulis1 = 0;
         mulis1.en = 1'b0;
      end else begin
         mulis0 = mulib0;
         mulis1 = 0;
         mulis1.en = 1'b0;
      end
      mulo00 = mulos0;
      mulo01 = mulos1;
      mulo10 = mulos0;
      mulo11 = mulos1;
      mulo0 = mulos0;
      mulob0 = mulos0;
   end

   mul0 mul0
     (
      .clk(clk),
      .req_command(req_command),
      .en(mulis0.en),
      .out(mulos0.out[63:0]),
      .req_in_1(mulis0.req_in_1[31:0]),
      .req_in_2(mulis0.req_in_2[31:0])
      );

   mul0 mul1
     (
      .clk(clk),
      .req_command(req_command),
      .en(mulis1.en),
      .out(mulos1.out[63:0]),
      .req_in_1(mulis1.req_in_1[31:0]),
      .req_in_2(mulis1.req_in_2[31:0])
      );

   sftit sfti00,sfti01;
   sftot sfto00,sfto01;
   sftit sfti10,sfti11;
   sftot sfto10,sfto11;
   sftit sftis0,sftis1;
   sftot sftos0,sftos1;
   sftit sfti0;
   sftot sfto0;
   sftit sftib0;
   sftot sftob0;

   always_comb begin
      if(sfti00.en0)begin
         sftis0 = sfti00;
         sftis1 = sfti01;
      end else if(sfti10.en0)begin
         sftis0 = sfti10;
         sftis1 = sfti11;
      end else if(sfti0.en0)begin
         sftis0 = sfti0;
         sftis1 = 0;
         sftis1.en0 = 1'b0;
         sftis1.en1 = 4'h0;
      end else begin
         sftis0 = sftib0;
         sftis1 = 0;
         sftis1.en0 = 1'b0;
         sftis1.en1 = 4'h0;
      end
      sfto00 = sftos0;
      sfto01 = sftos1;
      sfto10 = sftos0;
      sfto11 = sftos1;
      sfto0 = sftos0;
      sftob0 = sftos0;
   end

   alnsft0 alnsft0
     (
      .clk(clk),           .reset(reset),       .req_command(req_command),
      .en0(sftis0.en0),    .en1(sftis0.en1),
      .acc0(sftis0.acc0),  .acc1(sftis0.acc1),  .acc2(sftis0.acc2),  .acc3(sftis0.acc3),
      .sft0(sftis0.sft0),  .sft1(sftis0.sft1),  .sft2(sftis0.sft2),  .sft3(sftis0.sft3),
      .acc0o(sftos0.acc0o),.acc1o(sftos0.acc1o),.acc2o(sftos0.acc2o),.acc3o(sftos0.acc3o),
      .aln0(sftos0.aln0),  .aln1(sftos0.aln1),  .aln2(sftos0.aln2),  .aln3(sftos0.aln3)
      );

   alnsft0 alnsft1
     (
      .clk(clk),           .reset(reset),       .req_command(req_command),
      .en0(sftis1.en0),    .en1(sftis1.en1),
      .acc0(sftis1.acc0),  .acc1(sftis1.acc1),  .acc2(sftis1.acc2),  .acc3(sftis1.acc3),
      .sft0(sftis1.sft0),  .sft1(sftis1.sft1),  .sft2(sftis1.sft2),  .sft3(sftis1.sft3),
      .acc0o(sftos0.acc0o),.acc1o(sftos0.acc1o),.acc2o(sftos0.acc2o),.acc3o(sftos0.acc3o),
      .aln0(sftos1.aln0),  .aln1(sftos1.aln1),  .aln2(sftos1.aln2),  .aln3(sftos1.aln3)
      );

   selit seli0, seli1;
   selot selo0, selo1;
   selit selis;
   selot selos;

   always_comb begin
      if(seli0.en)begin
         selis = seli0;
      end else begin
         selis = seli1;
      end
      selo0 = selos;
      selo1 = selos;
   end

   alnseld0 alnseld0
     (
      .fracz(selis.fracz),      .expd(selis.expd),
      .acc0(selos.acc0), .acc1(selos.acc1), .acc2(selos.acc2), .acc3(selos.acc3),
      .acc4(selos.acc4), .acc5(selos.acc5), .acc6(selos.acc6), .acc7(selos.acc7),
      .sft0(selos.sft0), .sft1(selos.sft1), .sft2(selos.sft2), .sft3(selos.sft3),
      .sft4(selos.sft4), .sft5(selos.sft5), .sft6(selos.sft6), .sft7(selos.sft7)
   );

   addit addi10,addi11;
   addot addo10,addo11;
   addit addi20,addi21;
   addot addo20,addo21;
   addit addis0,addis1;
   addot addos0,addos1;
   addit addi1;
   addot addo1;
   addit addib1;
   addot addob1;

   always_comb begin
      if(addi10.en)begin
         addis0 = addi10;
         addis1 = addi11;
      end else if(addi20.en)begin
         addis0 = addi20;
         addis1 = addi21;
      end else if(addi1.en)begin
         addis0 = addi1;
         addis1 = 0;
      end else begin
         addis0 = addib1;
         addis1 = 0;
      end
      addo10 = addos0;
      addo11 = addos1;
      addo20 = addos0;
      addo21 = addos1;
      addo1 = addos0;
      addob1 = addos0;
   end

   add0 add0
     (
      .clk(clk),
      .en(addis0.en),
      .cout(addos0.cout[65:64]),
      .out(addos0.out[81:0]),
      .out0(addos0.out0[31:0]),
      .out1(addos0.out1[31:0]),
      .out2(addos0.out2[31:0]),
      .out3(addos0.out3[31:0]),
      .sub(addis0.sub[3:0]),
      .cin(addis0.cin[1:0]),
      .req_in_0(addis0.req_in_0[79:0]),
      .req_in_1(addis0.req_in_1[79:0]),
      .req_in_2(addis0.req_in_2[79:0]),
      .aln0(addis0.aln0[31:0]),
      .aln1(addis0.aln1[31:0]),
      .aln2(addis0.aln2[31:0]),
      .aln3(addis0.aln3[31:0])
   );

   add0 add1
     (
      .clk(clk),
      .en(addis1.en),
      .cout(addos1.cout[65:64]),
      .out(addos1.out[81:0]),
      .out0(addos1.out0[31:0]),
      .out1(addos1.out1[31:0]),
      .out2(addos1.out2[31:0]),
      .out3(addos1.out3[31:0]),
      .sub(addis1.sub[3:0]),
      .cin(addis1.cin[1:0]),
      .req_in_0(addis1.req_in_0[79:0]),
      .req_in_1(addis1.req_in_1[79:0]),
      .req_in_2(addis1.req_in_2[79:0]),
      .aln0(addis1.aln0[31:0]),
      .aln1(addis1.aln1[31:0]),
      .aln2(addis1.aln2[31:0]),
      .aln3(addis1.aln3[31:0])
   );

   fmad fmad
     (
      .clk(clk),
      .reset(reset),
      .req(req&(req_command==1)),
      .req_command(req_command),
      .x(x[63:0]),
      .y(y[63:0]),
      .z(z[63:0]),
      .rslt(rsltd[63:0]),
      .flag(flagd[4:0]),
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

   fmas fmas
     (
      .clk(clk),
      .reset(reset),
      .req(req&(req_command==0)),
      .req_command(req_command),
      .x(x[31:0]),
      .y(y[31:0]),
      .z(z[31:0]),
      .rslt(rslts[31:0]),
      .flag(flags[4:0]),
      .muli0(muli0),
      .mulo0(mulo0),
      .sfti0(sfti0),
      .sfto0(sfto0),
      .addi1(addi1),
      .addo1(addo1)
      );

   fmab fmab
     (
      .clk(clk),
      .reset(reset),
      .req(req&(req_command==2)),
      .req_command(req_command),
      .x(x[31:0]),
      .y(y[31:0]),
      .z(z[31:0]),
      .w(w[31:0]),
      .acc0(acc0[31:0]),
      .acc1(acc1[31:0]),
      .acc2(acc2[31:0]),
      .acc3(acc3[31:0]),
      .exp0(exp0[ 9:0]),
      .exp1(exp1[ 9:0]),
      .exp2(exp2[ 9:0]),
      .exp3(exp3[ 9:0]),
      .muli0(mulib0),
      .mulo0(mulob0),
      .sfti0(sftib0),
      .sfto0(sftob0),
      .addi1(addib1),
      .addo1(addob1)
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
   output              mulit muli,
   input               mulot mulo
   );

   assign muli.en = en;
   assign muli.req_in_1 = req_in_1;
   assign muli.req_in_2 = req_in_2;
   assign out = mulo.out;

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
   output               addit addi,
   input                addot addo
   );

   assign addi.en = en;
   assign addi.sub = sub;
   assign addi.cin = cin;
   assign addi.req_in_0 = req_in_0;
   assign addi.req_in_1 = req_in_1;
   assign addi.req_in_2 = req_in_2;
   assign addi.aln0 = aln0;
   assign addi.aln1 = aln1;
   assign addi.aln2 = aln2;
   assign addi.aln3 = aln3;
   assign cout = addo.cout;
   assign out = addo.out;
   assign out0 = addo.out0;
   assign out1 = addo.out1;
   assign out2 = addo.out2;
   assign out3 = addo.out3;

endmodule

module alnsft
  (
   input logic         clk,
   input logic         reset,
   input integer       req_command,
   input logic         en0,
   input logic [3:0]   en1,
   input logic [47:0]  acc0, acc1, acc2, acc3,
   input logic [5:0]   sft0, sft1, sft2, sft3,
   output logic [48:0] aln0, aln1, aln2, aln3,
   output logic [47:0] acc0o,acc1o,acc2o,acc3o,
   output              sftit sfti,
   input               sftot sfto
   );

   assign sfti.en0 = en0;
   assign sfti.en1 = en1;
   assign sfti.acc0 = acc0;
   assign sfti.acc1 = acc1;
   assign sfti.acc2 = acc2;
   assign sfti.acc3 = acc3;
   assign sfti.sft0 = sft0;
   assign sfti.sft1 = sft1;
   assign sfti.sft2 = sft2;
   assign sfti.sft3 = sft3;
   assign aln0 = sfto.aln0;
   assign aln1 = sfto.aln1;
   assign aln2 = sfto.aln2;
   assign aln3 = sfto.aln3;
   assign acc0o= sfto.acc0o;
   assign acc1o= sfto.acc1o;
   assign acc2o= sfto.acc2o;
   assign acc3o= sfto.acc3o;

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

   assign seli.en = en;
   assign seli.fracz = fracz;
   assign seli.expd = expd;

   assign acc0 = selo.acc0;
   assign acc1 = selo.acc1;
   assign acc2 = selo.acc2;
   assign acc3 = selo.acc3;
   assign acc4 = selo.acc4;
   assign acc5 = selo.acc5;
   assign acc6 = selo.acc6;
   assign acc7 = selo.acc7;
   assign sft0 = selo.sft0;
   assign sft1 = selo.sft1;
   assign sft2 = selo.sft2;
   assign sft3 = selo.sft3;
   assign sft4 = selo.sft4;
   assign sft5 = selo.sft5;
   assign sft6 = selo.sft6;
   assign sft7 = selo.sft7;

endmodule
