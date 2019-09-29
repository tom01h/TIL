module lza
  (
   input wire                clk,
   input wire                reset,
   input wire signed [7:0]   a,
   input wire signed [7:0]   b,
   output wire signed [15:0] fr,
   output wire [3:0]         ex
   );

   wire [9:0]                p = {{2{  a[7]^b[7]}},    a^b};
   wire [9:0]                g = {{2{  a[7]&b[7]}},    a&b};
   wire [9:0]                e = {{2{~(a[7]|b[7])}}, ~(a|b)};

   wire signed [8:0]         s = a+b;
   wire [8:0]                c = p ^ s;

   wire [3:0]                ext;

   wire [7:0]                o  = ~p[8:1] & ((p[9:2]^g[8:1]^g[7:0]) | (p[9:2]^e[8:1]^e[7:0]));
   wire                      on = ~p[0]   & ((p[1]  ^g[0]  ^1'b0)   | (p[1]  ^e[0]  ^1'b1  ));

   wire [8:1]                o3 = (ext[3]) ? {o[0],on,6'h3f} :  o[8:1];
   wire [8:5]                o2 = (ext[2]) ? o3[4:1]         : o3[8:5];
   wire [8:7]                o1 = (ext[1]) ? o2[6:5]         : o2[8:7];

   wire [8:1]                c3 = (ext[3]) ? {c[0],7'h00}    :  c[8:1];
   wire [8:5]                c2 = (ext[2]) ? c3[4:1]         : c3[8:5];
   wire [8:7]                c1 = (ext[1]) ? c2[6:5]         : c2[8:7];
   wire                      c0 = (ext[0]) ? c1[7]           : c1[8];

   assign                    ext = {( o[7:0]==0), (o3[7:4]==0), (o2[7:6]==0), (o1[7]==0)};
   assign                    ex  = ext + {1'b0,~(c0^s[8])} -1;

   wire [9:0]                s3 = (ext[3]) ? { s[1:0],8'h0}  : {s[8],s[8:0]};
   wire [9:0]                s2 = (ext[2]) ? {s3[7:0],4'h0}  : s3[9:0];
   wire [9:0]                s1 = (ext[1]) ? {s2[7:0],2'h0}  : s2[9:0];
   wire [9:0]                s0 = (ext[0]) ? {s1[8:0],1'b0}  : s1[9:0];

   assign fr[8:0] = (c0^s[8]) ? s0[9:1] : s0[8:0];
   assign fr[15:9] = {7{s[8]}};

   always @(posedge clk)
     if((fr[8]==fr[7])&(fr!=0)) $display("err");

endmodule
