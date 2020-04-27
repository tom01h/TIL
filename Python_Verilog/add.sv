module cla
  (
   input wire         clk,
   input wire         reset,
   input wire [31:0]  a,
   input wire [31:0]  b,
   output reg [31:0] s
   );

   always_ff @(posedge clk) begin
      s <= a+b;
   end

endmodule
