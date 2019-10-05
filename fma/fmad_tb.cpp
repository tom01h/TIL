#include "unistd.h"
#include "getopt.h"
#include "Vfma.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#define VCD_PATH_LENGTH 256

typedef union {
  double f;
  long i;
} fr;


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
  
  fr x, y, z;
  int xe, ye, ze;
  int i, nloop, flag;
  char *e;

  fr rslt, expect;

  i=0;

  if(argc==4){
    sscanf(argv[1],"%016lx", &x.i);
    sscanf(argv[2],"%016lx", &y.i);
    sscanf(argv[3],"%016lx", &z.i);
    nloop=1;
  } else if(argc==6){
    sscanf(argv[1],"%016lx", &x.i);
    sscanf(argv[2],"%016lx", &y.i);
    sscanf(argv[3],"%016lx", &z.i);
    sscanf(argv[4],"%016lx", &expect.i);
    flag = strtol(argv[5],&e,16);
    nloop=1;
  }
  
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  verilator_top = new Vfma;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");
  main_time = 0;

  verilator_top->req_command = 1;

  while ((i<nloop)|(argc==1)) {
    if(argc==1){
      if(scanf("%016lx %016lx %016lx %016lx %02x", &x.i, &y.i, &z.i, &expect.i, &flag)==EOF){
        break;}
    }else if(argc==6){
    }else{
      expect.f = (double)x.f * (double)y.f + (double)z.f;
      flag = -1;
    }
    verilator_top->x = x.i;
    verilator_top->y = y.i;
    verilator_top->z = z.i;

    verilator_top->reset = 1;
    eval();
    verilator_top->reset = 0;
    verilator_top->req   = 1;
    eval();
    verilator_top->req   = 0;

    eval();eval();eval();eval();eval();eval();eval();eval();eval();eval();

    rslt.i = verilator_top->rslt;
    if((expect.i==rslt.i)&((flag==-1)|(flag==verilator_top->flag))){
      printf("PASSED %04d : %016lx * %016lx + %016lx = %016lx .. %02x\n",i,x.i,y.i,z.i,rslt.i,flag&0xff);
    }else{
      printf("FAILED %04d : %016lx * %016lx + %016lx = %016lx .. %02x != %016lx .. %02x\n",i,x.i,y.i,z.i,expect.i,flag&0xff,rslt.i,verilator_top->flag);
    }
    i++;
  }
  delete verilator_top;
  tfp->close();

  
  exit(0);
}
