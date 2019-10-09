typedef struct packed {
   logic       en;
   logic [26:0] req_in_1;
   logic [26:0] req_in_2;
} mulit;

typedef struct packed {
   logic [53:0] out;
} mulot;

typedef struct packed {
   logic       en;
   logic       sub;
   logic [109:0] req_in_1;
   logic [172:0] req_in_2;
} addit;

typedef struct packed {
   logic [169:0] out;
   logic [2:0]   outg;
} addot;

module fma
  (
   input logic         clk,
   input logic         reset,
   input logic         req,
   input integer       req_command,
   input logic [63:0]  x,
   input logic [63:0]  y,
   input logic [63:0]  z,
   output logic [63:0] rslt,
   output logic [4:0]  flag
   );

   mulit muli00,muli01;
   mulot mulo00,mulo01;
   mulit muli10,muli11;
   mulot mulo10,mulo11;
   addit addi1;
   addot addo1;
   addit addi2;
   addot addo2;

   fmad fmad
     (
      .clk(clk),
      .reset(reset),
      .req(req),
      .req_command(req_command),
      .x(x[63:0]),
      .y(y[63:0]),
      .z(z[63:0]),
      .rslt(rslt[63:0]),
      .flag(flag[4:0]),
      .muli00(muli00),
      .mulo00(mulo00),
      .muli01(muli01),
      .mulo01(mulo01),
      .muli10(muli10),
      .mulo10(mulo10),
      .muli11(muli11),
      .mulo11(mulo11),
      .addi1(addi1),
      .addo1(addo1),
      .addi2(addi2),
      .addo2(addo2)
      );

endmodule

module mul
  (
   input logic         clk,
   input logic         en,
   output logic [53:0] out,
   input logic [26:0]  req_in_1,
   input logic [26:0]  req_in_2,
   output              mulit muli,
   input               mulot mulo
   );

   mul0 mul0
     (
      .clk(clk),
      .en(en),
      .out(out[53:0]),
      .req_in_1(req_in_1[26:0]),
      .req_in_2(req_in_2[26:0])
   );

endmodule

module add
  (
   input logic          clk,
   input logic          en,
   output logic [169:0] out,
   output logic [2:0]   outg,
   input logic          sub,
   input logic [109:0]  req_in_1,
   input logic [172:0]  req_in_2,
   output               addit addi,
   input                addot addo
   );

   add0 add0
     (
      .clk(clk),
      .en(en),
      .out(out[169:0]),
      .outg(outg[2:0]),
      .sub(sub),
      .req_in_1(req_in_1[109:0]),
      .req_in_2(req_in_2[172:0])
   );

endmodule
