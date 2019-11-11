#include "unistd.h"
#include "getopt.h"
#include "Vfdiv.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

typedef union {
  float f;
  int i;
} fr;


VerilatedVcdC* tfp;
Vfdiv* verilator_top;
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
  
  fr x, y, z;
  int xe, ye, ze;
  int i, nloop, flag;
  char *e;

  fr rslt, expect;

  srand((unsigned)time(NULL));
  i=0;

  if(argc==3){
    x.i = strtol(argv[1],&e,16);
    y.i = strtol(argv[2],&e,16);
    nloop=1;
  } else if(argc==5){
    x.i = strtol(argv[1],&e,16);
    y.i = strtol(argv[2],&e,16);
    expect.i = strtol(argv[3],&e,16);
    flag = strtol(argv[4],&e,16);
    nloop=1;
  }
  
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  verilator_top = new Vfdiv;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");
  main_time = 0;

  while ((i<nloop)|(argc==1)) {
    if(argc==1){
      if(scanf("%08x %08x %08x %02x", &x.i, &y.i, &expect.i, &flag)==EOF){
        break;}
    }else if(argc==5){
    }else{
      expect.f = (double)x.f / (double)y.f;
      flag = -1;
    }
    if(((x.i&0x7f800000) == 0)  || ((y.i&0x7f800000) == 0)  || ((expect.i&0x7f800000) == 0)  ||
       ((x.i|0x807fffff) == -1) || ((y.i|0x807fffff) == -1) || ((expect.i|0x807fffff) == -1) ||
       (flag == 3) ){
      printf("SKIPED %04d : %08x / %08x = %08x .. %02x\n",i,x.i,y.i,expect.i,flag&0xff);
      continue;
    }

    verilator_top->x = x.i;
    verilator_top->y = y.i;

    verilator_top->reset = 1;
    eval();
    verilator_top->reset = 0;
    verilator_top->req   = 1;
    eval();
    verilator_top->req   = 0;

    for(int k=0; k<30;k++){
      eval();
    }

    rslt.i = verilator_top->rslt;
    if((expect.i==rslt.i)&((flag==-1)|(flag==verilator_top->flag))){
      printf("PASSED %04d : %08x / %08x = %08x .. %02x\n",i,x.i,y.i,rslt.i,flag&0xff);
    }else{
      printf("FAILED %04d : %08x / %08x = %08x .. %02x != %08x .. %02x\n",i,x.i,y.i,expect.i,flag&0xff,rslt.i,verilator_top->flag);
    }
    i++;
  }
  delete verilator_top;
  tfp->close();

  
  exit(0);
}
