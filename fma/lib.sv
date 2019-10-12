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
