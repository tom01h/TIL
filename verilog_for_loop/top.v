module top
  (
   input wire         clk,
   input wire         rst,
   input wire         start,
   output wire        last,
   output wire [31:0] wa,
   output wire [31:0] ia
   );

   wire [3:0]        x, y, c;
   wire              next_x, next_y, next_c;
   wire              last_x, last_y, last_c;

   assign last = last_c;

   loop l_c(.fin(4'd2), .data(c[3:0]), .clk(clk), .rst(rst), .start(start),  .en(last_y), .next(next_c), .last(last_c));
   loop l_y(.fin(4'd2), .data(y[3:0]), .clk(clk), .rst(rst), .start(next_c), .en(last_x), .next(next_y), .last(last_y));
   loop l_x(.fin(4'd2), .data(x[3:0]), .clk(clk), .rst(rst), .start(next_y), .en(1'b1),   .next(next_x), .last(last_x));

   assign wa = c*9+y*3+x;
   assign ia = c*100+y*10+x;

endmodule

module loop
  (
   input wire [3:0] fin,
   output reg [3:0] data,
   input wire       clk,
   input wire       rst,
   input wire       start,
   input wire       en,
   output wire      next,
   output wire      last
   );

   reg              next0;
   reg              run;
   assign next = start | next0;
   assign last = (data==fin)&run&en;

   always @(posedge clk)begin
      next0 <= (run|start)&en&!last;
      if(rst)begin
         run <= 1'b0;
         data <= 4'd0;
      end if (start)begin
         run <= 1'b1;
         if(en)begin
            data <= data+1;
         end
      end else if (!en)begin
      end else if (run)begin
         if (last)begin
            data <= 4'd0;
            run <= 1'b0;
         end else begin
            data <= data+1;
         end
      end
   end

endmodule
