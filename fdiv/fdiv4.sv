module fdiv_check
  (
   input logic [31:0]  x,
   input logic [31:0]  y,
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

   localparam last = 14;
   localparam fin  = 15;

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
      .rslt(rslt0i),
      .flag(flag0i)
   );

   wire [23:0]       fracx = {1'b1,x[22:0]};
   wire [23:0]       fracy = {1'b1,y[22:0]};

   wire [7:0]        expx = x[30:23];
   wire [7:0]        expy = y[30:23];
   wire signed [9:0] expd = expx-expy+127;
   wire signed       sgnd = x[31]^y[31];

   logic [26:0]      p;
   logic [27:0]      qp, qn;

   always_ff @(posedge clk)begin
      if(cnt==0)begin
         if(req==1'b1)begin
            p  <= {1'b0,fracx};
            qp <= 26'h0;
            qn <= 26'h0;
         end
      end else if(cnt==fin)begin
         if(p[26]==1'b1)begin
            p <= p + {fracy,2'b0};
            qp <= qp-qn-1;
            qn <= 0;
         end else begin
            p <= p;
            qp <= qp-qn;
            qn <= 0;
         end
      end else begin
         casez(qi(p[26], {5{p[26]}}^p[25:21], fracy[23:20]))
           3'b000,
           3'b100: begin
              p <= {p,2'b00};
              qp <= {qp,2'b00};
              qn <= {qn,2'b00};
           end
           3'b001: begin
              p <= {p,2'b00} - {1'b0,fracy,2'b0};
              qp <= {qp,2'b01};
              qn <= {qn,2'b00};
           end
           3'b010: begin
              p <= {p,2'b00} - {fracy,3'b0};
              qp <= {qp,2'b10};
              qn <= {qn,2'b00};
           end
           3'b101: begin
              p <= {p,2'b00} + {1'b0,fracy,2'b0};
              qp <= {qp,2'b00};
              qn <= {qn,2'b01};
           end
           3'b110: begin
              p <= {p,2'b00} + {fracy,3'b0};
              qp <= {qp,2'b00};
              qn <= {qn,2'b10};
           end
         endcase
      end
   end

   wire [27:0]       q  = qp-qn;
   wire [25:0]       quot  = {fracx,25'h0} / fracy;
   wire [25:0]       remt  = {fracx,25'h0} % fracy;

   wire [27:0]       quo  = qp;
   wire [26:0]       rem  = p;

   logic             rnd;

   logic [32:0]      rslti;
   logic             inexact;
   always_comb begin   
      if(quo[27]==1'b1)begin
         rnd = quo[3] & ( ({quo[2:0],rem}!=0) | quo[4]);
         rslti   = {expd+1, quo[26:4]} + rnd;
         inexact = ({quo[1:0],rem}!=0);
      end else if(quo[26]==1'b1)begin
         rnd = quo[2] & ( ({quo[1:0],rem}!=0) | quo[3]);
         rslti   = {expd  , quo[25:3]} + rnd;
         inexact = ({quo[0],rem}!=0);
      end else begin
         rnd = quo[1] & ( ({quo[0],rem}!=0) | quo[2]);
         rslti   = {expd-1, quo[24:2]} + rnd;
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

   function [2:0] qi;
      input logic ps;
      input logic [4:0] pp;
      input logic [3:0] b;

      qi[2] = ps;

      casez(b[2:0])
        3'd0:begin
           if(pp<=6'd1)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd5)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd11)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
        3'd1:begin
           if(pp<=6'd2)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd6)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd13)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
        3'd2:begin
           if(pp<=6'd2)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd7)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd14)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
        3'd3:begin
           if(pp<=6'd2)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd8)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd15)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
        3'd4:begin
           if(pp<=6'd3)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd9)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd17)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
        3'd5:begin
           if(pp<=6'd3)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd9)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd18)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
        3'd6:begin
           if(pp<=6'd3)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd10)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd19)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
        3'd7:begin
           if(pp<=6'd4)begin
              qi[1:0] = 2'b00;
           end else if(pp<=6'd11)begin
              qi[1:0] = 2'b01;
           end else if(pp<=6'd21)begin
              qi[1:0] = 2'b10;
           end else begin
              $display("ERR %d, %d",pp,b);
              $finish;
           end
        end
      endcase
   endfunction

endmodule
