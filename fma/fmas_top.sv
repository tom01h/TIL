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
   logic [31:0] aln0;
   logic [31:0] aln1;
   logic [31:0] aln2;
   logic [31:0] aln3;
} addit;

typedef struct packed {
   logic [65:64] cout;
   logic [81:0] addo;
} addot;

module fma
  (
   input logic         clk,
   input logic         reset,
   input logic         req,
   input integer       req_command,
   input logic [31:0]  x,
   input logic [31:0]  y,
   input logic [31:0]  z,
   output logic [31:0] rslt,
   output logic [4:0]  flag
   );

   mulit muli0;
   mulot mulo0;
   addit addi1;
   addot addo1;

   fmas fmas
     (
      .clk(clk),
      .reset(reset),
      .req(req),
      .req_command(req_command),
      .x(x[31:0]),
      .y(y[31:0]),
      .z(z[31:0]),
      .rslt(rslt[31:0]),
      .flag(flag[4:0]),
      .muli0(muli0),
      .mulo0(mulo0),
      .addi1(addi1),
      .addo1(addo1)
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
   output logic [65:64] cout,
   output logic [81:0]  out,
   input logic          sub,
   input logic [1:0]    cin,
   input logic [79:0]   req_in_0,
   input logic [79:0]   req_in_1,
   input logic [79:0]   req_in_2,
   input logic [31:0]   aln0,
   input logic [31:0]   aln1,
   input logic [31:0]   aln2,
   input logic [31:0]   aln3,
   output               addit addi,
   input                addot addo
   );

   add0 add0
     (
      .clk(clk),
      .en(en),
      .cout(cout[65:64]),
      .out(out[81:0]),
      .sub(sub),
      .cin(cin[1:0]),
      .req_in_0(req_in_0[79:0]),
      .req_in_1(req_in_1[79:0]),
      .req_in_2(req_in_2[79:0]),
      .aln0(aln0[31:0]),
      .aln1(aln1[31:0]),
      .aln2(aln2[31:0]),
      .aln3(aln3[31:0])
   );

endmodule
