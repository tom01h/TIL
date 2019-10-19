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
   output logic [81:0]  out,
   input logic          sub,
   input logic [1:0]    cin,
   input logic [79:0]   req_in_0,
   input logic [79:0]   req_in_1,
   input logic [79:0]   req_in_2,
   input logic [31:0]   aln0,
   input logic [31:0]   aln1,
   input logic [31:0]   aln2,
   input logic [31:0]   aln3
   );

   logic [81:64]       sumh;
   logic [65:0]        suml;

   wire [79:0]         req_in_3 = {aln0, aln1[15:0], aln2[15:0], aln3[15:0]};

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

module alnsft0
  (
   input logic         clk,
   input logic         en,
   input logic [47:0]  acc0, acc1, acc2, acc3,
   input logic [5:0]   sft0, sft1, sft2, sft3,
   output logic [48:0] aln0, aln1, aln2, aln3
   );

   logic [47:0]        acc00, acc01, acc02, acc03;
   logic [5:0]         sft00, sft01, sft02, sft03;

   always_ff @(posedge clk) begin
      if(en)begin
         acc00 <= acc0;    acc01 <= acc1;    acc02 <= acc2;    acc03 <= acc3;
         sft00 <= sft0;    sft01 <= sft1;    sft02 <= sft2;    sft03 <= sft3;
      end
   end
   always_comb begin
      aln0 = {acc00,16'h0}>>sft00;
      aln1 = {acc01,16'h0}>>sft01;
      aln2 = {acc02,16'h0}>>sft02;
      aln3 = {acc03,16'h0}>>sft03;
   end
endmodule
