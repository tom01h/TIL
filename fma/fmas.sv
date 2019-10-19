module fmas_check
  (
   input logic [31:0]  x,
   input logic [31:0]  y,
   input logic [31:0]  z,
   output logic [31:0] rslt,
   output logic [4:0]  flag
   );

   always_comb begin
      rslt = {32{1'bx}};
      flag = 5'h0;
      if((x[30:23]==8'hff)&(x[22:0]!=0))begin
         rslt    = x|32'h00400000;
         flag[4] = ~x[22]|((y[30:23]==8'hff)&~y[22]&(y[21:0]!=0))|((z[30:23]==8'hff)&~z[22]&(z[21:0]!=0));
      end else if((y[30:23]==8'hff)&(y[22:0]!=0))begin
         rslt    = y|32'h00400000;
         flag[4] = ~y[22]|((x[30:23]==8'hff)&~x[22]&(x[21:0]!=0))|((z[30:23]==8'hff)&~z[22]&(z[21:0]!=0));
      end else if(((x[30:23]==8'hff)&(y[30:0]==0))|((y[30:23]==8'hff)&(x[30:0]==0)))begin
         rslt    = 32'hffc00000;
         flag[4] = 1'b1;
      end else if((z[30:23]==8'hff)&(z[22:0]!=0))begin
         rslt    = z|32'h00400000;
         flag[4] = ~z[22]|((x[30:23]==8'hff)&~x[22]&(x[21:0]!=0))|((y[30:23]==8'hff)&~y[22]&(y[21:0]!=0));
      end else if(((x[30:23]==8'hff)|(y[30:23]==8'hff))&((z[30:23]==8'hff)))begin
         if((x[31]^y[31])==z[31])begin
            rslt    = z[31:0];
         end else begin
            rslt    = 32'hffc00000;
            flag[4] = 1'b1;
         end
      end else if(x[30:23]==8'hff)begin
         rslt = {x[31]^y[31],x[30:0]};
      end else if(y[30:23]==8'hff)begin
         rslt = {x[31]^y[31],y[30:0]};
      end else if(z[30:23]==8'hff)begin
         rslt = z[31:0];
      end else if((x[30:0]==0)|(y[30:0]==0))begin
         if(z[30:0]==0)
           rslt = {z[31]&(x[31]^y[31]),z[30:0]};
         else
           rslt = z;
      end else begin
         flag[0] = 1'b1;
      end
   end

endmodule

module fmas
  (
   input logic         clk,
   input logic         reset,
   input logic         req,
   input integer       req_command,
   input logic [31:0]  x,
   input logic [31:0]  y,
   input logic [31:0]  z,
   output logic [31:0] rslt,
   output logic [4:0]  flag,
   output              mulit muli0,
   input               mulot mulo0,
   output              sftit sfti0,
   input               sftot sfto0,
   output              addit addi1,
   input               addot addo1
   );

   logic               en0, en1;

   always_comb begin
      if(reset)begin
         en0 = 1'b0;
      end else begin
         en0 = req;
      end
   end
   always_ff @ (posedge clk) begin
      if(reset)begin
         en1 <= 1'b0;
      end else begin
         en1 <= en0;
      end
   end

   logic [4:0]       flag0i;
   logic [31:0]      rslt0i;
   logic [4:0]       flag0, flag1;
   logic [31:0]      rslt0, rslt1;

   fmas_check fmas_check
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
   end

   wire [23:0]       fracx = {(x[30:23]!=8'h00),x[22:0]};
   wire [23:0]       fracy = {(y[30:23]!=8'h00),y[22:0]};
   wire [31:0]       fracz = {(z[30:23]!=8'h00),z[22:0],8'h0};

   wire [7:0]        expx =       (x[30:23]==8'h00) ? 8'h01 : x[30:23];
   wire [7:0]        expy =       (y[30:23]==8'h00) ? 8'h01 : y[30:23];
   wire signed [8:0] expz = {1'b0,(z[30:23]==8'h00) ? 8'h01 : z[30:23]};
   wire signed [9:0] expm = expx+expy-127+1;
   wire signed [9:0] expd = expm-expz;

   wire [26:0]       req_in_1 = {3'b0,fracx[23:0]};
   wire [26:0]       req_in_2 = {3'b0,fracy[23:0]};

   logic [53:0]      mul;

   mul mul0i
     (
      .clk(clk),
      .en(en0 & flag0i[0]),
      .req_in_1(req_in_1),
      .req_in_2(req_in_2),
      .out(mul),
      .muli(muli0),
      .mulo(mulo0)

   );

   logic [5:0]       sfti;
   logic [47:0]      acc0, acc1, acc2, acc3;
   logic [5:0]       sft0, sft1, sft2, sft3;

   always_comb begin
      if(expd>=55)begin
         sfti = 55;
      end else if(expd>=0)begin
         sfti = expd;
      end else if(expd>=-32)begin
         sfti = expd+32;
      end else begin
         sfti = 0;
      end

      if(sfti>=32)begin
         acc0 = 0;            acc1 = fracz;        acc2 = fracz;        acc3 = fracz;
         sft0 = 0;            sft1 = sfti;         sft2 = sfti-16;      sft3 = sfti-32;
      end else begin
         acc0 = fracz;        acc1 = fracz;        acc2 = fracz;        acc3 = 0;
         sft0 = sfti+16;      sft1 = sfti;         sft2 = sfti-16;      sft3 = 0;
      end
   end

   logic [48:0]      aln0, aln1, aln2, aln3;

   alnsft alnsft0
     (
      .clk(clk),   .en(en0 & flag0i[0]),
      .acc0(acc0), .acc1(acc1), .acc2(acc2), .acc3(acc3),
      .sft0(sft0), .sft1(sft1), .sft2(sft2), .sft3(sft3),
      .aln0(aln0), .aln1(aln1), .aln2(aln2), .aln3(aln3),
      .sfti(sfti0),      .sfto(sfto0)
      );

   logic [8:0]       expa0;
   logic             sgnz0;
   logic             sgnm0;

   logic             alnm0;

   always_ff @ (posedge clk) begin
      if(en0 & flag0i[0])begin
         sgnz0 <= z[31];
         sgnm0 <= x[31]^y[31];
         if(expd>=0)begin
            expa0 <= expm;
         end else if(expd>=-32)begin
            expa0 <= expm+32;
         end else begin
            expa0 <= expz;
         end

         if(expd>=0)begin
            alnm0 <= 1'b0;
         end else begin
            alnm0 <= 1'b1;
         end
      end
   end

   logic [79:0]      alnmul;

   always_comb begin
      if(alnm0)begin
         alnmul = {32'h0,mul[47:0]};
      end else begin
         alnmul = {mul[47:0],32'h0};
      end
   end

   logic [81:0]      add;

   add add1i
     (
      .clk(clk),
      .en(en1 & flag0[0]),
      .cout(),
      .sub(sgnm0^sgnz0),
      .cin({sgnm0^sgnz0,1'b0}),
      .req_in_0(alnmul),
      .req_in_1('h0),
      .req_in_2('h0),
      .aln0(aln0),      .aln1(aln1),      .aln2(aln2),      .aln3(aln3),
      .out(add),
      .addi(addi1),
      .addo(addo1)
   );

   logic [8:0]       expr1;
   logic             sgnr1;

   always_ff @(posedge clk) begin
      if(en1 & flag0[0])begin
         sgnr1 <= sgnz0;
         expr1 <= expa0;
      end
   end

   logic [64:0]  nrmi,nrm0,nrm1,nrm2,nrm3,nrm4,nrm5;
   logic [1:0]   ssn;

   logic [5:0]   nrmsft;                                // expr >= nrmsft : subnormal output
   assign nrmsft[5] = (~(|nrmi[64:32])|(&nrmi[64:32]))& (expr1[8:5]!=4'h0);
   assign nrmsft[4] = (~(|nrm5[64:48])|(&nrm5[64:48]))&((expr1[8:4]&{3'h7,~nrmsft[5],  1'b1})!=5'h00);
   assign nrmsft[3] = (~(|nrm4[64:56])|(&nrm4[64:56]))&((expr1[8:3]&{3'h7,~nrmsft[5:4],1'b1})!=6'h00);
   assign nrmsft[2] = (~(|nrm3[64:60])|(&nrm3[64:60]))&((expr1[8:2]&{3'h7,~nrmsft[5:3],1'b1})!=7'h00);
   assign nrmsft[1] = (~(|nrm2[64:62])|(&nrm2[64:62]))&((expr1[8:1]&{3'h7,~nrmsft[5:2],1'b1})!=8'h00);
   assign nrmsft[0] = (~(|nrm1[64:63])|(&nrm1[64:63]))&((expr1[8:0]&{3'h7,~nrmsft[5:1],1'b1})!=9'h000);

   assign nrmi = {add[81:18],(|add[17:0])};
   assign nrm5 = (~nrmsft[5]) ? nrmi : {add[49:0], 15'h0};
   assign nrm4 = (~nrmsft[4]) ? nrm5 : {nrm5[48:0], 16'h0000};
   assign nrm3 = (~nrmsft[3]) ? nrm4 : {nrm4[56:0], 8'h00};
   assign nrm2 = (~nrmsft[2]) ? nrm3 : {nrm3[60:0], 4'h0};
   assign nrm1 = (~nrmsft[1]) ? nrm2 : {nrm2[62:0], 2'b00};
   assign nrm0 = (~nrmsft[0]) ? nrm1 : {nrm1[63:0], 1'b0};
   assign ssn = {nrm0[38],(|nrm0[37:0])};

   wire [2:0]    grsn = {nrm0[40:39],(|ssn)};
   wire          rnd = (~nrmi[64]) ? (grsn[1:0]==2'b11)|(grsn[2:1]==2'b11)
                                   : ((grsn[1:0]==2'b00)|                          // inc
                                      ((grsn[1]^grsn[0])     &(grsn[0]))|          // rs=11
                                      ((grsn[2]^(|grsn[1:0]))&(grsn[1]^grsn[0]))); // gr=11
   wire [9:0]    expn = expr1-nrmsft+{1'b0,(nrm0[64]^nrm0[63])}; // subnormal(+0) or normal(+1)

   wire [30:0]   rsltr = (~nrm0[64]) ? {expn,nrm0[62:40]}+rnd : {expn,~nrm0[62:40]}+rnd;

   always_comb begin
      rslt[31] = sgnr1^add[81];
      flag = 0;
      if(flag1[0] == 1'b0)begin
         rslt = rslt1;
         flag = flag1;
      end else if(nrmi==0)begin
         rslt[31:0] = 32'h00000000;
      end else if(expn[9])begin
         rslt[30:0] = 31'h00000000;
         flag[0] = 1'b1;
         flag[1] = 1'b1;
      end else if((expn[8:0]>=9'h0ff)&(~expn[9]))begin
         rslt[30:0] = 31'h7f800000;
         flag[0] = 1'b1;
         flag[2] = 1'b1;
      end else if(~nrm0[64])begin
         rslt[30:0] = rsltr[30:0];
         flag[0] = |grsn[1:0] | (rsltr[30:23]==8'hff);
         flag[1] = ((rsltr[30:23]==8'h00)|((expn[7:0]==8'h00)&~ssn[1]))&(|grsn[1:0]);
         flag[2] = (rsltr[30:23]==8'hff);
      end else begin
         rslt[30:0] = rsltr[30:0];
         flag[0] = |grsn[1:0] | (rsltr[30:23]==8'hff);
         flag[1] = ((rsltr[30:23]==8'h00)|((expn[7:0]==8'h00)&((~ssn[1]&~ssn[0])|(ssn[1]&ssn[0])) ))&(|grsn[1:0]);
         flag[2] = (rsltr[30:23]==8'hff);
      end
   end

endmodule
