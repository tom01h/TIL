module fmab
  (
   input               clk,
   input               reset,
   input               req,
   input integer       req_command,
   input [31:0]        x,
   input [31:0]        y,
   input [31:0]        z,
   input [31:0]        w,
   output logic [31:0] acc0, acc1, acc2, acc3,
   output logic [ 9:0] exp0, exp1, exp2, exp3
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

   logic [63:0]        muli;
   wire [31:0]         req_in_1 = {1'b1,x[6:0],  1'b1,y[6:0],  1'b1,z[6:0],  1'b1,w[6:0]};
   wire [31:0]         req_in_2 = {1'b1,x[22:16],1'b1,y[22:16],1'b1,z[22:16],1'b1,w[22:16]};

   assign muli[63:48] = req_in_1[31:24] * req_in_2[31:24];
   assign muli[47:32] = req_in_1[23:16] * req_in_2[23:16];
   assign muli[31:16] = req_in_1[15: 8] * req_in_2[15: 8];
   assign muli[15: 0] = req_in_1[ 7: 0] * req_in_2[ 7: 0];

   logic [5:0]         sft0, sft1, sft2, sft3;
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

   logic [63:0]      mul;
   logic [4:0]       mulctl;

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

         mul <= muli;

         mulctl <= {1'b1,x[31]^x[15], y[31]^y[15], z[31]^z[15], w[31]^w[15]};

         if(exd0[9:6]!=0) sft0 <= 63;
         else             sft0 <= exd0;
         if(exd1[9:6]!=0) sft1 <= 63;
         else             sft1 <= exd1;
         if(exd2[9:6]!=0) sft2 <= 63;
         else             sft2 <= exd2;
         if(exd3[9:6]!=0) sft3 <= 63;
         else             sft3 <= exd3;
      end

      if(reset)begin
         exp0 <= 0;  exp1 <= 0;  exp2 <= 0;  exp3 <= 0;
         acc0 <= 0;  acc1 <= 0;  acc2 <= 0;  acc3 <= 0;
      end else if(en1)begin
         if(!sftout0)begin
            exp0 <= exp0l;
            acc0 <= add0;
         end
         if(!sftout1)begin
            exp1 <= exp1l;
            acc1 <= add1;
         end
         if(!sftout2)begin
            exp2 <= exp2l;
            acc2 <= add2;
         end
         if(!sftout3)begin
            exp3 <= exp3l;
            acc3 <= add3;
         end
      end
   end

   always_comb begin
      aln0 = $signed({acc0,16'h0})>>>sft0;
      aln1 = $signed({acc1,16'h0})>>>sft1;
      aln2 = $signed({acc2,16'h0})>>>sft2;
      aln3 = $signed({acc3,16'h0})>>>sft3;
   end

   assign add0 = (mulctl[3]) ? (aln0 - mul[63:48]) : (aln0 + mul[63:48]);
   assign add1 = (mulctl[2]) ? (aln1 - mul[47:32]) : (aln1 + mul[47:32]);
   assign add2 = (mulctl[1]) ? (aln2 - mul[31:16]) : (aln2 + mul[31:16]);
   assign add3 = (mulctl[0]) ? (aln3 - mul[15: 0]) : (aln3 + mul[15: 0]);

endmodule
