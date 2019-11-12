module fdiv_check
  (
   input logic [31:0]  x,
   input logic [31:0]  y,
   input logic [31:0]  z,
   output logic [31:0] rslt,
   output logic [4:0]  flag
   );
   always_comb begin
      rslt = {32{1'bx}};
      rslt[31] = x[31]^y[31];
      flag = 5'h0;
      if((x[30:23]==8'hff)&(x[22:0]!=0))begin
         rslt[31:0] = x|32'h00400000;
         flag[4]    = ~x[22]|(y[30:23]==8'hff)&(y[22:0]!=0)&~y[22];
      end else if((y[30:23]==8'hff)&(y[22:0]!=0))begin
         rslt[31:0] = y|32'h00400000;
         flag[4]    = ~y[22];
      end else if(((x[30:23]==8'hff)&(x[22:0]==0)) && ((y[30:23]==8'hff)&(y[22:0]==0)))begin
         rslt[31:0] = 32'hffc00000;
         flag[4]    = 1'b1;
      end else if((x[30:23]==8'hff)&(x[22:0]==0))begin
         rslt[30:0] = 31'h7f800000;
      end else if((y[30:23]==8'hff)&(y[22:0]==0))begin
         rslt[30:0] = 31'h00000000;
      end else if(((x[30:23]==8'h00)&(x[22:0]==0)) && ((y[30:23]==8'h00)&(y[22:0]==0)))begin
         rslt[31:0] = 32'hffc00000;
         flag[4]    = 1'b1;
      end else if((x[30:23]==8'h00)&(x[22:0]==0))begin
         rslt[30:0] = 31'h00000000;
      end else if((y[30:23]==8'h00)&(y[22:0]==0))begin
         rslt[30:0] = 31'h7f800000;
         flag[3]    = 1'b1;
      end else begin
         flag[0]    = 1'b1;
      end
   end
endmodule

module fdiv
  (
   input logic         clk,
   input logic         reset,
   input logic         req,
   input logic [31:0]  x,
   input logic [31:0]  y,
   output logic [31:0] rslt,
   output logic [4:0]  flag
   );

   localparam last = 26;
   localparam fin  = 27;

   integer             cnt;

   always_ff @(posedge clk)begin
      if(reset)begin
         cnt <= 0;
      end else if(cnt==0)begin
         if(req==1'b1)begin
            cnt <= 1;
         end
      end else if(cnt==fin)begin
         cnt <= 0;
      end else begin
         cnt <= cnt + 1;
      end
   end

   logic [4:0]       flag0i;
   logic [31:0]      rslt0i;

   fdiv_check fdiv_check
     (
      .x(x),
      .y(y),
      .z(z),
      .rslt(rslt0i),
      .flag(flag0i)
   );

   wire [23:0]       fracx = {1'b1,x[22:0]};
   wire [23:0]       fracy = {1'b1,y[22:0]};

   wire [7:0]        expx = x[30:23];
   wire [7:0]        expy = y[30:23];
   wire signed [9:0] expd = expx-expy+127;
   wire signed       sgnd = x[31]^y[31];

   logic [25:0]      p;
   logic [25:0]      qp, qn;

   always_ff @(posedge clk)begin
      if(cnt==0)begin
         if(req==1'b1)begin
            p  <= {1'b0,fracx};
            qp <= 26'h0;
            qn <= 26'h0;
         end
      end else if(cnt==fin)begin
         if(p[24]==1'b1)begin
            p <= p + {fracy,1'b0};
            qp <= qp-qn-1;
            qn <= 0;
         end else begin
            p <= p;
            qp <= qp-qn;
            qn <= 0;
         end
      end else begin
         if((p[25:23] == 3'b000) || (p[25:23] == 3'b111))begin
            p <= {p,1'b0};
            qp <= {qp,1'b0};
            qn <= {qn,1'b0};
         end else if(p[25]==1'b0)begin
            p <= {p,1'b0} - {fracy,1'b0};
            qp <= {qp,1'b1};
            qn <= {qn,1'b0};
         end else if(p[25]==1'b1)begin
            p <= {p,1'b0} + {fracy,1'b0};
            qp <= {qp,1'b0};
            qn <= {qn,1'b1};
         end
      end
   end

//   wire [25:0]       q  = qp-qn;
   wire [25:0]       quot  = {fracx,25'h0} / fracy;
   wire [25:0]       remt  = {fracx,25'h0} % fracy;

   wire [25:0]       quo  = qp;
   wire [25:0]       rem  = p;

   logic             rnd;

   logic [32:0]      rslti;
   logic             inexact;
   always_comb begin   
      if(quo[25]==1'b1)begin
         rnd = quo[1] & ( ({quo[0],rem}!=0) | quo[2]);
         rslti   = {expd,  quo[24:2]} + rnd;
         inexact = ({quo[1:0],rem}!=0);
      end else begin
         rnd = quo[0] & ( ({rem}!=0) | quo[1]);
         rslti   = {expd-1,quo[23:1]} + rnd;
         inexact = ({quo[0],rem}!=0);
      end
   end

   always_comb begin
      flag = 0;
      if(flag0i[0] == 1'b0)begin
         rslt = rslt0i[31:0];
         flag = flag0i;
      end else if(rslti[32])begin
         rslt[31]   = sgnd;
         rslt[30:0] = 31'h00000000;
         flag[1]    = 1'b1;
         flag[0]    = 1'b1;
      end else if((rslti[31]) || (rslti[30:23]==8'hff))begin
         rslt[31]   = sgnd;
         rslt[30:0] = 31'h7f800000;
         flag[2]    = 1'b1;
         flag[0]    = 1'b1;
      end else begin
         rslt[31]   = sgnd;
         rslt[30:0] = rslti[30:0];
         flag[0]    = inexact;
      end
   end

endmodule
