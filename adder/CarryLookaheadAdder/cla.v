module cla
  (
   input wire         clk,
   input wire         reset,
   input wire [31:0]  a,
   input wire [31:0]  b,
   output wire [31:0] s
   );

   wire [31:0]        g = a&b;
   wire [31:0]        p = a^b;

   wire [31:0]        c = g|p&{c[30:0],1'b0};
   assign             s = p^{c[30:0],1'b0};

endmodule
