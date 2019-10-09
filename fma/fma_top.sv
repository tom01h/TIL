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
   mulit mulis0,mulis1;
   mulot mulos0,mulos1;

   always_comb begin
      if(muli00.en)begin
         mulis0 = muli00;
         mulis1 = muli01;
      end else begin
         mulis0 = muli10;
         mulis1 = muli11;
      end
      mulo00 = mulos0;
      mulo01 = mulos1;
      mulo10 = mulos0;
      mulo11 = mulos1;
   end

   mul0 mul0
     (
      .clk(clk),
      .en(mulis0.en),
      .out(mulos0.out[53:0]),
      .req_in_1(mulis0.req_in_1[26:0]),
      .req_in_2(mulis0.req_in_2[26:0])
   );

   mul0 mul1
     (
      .clk(clk),
      .en(mulis1.en),
      .out(mulos1.out[53:0]),
      .req_in_1(mulis1.req_in_1[26:0]),
      .req_in_2(mulis1.req_in_2[26:0])
   );

   addit addi1;
   addot addo1;
   addit addi2;
   addot addo2;
   addit addis;
   addot addos;

   always_comb begin
      if(addi1.en)begin
         addis = addi1;
      end else begin
         addis = addi2;
      end
      addo1 = addos;
      addo2 = addos;
   end

   add0 add0
     (
      .clk(clk),
      .en(addis.en),
      .out(addos.out[169:0]),
      .outg(addos.outg[2:0]),
      .sub(addis.sub),
      .req_in_1(addis.req_in_1[109:0]),
      .req_in_2(addis.req_in_2[172:0])
   );

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
   output logic [79:0] out,
   input logic [52:0]  req_in_1,
   input logic [26:0]  req_in_2,
   output              mulit muli,
   input               mulot mulo
   );

   assign muli.en = en;
   assign muli.req_in_1 = req_in_1;
   assign muli.req_in_2 = req_in_2;
   assign out = mulo.out;

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

   assign addi.en = en;
   assign addi.sub = sub;
   assign addi.req_in_1 = req_in_1;
   assign addi.req_in_2 = req_in_2;
   assign out = addo.out;
   assign outg = addo.outg;

endmodule
