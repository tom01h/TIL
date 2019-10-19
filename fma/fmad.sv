module fmad_check
  (
   input logic [63:0]  x,
   input logic [63:0]  y,
   input logic [63:0]  z,
   output logic [63:0] rslt,
   output logic [4:0]  flag
   );

   always_comb begin
      rslt = {64{1'bx}};
      flag = 5'h0;
      if((x[62:52]==11'h7ff)&(x[51:0]!=0))begin
         rslt    = x|64'h00080000_00000000;
         flag[4] = ~x[51]|((y[62:52]==11'h7ff)&~y[51]&(y[50:0]!=0))|((z[62:52]==11'h7ff)&~z[51]&(z[50:0]!=0));
      end else if((y[62:52]==11'h7ff)&(y[51:0]!=0))begin
         rslt    = y|64'h00080000_00000000;
         flag[4] = ~y[51]|((x[62:52]==11'h7ff)&~x[51]&(x[50:0]!=0))|((z[62:52]==11'h7ff)&~z[51]&(z[50:0]!=0));
      end else if(((x[62:52]==11'h7ff)&(y[62:0]==0))|((y[62:52]==11'h7ff)&(x[62:0]==0)))begin
         rslt    = 64'hfff80000_00000000;
         flag[4] = 1'b1;
      end else if((z[62:52]==11'h7ff)&(z[51:0]!=0))begin
         rslt    = z|64'h00080000_00000000;
         flag[4] = ~z[51]|((x[62:52]==11'h7ff)&~x[51]&(x[50:0]!=0))|((y[62:52]==11'h7ff)&~y[51]&(y[50:0]!=0));
      end else if(((x[62:52]==11'h7ff)|(y[62:52]==11'h7ff))&((z[62:52]==11'h7ff)))begin
         if((x[63]^y[63])==z[63])begin
            rslt    = z[63:0];
         end else begin
            rslt    = 64'hfff80000_00000000;
            flag[4] = 1'b1;
         end
      end else if(x[62:52]==11'h7ff)begin
         rslt = {x[63]^y[63],x[62:0]};
      end else if(y[62:52]==11'h7ff)begin
         rslt = {x[63]^y[63],y[62:0]};
      end else if(z[62:52]==11'h7ff)begin
         rslt = z[63:0];
      end else if((x[62:0]==0)|(y[62:0]==0))begin
         if(z[62:0]==0)
           rslt = {z[63]&(x[63]^y[63]),z[62:0]};
         else
           rslt = z;
      end else begin
         flag[0] = 1'b1;
      end
   end

endmodule

module alnseld0
  (
   input logic [52:0]        fracz,
   input logic signed [12:0] expd,
   output logic [47:0]       acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7,
   output logic [5:0]        sft0, sft1, sft2, sft3, sft4, sft5, sft6, sft7
   );
   always_comb begin
      if(expd>=180)begin
         acc0 = 0;                acc1 = 0;                acc2 = 0;                acc3 = 0;
         sft0 = 0;                sft1 = 0;                sft2 = 0;                sft3 = 0;

         acc4 = 0;                acc5 = 0;                acc6 = 0;                acc7 = 0;
         sft4 = 0;                sft5 = 0;                sft6 = 0;                sft7 = 0;
      end else if(expd>=148)begin
         acc0 = 0;                acc1 = 0;                acc2 = 0;                acc3 = 0;
         sft0 = 0;                sft1 = 0;                sft2 = 0;                sft3 = 0;

         acc4 = 0;                acc5 = 0;                acc6 = fracz[52:48];     acc7 = fracz[52:32];
         sft4 = 0;                sft5 = 0;                sft6 = expd-132;         sft7 = expd-132;
      end else if(expd>=116)begin
         acc0 = 0;                acc1 = 0;                acc2 = 0;                acc3 = 0;
         sft0 = 0;                sft1 = 0;                sft2 = 0;                sft3 = 0;

         acc4 = fracz[52:48];     acc5 = fracz[52:32];     acc6 = fracz[52:16];     acc7 = fracz;
         sft4 = expd-100;         sft5 = expd-100;         sft6 = expd-100;         sft7 = expd-100;
      end else if(expd>=84)begin
         acc0 = 0;                acc1 = 0;                acc2 = fracz[52:48];     acc3 = fracz[52:32];
         sft0 = 0;                sft1 = 0;                sft2 = expd-68;          sft3 = expd-68;

         acc4 = fracz[52:16];     acc5 = fracz;            acc6 = fracz;            acc7 = fracz[31:0];
         sft4 = expd-68;          sft5 = expd-68;          sft6 = expd-84;          sft7 = expd-100;
      end else if(expd>=52)begin
         acc0 = fracz[52:48];     acc1 = fracz[52:32];     acc2 = fracz[52:16];     acc3 = fracz;
         sft0 = expd-36;          sft1 = expd-36;          sft2 = expd-36;          sft3 = expd-36;

         acc4 = fracz;            acc5 = fracz[31:0];      acc6 = 0;                acc7 = 0;
         sft4 = expd-52;          sft5 = expd-68;          sft6 = 0;                sft7 = 0;
      end else if(expd>=20)begin
         acc0 = fracz[52:16];     acc1 = fracz;            acc2 = fracz;            acc3 = fracz[31:0];
         sft0 = expd-4;           sft1 = expd-4;           sft2 = expd-20;          sft3 = expd-36;

         acc4 = 0;                acc5 = 0;                acc6 = 0;                acc7 = 0;
         sft4 = 0;                sft5 = 0;                sft6 = 0;                sft7 = 0;
      end else if(expd>=0)begin
         acc0 = fracz;            acc1 = fracz[31:0];      acc2 = 0;                acc3 = 0;
         sft0 = expd+12;          sft1 = expd-4;           sft2 = 0;                sft3 = 0;

         acc4 = 0;                acc5 = 0;                acc6 = 0;                acc7 = 0;
         sft4 = 0;                sft5 = 0;                sft6 = 0;                sft7 = 0;
      end else begin
         acc0 = fracz;            acc1 = 0;                acc2 = 0;                acc3 = 0;
         sft0 = 12;               sft1 = 0;                sft3 = 0;                sft3 = 0;

         acc4 = 0;                acc5 = 0;                acc6 = 0;                acc7 = 0;
         sft4 = 0;                sft5 = 0;                sft6 = 0;                sft7 = 0;
      end
   end
endmodule

module fmad
  (
   input logic         clk,
   input logic         reset,
   input logic         req,
   input integer       req_command,
   input logic [63:0]   x,
   input logic [63:0]  y,
   input logic [63:0]  z,
   output logic [63:0] rslt,
   output logic [4:0]  flag,
   output              mulit muli00, muli01,
   input               mulot mulo00, mulo01,
   output              mulit muli10, muli11,
   input               mulot mulo10, mulo11,
   output              sftit sfti00, sfti01,
   input               sftot sfto00, sfto01,
   output              sftit sfti10, sfti11,
   input               sftot sfto10, sfto11,
   output              selit seli0,  seli1,
   input               selot selo0,  selo1,
   output              addit addi10, addi11,
   input               addot addo10, addo11,
   output              addit addi20, addi21,
   input               addot addo20, addo21
   );

   logic               en0, en1, en2;

   always_comb begin
      if(reset)begin
         en0 = 1'b0;
      end else begin
         en0 = req;
      end
   end
   always_ff @(posedge clk) begin
      if(reset)begin
         en1 <= 1'b0;
         en2 <= 1'b0;
      end else begin
         en1 <= en0;
         en2 <= en1;
      end
   end

   logic [4:0]        flag0i;
   logic [63:0]       rslt0i;
   logic [4:0]        flag0, flag1, flag2;
   logic [63:0]       rslt0, rslt1, rslt2;

   fmad_check fmad_check
     (
      .x(x),
      .y(y),
      .z(z),
      .rslt(rslt0i),
      .flag(flag0i)
   );

   always_ff @(posedge clk) begin
      if(en0) begin
         flag0 <= flag0i;
         rslt0 <= rslt0i;
      end
      if(en1)begin
         flag1 <= flag0;
         rslt1 <= rslt0;
      end
      if(en2)begin
         flag2 <= flag1;
         rslt2 <= rslt1;
      end
   end

   wire [52:0]         fracx = {(x[62:52]!=11'h0),x[51:0]};
   wire [52:0]         fracy = {(y[62:52]!=11'h0),y[51:0]};
   wire [52:0]         fracz = {(z[62:52]!=11'h0),z[51:0]};

   wire [10:0]         expx =       (x[62:52]==11'h0) ? 11'h1 : x[62:52];
   wire [10:0]         expy =       (y[62:52]==11'h0) ? 11'h1 : y[62:52];
   wire signed [11:0]  expz = {1'b0,(z[62:52]==11'h0) ? 11'h1 : z[62:52]};
   wire signed [12:0]  expm = expx+expy-1023;
   wire signed [12:0]  expd = expm-expz;

   logic [53:0]        mul00, mul01;

   wire [52:0]         req_in_1 = fracx[52:0];
   wire [52:0]         req_in_2 = fracy[52:0];

   mul mul00i
     (
      .clk(clk), .en(en0 & flag0i[0]),
      .out(mul00),
      .req_in_1(req_in_1[26:0]),
      .req_in_2(req_in_2[26:0]),
      .muli(muli00), .mulo(mulo00)
      );

   mul mul01i
     (
      .clk(clk), .en(en0 & flag0i[0]),
      .out(mul01),
      .req_in_1(req_in_1[52:27]),
      .req_in_2(req_in_2[26:0]),
      .muli(muli01), .mulo(mulo01)
      );

   logic [47:0]        acc00, acc01, acc02, acc03, acc04, acc05, acc06, acc07;
   logic [5:0]         sft00, sft01, sft02, sft03, sft04, sft05, sft06, sft07;

   alnseld alnsel0
     (
      .en(en0),
      .fracz(fracz[52:0]),      .expd(expd+64),
      .acc0(acc00), .acc1(acc01), .acc2(acc02), .acc3(acc03),
      .acc4(acc04), .acc5(acc05), .acc6(acc06), .acc7(acc07),
      .sft0(sft00), .sft1(sft01), .sft2(sft02), .sft3(sft03),
      .sft4(sft04), .sft5(sft05), .sft6(sft06), .sft7(sft07),
      .seli(seli0), .selo(selo0)
   );

   logic [48:0]      aln00, aln01, aln02, aln03, aln04, aln05, aln06, aln07;

   alnsft alnsft00
     (
      .clk(clk),    .en(en0 & flag0i[0]),
      .acc0(acc00), .acc1(acc01), .acc2(acc02), .acc3(acc03),
      .sft0(sft00), .sft1(sft01), .sft2(sft02), .sft3(sft03),
      .aln0(aln00), .aln1(aln01), .aln2(aln02), .aln3(aln03),
      .sfti(sfti00),      .sfto(sfto00)
      );

   alnsft alnsft01
     (
      .clk(clk),    .en(en0 & flag0i[0]),
      .acc0(acc04), .acc1(acc05), .acc2(acc06), .acc3(acc07),
      .sft0(sft04), .sft1(sft05), .sft2(sft06), .sft3(sft07),
      .aln0(aln04), .aln1(aln05), .aln2(aln06), .aln3(aln07),
      .sfti(sfti01),      .sfto(sfto01)
      );

/////////
   logic [169:0]       align0i;
   logic [54:0]        aligng0i;
   
   always_comb begin
      if(expd+64>=55+116)begin
         align0i = 'h0;
      end else if(expd+64>=0)begin
         align0i = {fracz,116'h0} >> (expd+64);
      end else begin
         align0i = {fracz,116'h0};
      end
      if(expd+64>=55+116)begin
         aligng0i = fracz;
      end else if(expd+64>=116)begin
         aligng0i = {fracz,55'h0} >> (expd+64-116);
      end else begin
         aligng0i = 55'h0;
      end
   end

   logic [169:0]       align0;
   logic [2:0]         aligng0;

   wire [169:0]        alignt = {align0[169:128],
                                 aln00[15:0], aln01[15:0], aln02[15:0], aln03[15:0],
                                 aln04[15:0], aln05[15:0], aln06[15:0], aln07[15:0]};

   logic signed [12:0] expa0;
   logic               sgnz0;
   logic               sgnm0;
   logic signed [12:0] expd0;

   always_ff @(posedge clk) begin
      if(en0 & flag0i[0])begin
         align0 <= align0i;
         aligng0 <= {aligng0i[54:53],(|aligng0i[52:0])};
         if(expd+64>0)begin
            expa0 <= expm+63;
            expd0 <= expd+64+128;
         end else begin
            expa0 <= expz-1;
            expd0 <= 128;
         end
         sgnz0 <= z[63];
         sgnm0 <= x[63]^y[63];
      end
   end

   logic [145:0]       add1;
   logic [65:64]       cout1;

   add add10i
     (
      .clk(clk),          .en(en1 & flag0[0]),
      .cout(cout1),       .out(add1[63:0]),
      .sub(sgnm0^sgnz0),  .cin({sgnm0^sgnz0,1'b0}),
      .req_in_0(mul00),   .req_in_1({mul01[36:0],27'h0}),         .req_in_2(64'h0),
      .aln0(aln04[15:0]), .aln1(aln05[15:0]), .aln2(aln06[15:0]), .aln3(aln07[15:0]),
      .addi(addi10),      .addo(addo10)
      );

   add add11i
     (
      .clk(clk),          .en(en1 & flag0[0]),
      .cout(),            .out(add1[145:64]),
      .sub(sgnm0^sgnz0),  .cin(cout1),
      .req_in_0(64'h0),   .req_in_1(mul01[53:37]),                .req_in_2(64'h0),
      .aln0(aln00[15:0]), .aln1(aln01[15:0]), .aln2(aln02[15:0]), .aln3(aln03[15:0]),
      .addi(addi11),      .addo(addo11)
      );

   logic [53:0]        mul10,mul11;

   mul mul10i
     (
      .clk(clk),          .en(en1 & flag0[0]),
      .out(mul10),
      .req_in_1(req_in_1[26:0]), .req_in_2(req_in_2[52:27]),
      .muli(muli10),      .mulo(mulo10)
      );

   mul mul11i
     (
      .clk(clk),          .en(en1 & flag0[0]),
      .out(mul11),
      .req_in_1(req_in_1[52:27]), .req_in_2(req_in_2[52:27]),
      .muli(muli11),      .mulo(mulo11)
      );

   logic [47:0]        acc10, acc11, acc12, acc13, acc14, acc15, acc16, acc17;
   logic [5:0]         sft10, sft11, sft12, sft13, sft14, sft15, sft16, sft17;

   alnseld alnsel1
     (
      .en(en1),
      .fracz(fracz[52:0]),      .expd(expd0),
      .acc0(acc10), .acc1(acc11), .acc2(acc12), .acc3(acc13),
      .acc4(acc14), .acc5(acc15), .acc6(acc16), .acc7(acc17),
      .sft0(sft10), .sft1(sft11), .sft2(sft12), .sft3(sft13),
      .sft4(sft14), .sft5(sft15), .sft6(sft16), .sft7(sft17),
      .seli(seli1), .selo(selo1)
   );

   logic [48:0]        aln10, aln11, aln12, aln13, aln14, aln15, aln16, aln17;

   alnsft alnsft10
     (
      .clk(clk),    .en(en1 & flag0[0]),
      .acc0(acc10), .acc1(acc11), .acc2(acc12), .acc3(acc13),
      .sft0(sft10), .sft1(sft11), .sft2(sft12), .sft3(sft13),
      .aln0(aln10), .aln1(aln11), .aln2(aln12), .aln3(aln13),
      .sfti(sfti10),      .sfto(sfto10)
      );

   alnsft alnsft11
     (
      .clk(clk),    .en(en1 & flag0[0]),
      .acc0(acc14), .acc1(acc15), .acc2(acc16), .acc3(acc17),
      .sft0(sft14), .sft1(sft15), .sft2(sft16), .sft3(sft17),
      .aln0(aln14), .aln1(aln15), .aln2(aln16), .aln3(aln17),
      .sfti(sfti11),      .sfto(sfto11)
      );

   logic [12:0]        expr1;
   logic               sgnz1;
   logic               sgnm1;
   logic               alnm1;
   logic [2:0]         addg1;

   always_ff @(posedge clk) begin
      if(en1 & flag0[0])begin
         sgnz1 <= sgnz0;
         sgnm1 <= sgnm0;
         expr1 <= expa0;
         alnm1 <= (expd<-1);
         addg1 <= aligng0;
      end
   end

   logic [143:0]       add2in0, add2in1, add2in2, add2in3;
   wire [169:128]      align1 = {aln15[15:0], aln16[15:0], aln17[15:0]};

   always_comb  begin
      if(alnm1)begin
         add2in0 = mul10;
         add2in1 = {mul11,27'h0};
         add2in2 = {{25{add1[145]}},add1[144:27]};
         add2in3 = {align1,53'h0,48'h0};
      end else begin
         add2in0 = {mul10,48'h0};
         add2in1 = {mul11,27'h0,48'h0};
         add2in2 = {add1[144:0],addg1,18'h0};
         add2in3 = 'h0;
      end
   end

   logic [169:27]      add2h;
   logic [65:64]       cout2;

   add add20i
     (
      .clk(clk),          .en(en2 & flag1[0]),
      .cout(cout2),       .out(add2h[63+27:27]),
      .sub(sgnz1^sgnm1),  .cin({sgnm1^sgnz1,1'b0}),
      .req_in_0(add2in0[63:0]),      .req_in_1(add2in1[63:0]),      .req_in_2(add2in2[63:0]),
      .aln0(add2in3[63:48]), .aln1(add2in3[47:32]), .aln2(add2in3[31:16]), .aln3(add2in3[15: 0]),
      .addi(addi20),      .addo(addo20)
      );

   add add21i
     (
      .clk(clk),          .en(en2 & flag1[0]),
      .cout(),            .out(add2h[169:64+27]),
      .sub(sgnz1^sgnm1),  .cin(cout2),
      .req_in_0(add2in0[143:64]),    .req_in_1(add2in1[143:64]),    .req_in_2(add2in2[143:64]),
      .aln0(add2in3[143:112]), .aln1(add2in3[111: 96]), .aln2(add2in3[ 95: 80]), .aln3(add2in3[ 79: 64]),
      .addi(addi21),      .addo(addo21)
      );

   logic [12:0]        expr2;
   logic               sgnr2;
   logic [26:0]        add2l;

   always_ff @(posedge clk) begin
      if(en2 & flag1[0])begin
         sgnr2 <= sgnz1;
         if(alnm1)begin
            expr2 <= expr1;
            add2l[26:0] <= add1[26:0];
         end else begin
            expr2 <= expr1 -48;
            add2l[26:0] <= 27'h0;
         end
      end
   end


   wire [169:0]        add2 = {add2h,add2l};

   logic [128:0]       nrmi,nrm0,nrm1,nrm2,nrm3,nrm4,nrm5,nrm6;
   logic [1:0]         ssn;

   logic [6:0]         nrmsft;                                // expr >= nrmsft : subnormal output
   assign nrmsft[6] = (~(|add2[169:105])|(&add2[169:105]))& (expr2[12:6]!=7'h0);
   assign nrmsft[5] = (~(|nrm6[128: 96])|(&nrm6[128: 96]))&((expr2[12:5]&{6'h3f,~nrmsft[6]  ,1'b1})!=8'h0);
   assign nrmsft[4] = (~(|nrm5[128:112])|(&nrm5[128:112]))&((expr2[12:4]&{6'h3f,~nrmsft[6:5],1'b1})!=9'h0);
   assign nrmsft[3] = (~(|nrm4[128:120])|(&nrm4[128:120]))&((expr2[12:3]&{6'h3f,~nrmsft[6:4],1'b1})!=10'h0);
   assign nrmsft[2] = (~(|nrm3[128:124])|(&nrm3[128:124]))&((expr2[12:2]&{6'h3f,~nrmsft[6:3],1'b1})!=11'h0);
   assign nrmsft[1] = (~(|nrm2[128:126])|(&nrm2[128:126]))&((expr2[12:1]&{6'h3f,~nrmsft[6:2],1'b1})!=12'h0);
   assign nrmsft[0] = (~(|nrm1[128:127])|(&nrm1[128:127]))&((expr2[12:0]&{6'h3f,~nrmsft[6:1],1'b1})!=13'h0);

   assign nrmi = {add2[169:42],(|add2[41:0])};
   assign nrm6 = (~nrmsft[6]) ? nrmi : {add2[105:0], 23'h0};
   assign nrm5 = (~nrmsft[5]) ? nrm6 : {nrm6[ 96:0], 32'h0};
   assign nrm4 = (~nrmsft[4]) ? nrm5 : {nrm5[112:0], 16'h0};
   assign nrm3 = (~nrmsft[3]) ? nrm4 : {nrm4[120:0],  8'h0};
   assign nrm2 = (~nrmsft[2]) ? nrm3 : {nrm3[124:0],  4'h0};
   assign nrm1 = (~nrmsft[1]) ? nrm2 : {nrm2[126:0],  2'b0};
   assign nrm0 = (~nrmsft[0]) ? nrm1 : {nrm1[127:0],  1'b0};
   assign ssn = {nrm0[73],(|nrm0[72:0])};

   wire [2:0]          grsn = {nrm0[75:74],(|ssn)};
   wire                rnd = (~nrmi[128]) ? (grsn[1:0]==2'b11)|(grsn[2:1]==2'b11)
                                          : ((grsn[1:0]==2'b00)|                          // inc
                                            ((grsn[1]^grsn[0])     &(grsn[0]))|          // rs=11
                                            ((grsn[2]^(|grsn[1:0]))&(grsn[1]^grsn[0]))); // gr=11
   wire [13:0]         expn = expr2-nrmsft+{1'b0,(nrm0[128]^nrm0[127])}; // subnormal(+0) or normal(+1)

   wire [62:0]         rsltr = (~nrm0[128]) ? {expn,nrm0[126:75]}+rnd : {expn,~nrm0[126:75]}+rnd;

   always @ (*) begin
      rslt[63] = sgnr2^add2[169];
      flag = 0;
      if(flag2[0] == 1'b0)begin
         rslt = rslt2;
         flag = flag2;
      end else if(nrmi==0)begin
         rslt[63:0] = 64'h00000000_00000000;
      end else if(expn[13])begin
         rslt[62:0] = 63'h00000000_00000000;
         flag[0] = 1'b1;
         flag[1] = 1'b1;
      end else if((expn[12:0]>=12'h7ff)&(~expn[13]))begin
         rslt[62:0] = 63'h7ff00000_00000000;
         flag[0] = 1'b1;
         flag[2] = 1'b1;
      end else if(~nrm0[128])begin
         rslt[62:0] = rsltr[62:0];
         flag[0] = |grsn[1:0] | (rsltr[62:52]==11'h7ff);
         flag[1] = ((rsltr[62:52]==11'h000)|((expn[10:0]==11'h000)&~ssn[1]))&(|grsn[1:0]);
         flag[2] =  (rsltr[62:52]==11'h7ff);
      end else begin
         rslt[62:0] = rsltr[62:0];
         flag[0] = |grsn[1:0] | (rsltr[62:52]==11'h7ff);
         flag[1] = ((rsltr[62:52]==11'h000)|((expn[10:0]==11'h000)&((~ssn[1]&~ssn[0])|(ssn[1]&ssn[0])) ))&(|grsn[1:0]);
         flag[2] =  (rsltr[62:52]==11'h7ff);
      end
   end

endmodule
