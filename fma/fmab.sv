module fmab
  (
   input logic         clk,
   input logic         reset,
   input logic         req,
   input integer       req_command,
   input logic [31:0]  x,
   input logic [31:0]  y,
   input logic [31:0]  z,
   input logic [31:0]  w,
   output logic [31:0] acc0, acc1, acc2, acc3,
   output logic [ 9:0] exp0, exp1, exp2, exp3,
   mul_if              mul_if,
   alnsft_if           alnsft_if,
   add_if              add_if
   );

   logic               en0, en1;

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
      end else begin
         en1 <= en0;
      end
   end

   logic [63:0]        mul;
   wire [31:0]         req_in_1 = {1'b1,x[6:0],  1'b1,y[6:0],  1'b1,z[6:0],  1'b1,w[6:0]};
   wire [31:0]         req_in_2 = {1'b1,x[22:16],1'b1,y[22:16],1'b1,z[22:16],1'b1,w[22:16]};

   mul mul0i
     (
      .clk(clk),
      .req_command(req_command),
      .en(en0),
      .req_in_1(req_in_1),
      .req_in_2(req_in_2),
      .out(mul),
      .mul(mul_if)
      );

   logic signed [9:0]  exp0l, exp1l, exp2l, exp3l;
   logic [48:0]        aln0, aln1, aln2, aln3;
   logic [31:0]        add0, add1, add2, add3;

   wire sftout0 = ((exp0l==0) | (aln0[48:30]!={19{1'b0}}) & (aln0[48:30]!={19{1'b1}}));
   wire sftout1 = ((exp1l==0) | (aln1[48:30]!={19{1'b0}}) & (aln1[48:30]!={19{1'b1}}));
   wire sftout2 = ((exp2l==0) | (aln2[48:30]!={19{1'b0}}) & (aln2[48:30]!={19{1'b1}}));
   wire sftout3 = ((exp3l==0) | (aln3[48:30]!={19{1'b0}}) & (aln3[48:30]!={19{1'b1}}));

   wire signed [9:0] exp0p = {1'b0,x[30:23]} + {1'b0,x[14:7]};
   wire signed [9:0] exp1p = {1'b0,y[30:23]} + {1'b0,y[14:7]};
   wire signed [9:0] exp2p = {1'b0,z[30:23]} + {1'b0,z[14:7]};
   wire signed [9:0] exp3p = {1'b0,w[30:23]} + {1'b0,w[14:7]};

   wire signed [9:0] exp0i = (!sftout0) ? exp0 : exp0l;
   wire signed [9:0] exp1i = (!sftout1) ? exp1 : exp1l;
   wire signed [9:0] exp2i = (!sftout2) ? exp2 : exp2l;
   wire signed [9:0] exp3i = (!sftout3) ? exp3 : exp3l;

   wire signed [9:0] exd0 = exp0p - exp0i + 16;
   wire signed [9:0] exd1 = exp1p - exp1i + 16;
   wire signed [9:0] exd2 = exp2p - exp2i + 16;
   wire signed [9:0] exd3 = exp3p - exp3i + 16;

   wire [5:0]        sft0 = (exd0[9:6]!=0) ? 63 : exd0;
   wire [5:0]        sft1 = (exd1[9:6]!=0) ? 63 : exd1;
   wire [5:0]        sft2 = (exd2[9:6]!=0) ? 63 : exd2;
   wire [5:0]        sft3 = (exd3[9:6]!=0) ? 63 : exd3;

   alnsft alnsft0i
     (
      .clk(clk),
      .reset(reset),
      .req_command(req_command),
      .en0(en0),
      .en1({(en1&!sftout0),(en1&!sftout1),(en1&!sftout2),(en1&!sftout3)}),
      .acc0({{16{add0[31]}},add0}),
      .acc1({{16{add1[31]}},add1}),
      .acc2({{16{add2[31]}},add2}),
      .acc3({{16{add3[31]}},add3}),
      .sft0(sft0),  .sft1(sft1),  .sft2(sft2),  .sft3(sft3),
      .acc0o(acc0), .acc1o(acc1), .acc2o(acc2), .acc3o(acc3),
      .aln0(aln0),  .aln1(aln1),  .aln2(aln2),  .aln3(aln3),
      .asft(alnsft_if)
      );

   logic [3:0]       mulctl;

   always_ff @(posedge clk) begin
      if(en0)begin
         if((x[30:23]==0)|(x[14:7]==0)|(exd0<0))  exp0l <= 0;
         else                                     exp0l <= exp0p;
         if((y[30:23]==0)|(y[14:7]==0)|(exd1<0))  exp1l <= 0;
         else                                     exp1l <= exp1p;
         if((z[30:23]==0)|(z[14:7]==0)|(exd2<0))  exp2l <= 0;
         else                                     exp2l <= exp2p;
         if((w[30:23]==0)|(w[14:7]==0)|(exd3<0))  exp3l <= 0;
         else                                     exp3l <= exp3p;

         mulctl <= {x[31]^x[15], y[31]^y[15], z[31]^z[15], w[31]^w[15]};
      end

      if(reset)begin
         exp0 <= 0;  exp1 <= 0;  exp2 <= 0;  exp3 <= 0;
      end else if(en1)begin
         if(!sftout0)begin
            exp0 <= exp0l;
         end
         if(!sftout1)begin
            exp1 <= exp1l;
         end
         if(!sftout2)begin
            exp2 <= exp2l;
         end
         if(!sftout3)begin
            exp3 <= exp3l;
         end
      end
   end

   add add0i
     (
      .clk(clk),
      .en(1'b0),
      .cout(),
      .out(),
      .out0(add0),
      .out1(add1),
      .out2(add2),
      .out3(add3),
      .sub(mulctl[3:0]),
      .cin(2'b0),
      .req_in_0(mul),
      .req_in_1(0),
      .req_in_2(0),
      .aln0(aln0),
      .aln1(aln1),
      .aln2(aln2),
      .aln3(aln3),
      .add(add_if)
   );

endmodule
