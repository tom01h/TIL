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

module mul0
  (
   input logic         clk,
   input logic         en,
   output logic [53:0] out,
   input logic [26:0]  req_in_1,
   input logic [26:0]  req_in_2
   );

   always_ff @(posedge clk)begin
      if(en)begin
         out <= req_in_1 * req_in_2;
      end
   end

endmodule

module add0
  (
   input logic          clk,
   input logic          en,
   output logic [65:64] cout,
   output logic [81:0] out,
   input logic          sub,
   input logic [1:0]    cin,
   input logic [79:0]  req_in_0,
   input logic [79:0]  req_in_1,
   input logic [79:0]  req_in_2,
   input logic [79:0]  req_in_3
   );

   logic [81:64]       sumh;
   logic [65:0]         suml;

   assign cout = suml[65:64];

   always_comb begin
      if(sub)begin
         suml = {1'b0, req_in_3[63: 0]} + {1'b0, req_in_2[63: 0]} +
                {1'b0,~req_in_1[63: 0]} + {1'b0,~req_in_0[63: 0]} + cin;
         sumh =        req_in_3[79:64]  +        req_in_2[79:64]  +
                      ~req_in_1[79:64]  +       ~req_in_0[79:64]  + suml[65:64];
      end else begin
         suml = {1'b0, req_in_3[63: 0]} + {1'b0, req_in_2[63: 0]} +
                {1'b0, req_in_1[63: 0]} + {1'b0, req_in_0[63: 0]} + cin;
         sumh =        req_in_3[79:64]  +        req_in_2[79:64]  +
                       req_in_1[79:64]  +        req_in_0[79:64]  + suml[65:64];
      end
   end

   always_ff @(posedge clk)begin
      if(en)begin
         out <= {sumh,suml[63:0]};
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
      .clk(clk),
      .en(en0),
      .out(mul00),
      .req_in_1(req_in_1[26:0]),
      .req_in_2(req_in_2[26:0]),
      .muli(muli00),
      .mulo(mulo00)
      );

   mul mul01i
     (
      .clk(clk),
      .en(en0),
      .out(mul01),
      .req_in_1(req_in_1[52:27]),
      .req_in_2(req_in_2[26:0]),
      .muli(muli01),
      .mulo(mulo01)
      );

   logic [169:0]       align0i;
   logic [54:0]        aligng0i;
   
   always_comb begin
      if(expd>53+117-64)begin
         {align0i,aligng0i} = {'h0,fracz};
      end else if(expd>-64)begin
         {align0i,aligng0i} = {fracz,116'h0,55'h0} >> (expd+64);
      end else begin
         {align0i,aligng0i} = {fracz,116'h0,55'h0};
      end
   end

   logic [169:0]       align0;
   logic [2:0]         aligng0;
   logic signed [12:0] expa0;
   logic               sgnz0;
   logic               sgnm0;

   always_ff @(posedge clk) begin
      if(en0)begin
         align0 <= align0i;
         aligng0 <= {aligng0i[54:53],(|aligng0i[52:0])};
         if(expd>-64)begin
            expa0 <= expm+63;
         end else begin
            expa0 <= expz-1;
         end
         sgnz0 <= z[63];
         sgnm0 <= x[63]^y[63];
      end
   end

   logic [145:0]       add1;
   logic [65:64]       cout1;

   add add10i
     (
      .clk(clk),
      .en(en1 & flag0[0]),
      .cout(cout1),
      .out(add1[63:0]),
      .sub(sgnm0^sgnz0),
      .cin({sgnm0^sgnz0,1'b0}),
      .req_in_0(mul00),
      .req_in_1({mul01[36:0],27'h0}),
      .req_in_2(align0[63:0]),
      .req_in_3(64'h0),
      .addi(addi10),
      .addo(addo10)
      );

   add add11i
     (
      .clk(clk),
      .en(en1 & flag0[0]),
      .cout(),
      .out(add1[145:64]),
      .sub(sgnm0^sgnz0),
      .cin(cout1),
      .req_in_0(64'h0),
      .req_in_1(mul01[53:37]),
      .req_in_2(align0[143:64]),
      .req_in_3(64'h0),
      .addi(addi11),
      .addo(addo11)
      );

   logic [53:0]        mul10,mul11;

   mul mul10i
     (
      .clk(clk),
      .en(en1 & flag0[0]),
      .out(mul10),
      .req_in_1(req_in_1[26:0]),
      .req_in_2(req_in_2[52:27]),
      .muli(muli10),
      .mulo(mulo10)
      );

   mul mul11i
     (
      .clk(clk),
      .en(en1 & flag0[0]),
      .out(mul11),
      .req_in_1(req_in_1[52:27]),
      .req_in_2(req_in_2[52:27]),
      .muli(muli11),
      .mulo(mulo11)
      );

   logic [12:0]        expr1;
   logic               sgnz1;
   logic               sgnm1;
   logic [2:0]         addg1;
   logic [169:144]     align1;

   always_ff @(posedge clk) begin
      if(en1 & flag0[0])begin
         sgnz1 <= sgnz0;
         sgnm1 <= sgnm0;
         expr1 <= expa0;
         addg1 <= aligng0;
         align1 <= align0[169:144];
      end
   end

   logic [169:27]      add2h;
   logic [65:64]       cout2;

   add add20i
     (
      .clk(clk),
      .en(en2 & flag1[0]),
      .cout(cout2),
      .out(add2h[63+27:27]),
      .sub(sgnz1^sgnm1),
      .cin({sgnm1^sgnz1,1'b0}),
      .req_in_0(mul10),
      .req_in_1({mul11[36:0],27'h0}),
      .req_in_2(add1[63+27:27]),
      .req_in_3(64'h0),
      .addi(addi20),
      .addo(addo20)
      );

   add add21i
     (
      .clk(clk),
      .en(en2 & flag1[0]),
      .cout(),
      .out(add2h[169:64+27]),
      .sub(sgnz1^sgnm1),
      .cin(cout2),
      .req_in_0(64'h0),
      .req_in_1(mul11[53:37]),
      .req_in_2({{25{add1[145]}},add1[144:64+27]}),
      .req_in_3({align1,53'h0}),
      .addi(addi21),
      .addo(addo21)
      );

   logic [12:0]        expr2;
   logic               sgnr2;
   logic [2:0]         addg2;
   logic [26:0]        add2l;

   always_ff @(posedge clk) begin
      if(en2 & flag1[0])begin
         sgnr2 <= sgnz1;
         expr2 <= expr1;
         add2l[26:0] <= add1[26:0];
         addg2 <= addg1;
      end
   end


   wire [169:0]        add2 = {add2h,add2l};

   logic [256:0]       nrmi,nrm7;
   logic [128:0]       nrm0,nrm1,nrm2,nrm3,nrm4,nrm5,nrm6;
   logic [1:0]         ssn;

   logic [7:0]         nrmsft;                                // expr >= nrmsft : subnormal output
   assign nrmsft[7] = (~(|add2[169: 41])|(&add2[169: 41]))& (expr2[12:7]!=6'h0);
   assign nrmsft[6] = (~(|nrm7[256:192])|(&nrm7[256:192]))&((expr2[12:6]&{5'h1f,~nrmsft[7  ],1'b1})!=7'h0);
   assign nrmsft[5] = (~(|nrm6[128: 96])|(&nrm6[128: 96]))&((expr2[12:5]&{5'h1f,~nrmsft[7:6],1'b1})!=8'h0);
   assign nrmsft[4] = (~(|nrm5[128:112])|(&nrm5[128:112]))&((expr2[12:4]&{5'h1f,~nrmsft[7:5],1'b1})!=9'h0);
   assign nrmsft[3] = (~(|nrm4[128:120])|(&nrm4[128:120]))&((expr2[12:3]&{5'h1f,~nrmsft[7:4],1'b1})!=10'h0);
   assign nrmsft[2] = (~(|nrm3[128:124])|(&nrm3[128:124]))&((expr2[12:2]&{5'h1f,~nrmsft[7:3],1'b1})!=11'h0);
   assign nrmsft[1] = (~(|nrm2[128:126])|(&nrm2[128:126]))&((expr2[12:1]&{5'h1f,~nrmsft[7:2],1'b1})!=12'h0);
   assign nrmsft[0] = (~(|nrm1[128:127])|(&nrm1[128:127]))&((expr2[12:0]&{5'h1f,~nrmsft[7:1],1'b1})!=13'h0);

   assign nrmi = {add2[169:0],addg2[2:0],84'h0};
   assign nrm7 = (~nrmsft[7]) ? nrmi : { add2[ 41:0], addg2[2:0],84'h0,128'h0};
   assign nrm6 = (~nrmsft[6]) ? {nrm7[256:129],(|nrm7[128:0])} : {nrm7[192:65],(|nrm7[64:0])};
   assign nrm5 = (~nrmsft[5]) ? nrm6 : {nrm6[ 96:0], 32'h0};
   assign nrm4 = (~nrmsft[4]) ? nrm5 : {nrm5[112:0], 16'h0};
   assign nrm3 = (~nrmsft[3]) ? nrm4 : {nrm4[120:0],  8'h0};
   assign nrm2 = (~nrmsft[2]) ? nrm3 : {nrm3[124:0],  4'h0};
   assign nrm1 = (~nrmsft[1]) ? nrm2 : {nrm2[126:0],  2'b0};
   assign nrm0 = (~nrmsft[0]) ? nrm1 : {nrm1[127:0],  1'b0};
   assign ssn = {nrm0[73],(|nrm0[72:0])};

   wire [2:0]          grsn = {nrm0[75:74],(|ssn)};
   wire                rnd = (~nrmi[256]) ? (grsn[1:0]==2'b11)|(grsn[2:1]==2'b11)
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
