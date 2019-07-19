module src_buf
  (
   input wire        clk,
   input wire        src_v,
   input wire [3:0]  src_a,
   input wire [63:0] src_d,
   input wire        exec,
   input wire [4:0]  ia,
   output reg [31:0] d
   );

   reg [63:0]        buff [0:15];
   reg [63:0]        wd;
   reg               ia_;

   assign d = (ia_) ? wd[31:0] : wd[63:32];

   always_ff @(posedge clk)
     ia_ <= ia[0];

   always_ff @(posedge clk)
     if(    src_v) buff[src_a[3:0]] <= src_d;
     else if(exec) wd <= buff[ia[4:1]];

endmodule

module dst_buf
  (
   input wire        clk,
   input wire        dst_v,
   input wire [2:0]  dst_a,
   output reg [63:0] dst_d,
   input wire        outr,
   input wire [3:0]  oa,
   input wire [31:0] result
   );

   reg [31:0]        buff0 [0:7];
   reg [31:0]        buff1 [0:7];

   always_ff @(posedge clk)
     if(outr&~oa[0])
       buff0[oa[3:1]] <= result;
     else if(dst_v)
       dst_d[63:32] <= buff0[dst_a[2:0]];

   always_ff @(posedge clk)
     if(outr& oa[0])
       buff1[oa[3:1]] <= result;
     else if(dst_v)
       dst_d[31:0] <= buff1[dst_a[2:0]];
endmodule

