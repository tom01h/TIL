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

   mul_if mul_if00,mul_if01,mul_if10,mul_if11;
   mul_if mul_ifs0,mul_ifs1,mul_ifb0,mul_ifb1;

   mul_i mul_i0
     (
      .clk(clk),
      .req_command(req_command),
      .mul0(mul_if00), .mul1(mul_if10),
      .muls(mul_ifs0), .mulb(mul_ifb0)
      );

   mul_i mul_i1
     (
      .clk(clk),
      .req_command(req_command),
      .mul0(mul_if01), .mul1(mul_if11),
      .muls(mul_ifs1), .mulb(mul_ifb1)
      );

   alnsft_if alnsft_if00,alnsft_if01,alnsft_if10,alnsft_if11;
   alnsft_if alnsft_ifs0,alnsft_ifs1,alnsft_ifb0,alnsft_ifb1;

   alnsft_i alnsft_i0
     (
      .clk(clk), .reset(reset), .req_command(req_command),
      .asft0(alnsft_if00), .asft1(alnsft_if10),
      .asfts(alnsft_ifs0), .asftb(alnsft_ifb0)
      );

   alnsft_i alnsft_i1
     (
      .clk(clk), .reset(reset), .req_command(req_command),
      .asft0(alnsft_if01), .asft1(alnsft_if11),
      .asfts(alnsft_ifs1), .asftb(alnsft_ifb1)
      );

   alnseld_if alnseld_if0;
   alnseld_if alnseld_if1;

   alnseld_i alnseld_i
     (
      .asel0(alnseld_if0),
      .asel1(alnseld_if1)
      );

   add_if add_if10,add_if11,add_if20,add_if21;
   add_if add_ifs0,add_ifs1,add_ifb0,add_ifb1;

   add_i add_i0
     (
      .clk(clk),
      .add0(add_if10), .add1(add_if20),
      .adds(add_ifs0), .addb(add_ifb0)
      );

   add_i add_i1
     (
      .clk(clk),
      .add0(add_if11), .add1(add_if21),
      .adds(add_ifs1), .addb(add_ifb1)
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
      .mul_if(mul_ifs0),
      .alnsft_if(alnsft_ifs0),
      .add_if(add_ifs0)
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
      .mul_if(mul_ifb0),
      .alnsft_if(alnsft_ifb0),
      .add_if(add_ifb0)
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

   assign mul.en = en;
   assign mul.req_in_1 = req_in_1;
   assign mul.req_in_2 = req_in_2;
   assign out = mul.out;
endmodule

module mul_i
  (
   input logic clk,
   input integer req_command,
   mul_if mul0, mul1,
   mul_if muls, mulb
   );

   logic         en;
   logic [31:0]  req_in_1;
   logic [31:0]  req_in_2;

   always_comb begin
      if(mul0.en)begin
         en = mul0.en;
         req_in_1 = mul0.req_in_1;
         req_in_2 = mul0.req_in_2;
      end else if(mul1.en)begin
         en = mul1.en;
         req_in_1 = mul1.req_in_1;
         req_in_2 = mul1.req_in_2;
      end else if(muls.en)begin
         en = muls.en;
         req_in_1 = muls.req_in_1;
         req_in_2 = muls.req_in_2;
      end else begin
         en = mulb.en;
         req_in_1 = mulb.req_in_1;
         req_in_2 = mulb.req_in_2;
      end
   end

   logic [63:0]  out;

   mul0 mul
     (
      .clk(clk),
      .req_command(req_command),
      .en(en),
      .out(out[63:0]),
      .req_in_1(req_in_1[31:0]),
      .req_in_2(req_in_2[31:0])
      );

   assign mul0.out = out;
   assign mul1.out = out;
   assign muls.out = out;
   assign mulb.out = out;

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

   assign add.en = en;
   assign add.sub = sub;
   assign add.cin = cin;
   assign add.req_in_0 = req_in_0;
   assign add.req_in_1 = req_in_1;
   assign add.req_in_2 = req_in_2;
   assign add.aln0 = aln0;
   assign add.aln1 = aln1;
   assign add.aln2 = aln2;
   assign add.aln3 = aln3;

   assign cout = add.cout;
   assign out = add.out;
   assign out0 = add.out0;
   assign out1 = add.out1;
   assign out2 = add.out2;
   assign out3 = add.out3;
endmodule

module add_i
  (
   input logic clk,
   add_if add0, add1,
   add_if adds, addb
   );

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

   always_comb begin
      if(add0.en)begin
         en = add0.en;
         sub = add0.sub;
         cin = add0.cin;
         req_in_0 = add0.req_in_0;
         req_in_1 = add0.req_in_1;
         req_in_2 = add0.req_in_2;
         aln0 = add0.aln0;
         aln1 = add0.aln1;
         aln2 = add0.aln2;
         aln3 = add0.aln3;
      end else if(add1.en)begin
         en = add1.en;
         sub = add1.sub;
         cin = add1.cin;
         req_in_0 = add1.req_in_0;
         req_in_1 = add1.req_in_1;
         req_in_2 = add1.req_in_2;
         aln0 = add1.aln0;
         aln1 = add1.aln1;
         aln2 = add1.aln2;
         aln3 = add1.aln3;
      end else if(adds.en)begin
         en = adds.en;
         sub = adds.sub;
         cin = adds.cin;
         req_in_0 = adds.req_in_0;
         req_in_1 = adds.req_in_1;
         req_in_2 = adds.req_in_2;
         aln0 = adds.aln0;
         aln1 = adds.aln1;
         aln2 = adds.aln2;
         aln3 = adds.aln3;
      end else begin
         en = addb.en;
         sub = addb.sub;
         cin = addb.cin;
         req_in_0 = addb.req_in_0;
         req_in_1 = addb.req_in_1;
         req_in_2 = addb.req_in_2;
         aln0 = addb.aln0;
         aln1 = addb.aln1;
         aln2 = addb.aln2;
         aln3 = addb.aln3;
      end
   end

   logic [65:64] cout;
   logic [81:0]  out;
   logic [31:0]  out0;
   logic [31:0]  out1;
   logic [31:0]  out2;
   logic [31:0]  out3;

   add0 add
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

   assign add0.cout = cout;
   assign add0.out = out;
   assign add0.out0 = out0;
   assign add0.out1 = out1;
   assign add0.out2 = out2;
   assign add0.out3 = out3;

   assign add1.cout = cout;
   assign add1.out = out;
   assign add1.out0 = out0;
   assign add1.out1 = out1;
   assign add1.out2 = out2;
   assign add1.out3 = out3;

   assign adds.cout = cout;
   assign adds.out = out;
   assign adds.out0 = out0;
   assign adds.out1 = out1;
   assign adds.out2 = out2;
   assign adds.out3 = out3;

   assign addb.cout = cout;
   assign addb.out = out;
   assign addb.out0 = out0;
   assign addb.out1 = out1;
   assign addb.out2 = out2;
   assign addb.out3 = out3;
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
   alnsft_if asft
   );
   assign asft.en0 = en0;
   assign asft.en1 = en1;
   assign asft.acc0 = acc0;
   assign asft.acc1 = acc1;
   assign asft.acc2 = acc2;
   assign asft.acc3 = acc3;
   assign asft.sft0 = sft0;
   assign asft.sft1 = sft1;
   assign asft.sft2 = sft2;
   assign asft.sft3 = sft3;

   assign aln0 = asft.aln0;
   assign aln1 = asft.aln1;
   assign aln2 = asft.aln2;
   assign aln3 = asft.aln3;
   assign acc0o= asft.acc0o;
   assign acc1o= asft.acc1o;
   assign acc2o= asft.acc2o;
   assign acc3o= asft.acc3o;
endmodule

module alnsft_i
  (
   input logic clk,
   input logic reset,
   input integer req_command,
   alnsft_if asft0, asft1,
   alnsft_if asfts, asftb
   );

   logic         en0;
   logic [3:0]   en1;
   logic [47:0]  acc0, acc1, acc2, acc3;
   logic [5:0]   sft0, sft1, sft2, sft3;

   always_comb begin
      if(asft0.en0)begin
         en0 = asft0.en0;
         en1 = asft0.en1;
         acc0 = asft0.acc0;
         acc1 = asft0.acc1;
         acc2 = asft0.acc2;
         acc3 = asft0.acc3;
         sft0 = asft0.sft0;
         sft1 = asft0.sft1;
         sft2 = asft0.sft2;
         sft3 = asft0.sft3;
      end else if(asft1.en0)begin
         en0 = asft1.en0;
         en1 = asft1.en1;
         acc0 = asft1.acc0;
         acc1 = asft1.acc1;
         acc2 = asft1.acc2;
         acc3 = asft1.acc3;
         sft0 = asft1.sft0;
         sft1 = asft1.sft1;
         sft2 = asft1.sft2;
         sft3 = asft1.sft3;
      end else if(asfts.en0)begin
         en0 = asfts.en0;
         en1 = asfts.en1;
         acc0 = asfts.acc0;
         acc1 = asfts.acc1;
         acc2 = asfts.acc2;
         acc3 = asfts.acc3;
         sft0 = asfts.sft0;
         sft1 = asfts.sft1;
         sft2 = asfts.sft2;
         sft3 = asfts.sft3;
      end else begin
         en0 = asftb.en0;
         en1 = asftb.en1;
         acc0 = asftb.acc0;
         acc1 = asftb.acc1;
         acc2 = asftb.acc2;
         acc3 = asftb.acc3;
         sft0 = asftb.sft0;
         sft1 = asftb.sft1;
         sft2 = asftb.sft2;
         sft3 = asftb.sft3;
      end
   end

   logic [48:0]  aln0, aln1, aln2, aln3;
   logic [47:0]  acc0o,acc1o,acc2o,acc3o;

   alnsft0 alnsft0
     (
      .clk(clk),           .reset(reset),       .req_command(req_command),
      .en0(en0),    .en1(en1),
      .acc0(acc0),  .acc1(acc1),  .acc2(acc2),  .acc3(acc3),
      .sft0(sft0),  .sft1(sft1),  .sft2(sft2),  .sft3(sft3),
      .acc0o(acc0o),.acc1o(acc1o),.acc2o(acc2o),.acc3o(acc3o),
      .aln0(aln0),  .aln1(aln1),  .aln2(aln2),  .aln3(aln3)
      );

   assign asft0.aln0 =aln0;
   assign asft0.aln1 =aln1;
   assign asft0.aln2 =aln2;
   assign asft0.aln3 =aln3;

   assign asft0.acc0o =acc0o;
   assign asft0.acc1o =acc1o;
   assign asft0.acc2o =acc2o;
   assign asft0.acc3o =acc3o;

   assign asft1.aln0 =aln0;
   assign asft1.aln1 =aln1;
   assign asft1.aln2 =aln2;
   assign asft1.aln3 =aln3;

   assign asft1.acc0o =acc0o;
   assign asft1.acc1o =acc1o;
   assign asft1.acc2o =acc2o;
   assign asft1.acc3o =acc3o;

   assign asfts.aln0 =aln0;
   assign asfts.aln1 =aln1;
   assign asfts.aln2 =aln2;
   assign asfts.aln3 =aln3;

   assign asfts.acc0o =acc0o;
   assign asfts.acc1o =acc1o;
   assign asfts.acc2o =acc2o;
   assign asfts.acc3o =acc3o;

   assign asftb.aln0 =aln0;
   assign asftb.aln1 =aln1;
   assign asftb.aln2 =aln2;
   assign asftb.aln3 =aln3;

   assign asftb.acc0o =acc0o;
   assign asftb.acc1o =acc1o;
   assign asftb.acc2o =acc2o;
   assign asftb.acc3o =acc3o;

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

   assign asel.en = en;
   assign asel.fracz = fracz;
   assign asel.expd = expd;

   assign acc0 = asel.acc0;
   assign acc1 = asel.acc1;
   assign acc2 = asel.acc2;
   assign acc3 = asel.acc3;
   assign acc4 = asel.acc4;
   assign acc5 = asel.acc5;
   assign acc6 = asel.acc6;
   assign acc7 = asel.acc7;
   assign sft0 = asel.sft0;
   assign sft1 = asel.sft1;
   assign sft2 = asel.sft2;
   assign sft3 = asel.sft3;
   assign sft4 = asel.sft4;
   assign sft5 = asel.sft5;
   assign sft6 = asel.sft6;
   assign sft7 = asel.sft7;

endmodule

module alnseld_i
  (
   alnseld_if asel0,
   alnseld_if asel1
   );

   logic [52:0]        fracz;
   logic signed [12:0] expd;

   always_comb begin
      if(asel0.en)begin
         fracz = asel0.fracz;
         expd  = asel0.expd;
      end else begin
         fracz = asel1.fracz;
         expd  = asel1.expd;
      end
   end

   logic [47:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7;
   logic [5:0]  sft0, sft1, sft2, sft3, sft4, sft5, sft6, sft7;

   alnseld0 alnseld0
     (
      .fracz(fracz),      .expd(expd),
      .acc0(acc0), .acc1(acc1), .acc2(acc2), .acc3(acc3),
      .acc4(acc4), .acc5(acc5), .acc6(acc6), .acc7(acc7),
      .sft0(sft0), .sft1(sft1), .sft2(sft2), .sft3(sft3),
      .sft4(sft4), .sft5(sft5), .sft6(sft6), .sft7(sft7)
      );

   assign asel0.acc0 = acc0;
   assign asel0.acc1 = acc1;
   assign asel0.acc2 = acc2;
   assign asel0.acc3 = acc3;
   assign asel0.acc4 = acc4;
   assign asel0.acc5 = acc5;
   assign asel0.acc6 = acc6;
   assign asel0.acc7 = acc7;
   assign asel0.sft0 = sft0;
   assign asel0.sft1 = sft1;
   assign asel0.sft2 = sft2;
   assign asel0.sft3 = sft3;
   assign asel0.sft4 = sft4;
   assign asel0.sft5 = sft5;
   assign asel0.sft6 = sft6;
   assign asel0.sft7 = sft7;

   assign asel1.acc0 = acc0;
   assign asel1.acc1 = acc1;
   assign asel1.acc2 = acc2;
   assign asel1.acc3 = acc3;
   assign asel1.acc4 = acc4;
   assign asel1.acc5 = acc5;
   assign asel1.acc6 = acc6;
   assign asel1.acc7 = acc7;
   assign asel1.sft0 = sft0;
   assign asel1.sft1 = sft1;
   assign asel1.sft2 = sft2;
   assign asel1.sft3 = sft3;
   assign asel1.sft4 = sft4;
   assign asel1.sft5 = sft5;
   assign asel1.sft6 = sft6;
   assign asel1.sft7 = sft7;

endmodule
