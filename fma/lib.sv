module mul0
  (
   input logic         clk,
   input integer       req_command,
   input logic         en,
   output logic [63:0] out,
   input logic [31:0]  req_in_1,
   input logic [31:0]  req_in_2
   );

   always_ff @(posedge clk)begin
      if(en)begin
         casez(req_command)
           0,
           1:begin
              out[63:54] <= 'h0;
              out[53:0] <= req_in_1[26:0] * req_in_2[26:0];
           end
           2:begin
              out[63:48] <= req_in_1[31:24] * req_in_2[31:24];
              out[47:32] <= req_in_1[23:16] * req_in_2[23:16];
              out[31:16] <= req_in_1[15: 8] * req_in_2[15: 8];
              out[15: 0] <= req_in_1[ 7: 0] * req_in_2[ 7: 0];
           end
         endcase
      end
   end
endmodule

module add0
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
   input logic [31:0]   aln3
   );

   assign out0 = (sub[3]) ? (aln0 - req_in_0[63:48]) : (aln0 + req_in_0[63:48]);
   assign out1 = (sub[2]) ? (aln1 - req_in_0[47:32]) : (aln1 + req_in_0[47:32]);
   assign out2 = (sub[1]) ? (aln2 - req_in_0[31:16]) : (aln2 + req_in_0[31:16]);
   assign out3 = (sub[0]) ? (aln3 - req_in_0[15: 0]) : (aln3 + req_in_0[15: 0]);

   logic [81:64]       sumh;
   logic [65:0]        suml;

   wire [79:0]         req_in_3 = {aln0, aln1[15:0], aln2[15:0], aln3[15:0]};

   assign cout = suml[65:64];

   always_comb begin
      if(sub[0])begin
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

module alnsft0
  (
   input logic         clk,
   input logic         reset,
   input integer       req_command,
   input logic         en0,
   input logic [3:0]   en1,
   input logic [47:0]  acc0, acc1, acc2, acc3,
   input logic [5:0]   sft0, sft1, sft2, sft3,
   output logic [47:0] acc0o, acc1o, acc2o, acc3o,
   output logic [48:0] aln0, aln1, aln2, aln3
   );

   wire [3:0]          eni = (req_command==2) ? en1 : {4{en0}};

   logic [5:0]         sft00, sft01, sft02, sft03;

   always_ff @(posedge clk) begin
      if(en0)begin
         sft00 <= sft0;
         sft01 <= sft1;
         sft02 <= sft2;
         sft03 <= sft3;
      end
      if(reset)begin
         acc0o <= 0;
         acc1o <= 0;
         acc2o <= 0;
         acc3o <= 0;
      end else begin
         if(eni[3])begin
            acc0o <= acc0;
         end
         if(eni[2])begin
            acc1o <= acc1;
         end
         if(eni[1])begin
            acc2o <= acc2;
         end
         if(eni[0])begin
            acc3o <= acc3;
         end
      end
   end
   always_comb begin
      casez(req_command)
        0,
        1:begin
           aln0 = {acc0o,16'h0}>>sft00;
           aln1 = {acc1o,16'h0}>>sft01;
           aln2 = {acc2o,16'h0}>>sft02;
           aln3 = {acc3o,16'h0}>>sft03;
        end
        2:begin
           aln0 = $signed({acc0o,16'h0})>>>sft00;
           aln1 = $signed({acc1o,16'h0})>>>sft01;
           aln2 = $signed({acc2o,16'h0})>>>sft02;
           aln3 = $signed({acc3o,16'h0})>>>sft03;
        end
      endcase
   end
endmodule
