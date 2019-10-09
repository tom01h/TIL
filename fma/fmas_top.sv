typedef struct packed {
   logic       en;
   integer     req_command;
   logic [26:0] req_in_1;
   logic [26:0] req_in_2;
} mulit;

typedef struct packed {
   logic [53:0] out;
} mulot;

typedef struct packed {
   logic       en;
   integer     req_command;
   logic [63:0] mul;
   logic [4:0]  mulctl;
   logic [31:0] aln0;
   logic [31:0] aln1;
   logic [31:0] aln2;
   logic [31:0] aln3;
} addit;

typedef struct packed {
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
   input integer       req_command,
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
      .req_command(req_command),
      .out(out[53:0]),
      .req_in_1(req_in_1[26:0]),
      .req_in_2(req_in_2[26:0])
   );

endmodule

module add
  (
   input logic         clk,
   input logic         en,
   input integer       req_command,
   input logic [63:0]  mul,
   input logic [4:0]   mulctl,
   input logic [31:0]  aln0,
   input logic [31:0]  aln1,
   input logic [31:0]  aln2,
   input logic [31:0]  aln3,
   output logic [81:0] out,
   output              addit addi,
   input               addot addo
   );

   add0 add1i
     (
      .clk(clk),
      .en(en),
      .req_command(req_command),
      .mul(mul),
      .mulctl(mulctl),
      .aln0(aln0),      .aln1(aln1),      .aln2(aln2),      .aln3(aln3),
      .out(out)
   );

endmodule
