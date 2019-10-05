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
         flag[4] = ~z[51]|((x[62:23]==11'h7ff)&~x[51]&(x[50:0]!=0))|((y[62:52]==11'h7ff)&~y[51]&(y[50:0]!=0));
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

module fmad
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

   logic[4:0]         flag0i;
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

   logic [105:0]       muli;

   wire [52:0]         req_in_1 = fracx[52:0];
   wire [52:0]         req_in_2 = fracy[52:0];

   assign muli = req_in_1 * req_in_2;

   logic [169:0]       aligni;
   
   always_comb begin
      if(expd>-64)begin
         aligni = {fracz,116'h0} >> (expd+64);
      end else begin
         aligni = {fracz,116'h0};
      end
   end

   logic [105:0]       mul;
   logic [169:0]       align;
   logic signed [12:0] expa;
   logic               sgnz;
   logic               sgnm;

   always_ff @(posedge clk) begin
      if(en0)begin
         mul <= muli;
         align <= aligni;
         if(expd>-64)begin
            expa <= expm+63;
         end else begin
            expa <= expz-1;
         end
         sgnz <= z[63];
         sgnm <= x[63]^y[63];
      end
   end

   logic [169:0]       addi;

   always_comb begin
      if(sgnm^sgnz)begin
         addi = mul - align;
      end else begin
         addi = mul + align;
      end
   end

   logic [169:0]       add;
   logic [12:0]        expr;
   logic               sgnr;

   always_ff @(posedge clk) begin
      if(en1 & flag0[0])begin
         add[169:0] <= addi;
         sgnr <= sgnm;
         expr <= expa;
      end
   end

   logic [128:0]       nrmi,nrm0,nrm1,nrm2,nrm3,nrm4,nrm5,nrm6;
   logic [1:0]         ssn;

   logic [6:0]         nrmsft;                                // expr >= nrmsft : subnormal output
   assign nrmsft[6] = (~(|nrmi[128: 64])|(&nrmi[128: 64]))& (expr[12:6]!=4'h0);
   assign nrmsft[5] = (~(|nrm6[128: 96])|(&nrm6[128: 96]))&((expr[12:5]&{6'h1f,~nrmsft[6  ],1'b1})!=8'h0);
   assign nrmsft[4] = (~(|nrm5[128:112])|(&nrm5[128:112]))&((expr[12:4]&{6'h1f,~nrmsft[6:5],1'b1})!=9'h0);
   assign nrmsft[3] = (~(|nrm4[128:120])|(&nrm4[128:120]))&((expr[12:3]&{6'h1f,~nrmsft[6:4],1'b1})!=10'h0);
   assign nrmsft[2] = (~(|nrm3[128:124])|(&nrm3[128:124]))&((expr[12:2]&{6'h1f,~nrmsft[6:3],1'b1})!=11'h0);
   assign nrmsft[1] = (~(|nrm2[128:126])|(&nrm2[128:126]))&((expr[12:1]&{6'h1f,~nrmsft[6:2],1'b1})!=12'h0);
   assign nrmsft[0] = (~(|nrm1[128:127])|(&nrm1[128:127]))&((expr[12:0]&{6'h3f,~nrmsft[6:1],1'b1})!=13'h0);

   assign nrmi = {add[169:42],(|add[41:0])};

   assign nrm6 = (~nrmsft[6]) ? nrmi : { add[105:0], 23'h0};
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
   wire [13:0]         expn = expr-nrmsft+{1'b0,(nrm0[128]^nrm0[127])}; // subnormal(+0) or normal(+1)

   wire [62:0]         rsltr = (~nrm0[128]) ? {expn,nrm0[126:75]}+rnd : {expn,~nrm0[126:75]}+rnd;

   always @ (*) begin
      rslt[63] = sgnr^add[169];
      flag = 0;
      if(flag1[0] == 1'b0)begin
         rslt = rslt1;
         flag = flag1;
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
      end else if(~nrm0[64])begin
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
