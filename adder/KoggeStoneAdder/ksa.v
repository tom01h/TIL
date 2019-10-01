module ksa
  (
   input wire         clk,
   input wire         reset,
   input wire [31:0]  a,
   input wire [31:0]  b,
   output wire [31:0] s
   );

   wire [31:0]        g0 = a&b;
   wire [31:0]        p0 = a^b;

   wire [31:0]        g1 = g0 | p0&{g0[30:0],1'b0};
   wire [31:0]        p1 =      p0&{p0[30:0],1'b1};

   wire [31:0]        g2 = g1 | p1&{g1[29:0],2'b0};
   wire [31:0]        p2 =      p1&{p1[29:0],2'h3};

   wire [31:0]        g4 = g2 | p2&{g2[27:0],4'b0};
   wire [31:0]        p4 =      p2&{p2[27:0],4'hf};

   wire [31:0]        g8 = g4 | p4&{g4[23:0],8'b0};
   wire [31:0]        p8 =      p4&{p4[23:0],8'hff};

   wire [31:0]        g16= g8 | p8&{g8[15:0],16'b0};
   wire [31:0]        p16=      p8&{p8[15:0],16'hffff};


   wire               cin = 1'b0;

   wire [31:0]        c = g16  | p16[31:0] & {32{cin}};
   assign             s = p0^{c[30:0],cin};

endmodule
