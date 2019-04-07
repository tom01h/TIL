module top
  (
   input wire         clk,
   input wire         rst,
   input wire         start,
   output wire        last,
   output wire [31:0] wa,
   output wire [31:0] ia
   );

   wire [3:0]         x, y, c;
   wire               next_x, next_y, next_c;
   wire               last_x, last_y, last_c;

   assign last = last_c;

   loop1 #(.W(4)) l_c(.ini(4'd0), .fin(4'd2), .data(c[3:0]), .start(start),  .last(last_c),
                      .clk(clk),  .rst(rst),                  .next(next_c),   .en(last_y) );

   loop1 #(.W(4)) l_y(.ini(4'd0), .fin(4'd2), .data(y[3:0]), .start(next_c), .last(last_y),
                      .clk(clk),  .rst(rst),                  .next(next_y),   .en(last_x) );

   loop1 #(.W(4)) l_x(.ini(4'd0), .fin(4'd2), .data(x[3:0]), .start(next_y), .last(last_x),
                      .clk(clk),  .rst(rst),                  .next(next_x),   .en(1'b1) );

   assign wa = c*9+y*3+x;
   assign ia = c*100+y*10+x;

endmodule

module loop1
  #(
    parameter W = 32
    )
   (
    input wire [W-1:0] ini,
    input wire [W-1:0] fin,
    output reg [W-1:0] data,
    input wire         clk,
    input wire         rst,
    input wire         start,
    input wire         en,
    output wire        next,
    output wire        last
    );

   reg                 next0;
   reg                 run;
   assign next = start | next0;
   assign last = (data==fin)&(run|start)&en;

   always @(posedge clk)begin
      next0 <= (run|start)&en&!last;
      if(rst)begin
         run <= 1'b0;
         data <= ini;
      end if (start|run)begin
         if(last)begin
            if(en)begin
               data <= ini;
               run <= 1'b0;
            end
         end else begin
            run <= 1'b1;
            if(en)begin
               data <= data+1;
            end
         end
      end
   end
endmodule
