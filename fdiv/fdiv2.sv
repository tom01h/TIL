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

   always_comb begin
      if(quo[25]==1'b1)begin
         rnd = quo[1] & ( ({quo[0],rem}!=0) | quo[2]);
         rslt[31]   = sgnd;
         rslt[30:0] = {expd,  quo[24:2]} + rnd;
         flag[0]    = ({quo[1:0],rem}!=0);
      end else begin
         rnd = quo[0] & ( ({rem}!=0) | quo[1]);
         rslt[31]   = sgnd;
         rslt[30:0] = {expd-1,quo[23:1]} + rnd;
         flag[0]    = ({quo[0],rem}!=0);
      end
   end

endmodule
