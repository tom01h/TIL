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
   logic [1:0] cin;
   logic [79:0] req_in_0;
   logic [79:0] req_in_1;
   logic [79:0] req_in_2;
   logic [79:0] req_in_3;
} addit;

typedef struct packed {
   logic [65:64] cout;
   logic [81:0]  out;
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

   addit addi10,addi11;
   addot addo10,addo11;
   addit addi20,addi21;
   addot addo20,addo21;
   addit addis0,addis1;
   addot addos0,addos1;

   always_comb begin
      if(addi10.en)begin
         addis0 = addi10;
         addis1 = addi11;
      end else begin
         addis0 = addi20;
         addis1 = addi21;
      end
      addo10 = addos0;
      addo11 = addos1;
      addo20 = addos0;
      addo21 = addos1;
   end

   add0 add0
     (
      .clk(clk),
      .en(addis0.en),
      .cout(addos0.cout[65:64]),
      .out(addos0.out[81:0]),
      .sub(addis0.sub),
      .cin(addis0.cin[1:0]),
      .req_in_0(addis0.req_in_0[79:0]),
      .req_in_1(addis0.req_in_1[79:0]),
      .req_in_2(addis0.req_in_2[79:0]),
      .req_in_3(addis0.req_in_3[79:0])
   );

   add0 add1
     (
      .clk(clk),
      .en(addis1.en),
      .cout(addos1.cout[65:64]),
      .out(addos1.out[81:0]),
      .sub(addis1.sub),
      .cin(addis1.cin[1:0]),
      .req_in_0(addis1.req_in_0[79:0]),
      .req_in_1(addis1.req_in_1[79:0]),
      .req_in_2(addis1.req_in_2[79:0]),
      .req_in_3(addis1.req_in_3[79:0])
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
      .addi10(addi10),
      .addo10(addo10),
      .addi11(addi11),
      .addo11(addo11),
      .addi20(addi20),
      .addo20(addo20),
      .addi21(addi21),
      .addo21(addo21)
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
   output logic [65:64] cout,
   output logic [81:0]  out,
   input logic          sub,
   input logic [1:0]    cin,
   input logic [79:0]   req_in_0,
   input logic [79:0]   req_in_1,
   input logic [79:0]   req_in_2,
   input logic [79:0]   req_in_3,
   output               addit addi,
   input                addot addo
   );

   assign addi.en = en;
   assign addi.sub = sub;
   assign addi.cin = cin;
   assign addi.req_in_0 = req_in_0;
   assign addi.req_in_1 = req_in_1;
   assign addi.req_in_2 = req_in_2;
   assign addi.req_in_3 = req_in_3;
   assign cout = addo.cout;
   assign out = addo.out;

endmodule
