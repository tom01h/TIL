#include "unistd.h"
#include "getopt.h"
#include "Vfma.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define VCD_PATH_LENGTH 256

typedef union {
  float f;
  unsigned int i;
} fr;


void check(int acc, int exp, fr expect, fr x, fr y, fr z)
{
  fr result;
  bool fail;
  fr expect2;
  fr x2, y2, z2;

  x2.f = x.f;
  y2.f = y.f;
  z2.f = z.f;

  x2.i &= 0xffff0000;
  y2.i &= 0xffff0000;
  z2.i &= 0xffff0000;

  if((x2.i&0x7f800000)==0){x2.f=0;}
  if((y2.i&0x7f800000)==0){y2.f=0;}
  if((z2.i&0x7f800000)==0){z2.f=0;}

  expect2.f = x2.f * y2.f + z2.f;

  result.f = acc;
  result.f *= pow(2,(exp - 256 - 16 + 4));

  if(isnan(expect.f)){fail=0;}
  else if(isnan(expect2.f)){fail=0;}
  else if(expect2.i==0x7f800000){fail=0;}
  else if(expect2.i==0xff800000){fail=0;}
  else if(abs((result.f-expect2.f)/expect2.f)<(1.0/256)){fail=0;}
  else if((result.f==0)&&(expect2.f<pow(2,-126))){fail=0;}
  else{fail=1;}
  /*
  if(fail){printf("FAILED: ");}
  else    {printf("PASSED: ");}
  printf("%08x * %08x + %08x = %08x\n",x2.i, y2.i, z2.i, expect2.i);
  */
  if(fail){printf("FAILED: ");}
  else    {printf("PASSED: ");}
  printf("%08x * %08x + %08x = %08x ",x.i, y.i, z.i, expect2.i);
  printf("result=%08x error=%f error2=%f\n",result.i, abs((result.f-expect.f)/expect.f), abs((result.f-expect2.f)/expect2.f));
}

VerilatedVcdC* tfp;
Vfma* verilator_top;
vluint64_t main_time;

vluint64_t vcdstart = 0;
vluint64_t vcdend = vcdstart + 300000;

void eval()
{
  verilator_top->clk = 0;
  verilator_top->eval();

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  verilator_top->clk = 1;
  verilator_top->eval();

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  return;
}


int main(int argc, char **argv, char **env) {
  
  fr x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3;
  int flag0, flag1, flag2, flag3;

  fr expect0, expect1, expect2, expect3;

  srand((unsigned)time(NULL));

  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  verilator_top = new Vfma;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");
  main_time = 0;

  verilator_top->req_command = 2;

  while (1) {
    if(scanf("%08x %08x %08x %08x %02x", &x0.i, &y0.i, &z0.i, &expect0.i, &flag0)==EOF){break;}
    if(scanf("%08x %08x %08x %08x %02x", &x1.i, &y1.i, &z1.i, &expect1.i, &flag1)==EOF){break;}
    if(scanf("%08x %08x %08x %08x %02x", &x2.i, &y2.i, &z2.i, &expect2.i, &flag2)==EOF){break;}
    if(scanf("%08x %08x %08x %08x %02x", &x3.i, &y3.i, &z3.i, &expect3.i, &flag3)==EOF){break;}

    verilator_top->x = (z0.i>>16)|0x3f800000;
    verilator_top->y = (z1.i>>16)|0x3f800000;
    verilator_top->z = (z2.i>>16)|0x3f800000;
    verilator_top->w = (z3.i>>16)|0x3f800000;

    verilator_top->reset = 1;
    eval();
    verilator_top->reset = 0;
    verilator_top->req   = 1;
    eval();
    verilator_top->req   = 0;

    eval();eval();eval();eval();eval();

    verilator_top->x = (x0.i>>16)|(y0.i&0xffff0000);
    verilator_top->y = (x1.i>>16)|(y1.i&0xffff0000);
    verilator_top->z = (x2.i>>16)|(y2.i&0xffff0000);
    verilator_top->w = (x3.i>>16)|(y3.i&0xffff0000);

    verilator_top->req   = 1;
    eval();
    verilator_top->req   = 0;

    eval();eval();eval();eval();


    check((signed)verilator_top->acc0, verilator_top->exp0, expect0, x0, y0, z0);
    check((signed)verilator_top->acc1, verilator_top->exp1, expect1, x1, y1, z1);
    check((signed)verilator_top->acc2, verilator_top->exp2, expect2, x2, y2, z2);
    check((signed)verilator_top->acc3, verilator_top->exp3, expect3, x3, y3, z3);

  }
  delete verilator_top;
  tfp->close();

  exit(0);
}
