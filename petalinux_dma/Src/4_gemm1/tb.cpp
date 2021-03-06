#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtop.h"

vluint64_t main_time = 0;
vluint64_t vcdstart = 0;
vluint64_t vcdend = vcdstart + 300000;

VerilatedVcdC* tfp;
Vtop* verilator_top;

void eval()
{
  // negedge clk /////////////////////////////
  verilator_top->S_AXI_ACLK = 0;
  verilator_top->AXIS_ACLK = 0;

  verilator_top->eval();

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  // posegedge clk /////////////////////////////
  verilator_top->S_AXI_ACLK = 1;
  verilator_top->AXIS_ACLK = 1;

  verilator_top->eval();

  if((main_time>=vcdstart)&((main_time<vcdend)|(vcdend==0)))
    tfp->dump(main_time);
  main_time += 5;

  return;
}

int main(int argc, char **argv) {

  // Verilator setup /////////////////////////////
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  verilator_top = new Vtop;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open("tmp.vcd");
  main_time = 0;

  // initial begin /////////////////////////////
  verilator_top->S_AXI_BREADY = 1;
  verilator_top->S_AXI_WSTRB = 15;
  verilator_top->S_AXI_RREADY = 1;
  verilator_top->S_AXIS_TSTRB = 15;
  verilator_top->S_AXIS_TLAST = 0;
  verilator_top->M_AXIS_TREADY = 1;

  verilator_top->S_AXI_ARESETN = 0;
  verilator_top->S_AXI_ACLK = 1;
  verilator_top->AXIS_ARESETN = 0;
  verilator_top->AXIS_ACLK = 1;
  verilator_top->S_AXI_ARVALID = 0;
  verilator_top->S_AXI_AWVALID = 0;
  verilator_top->S_AXI_WVALID = 0;
  verilator_top->S_AXIS_TVALID = 0;
  verilator_top->eval();
  main_time += 5;

  eval();eval();
  verilator_top->S_AXI_ARESETN = 1;
  verilator_top->AXIS_ARESETN = 1;
  eval();eval();

////////////////////// Set Matrix /////////////////////////////
  int matrix[4][8];

  printf("\n--- Set Matrix ---\n");
  for(int j=0; j<4; j++){
    for(int i=0; i<8; i++){
      matrix[j][i] = rand() & 0x000000ff;
      printf("%3d ",matrix[j][i]);
    }
    printf("\n");
  }
  // matw <- 1;
  verilator_top->S_AXI_AWADDR = 0;
  verilator_top->S_AXI_WDATA = 1;
  verilator_top->S_AXI_AWVALID = 1;
  verilator_top->S_AXI_WVALID = 1;
  eval();
  verilator_top->S_AXI_AWVALID = 0;
  verilator_top->S_AXI_WVALID = 0;
  eval();eval();

  verilator_top->S_AXIS_TVALID = 1;
  for(int i=0; i<20; i++){
    verilator_top->S_AXIS_TDATA = matrix[i/8][i%8];
    eval();
  }
  verilator_top->S_AXIS_TVALID = 0;
  eval();
  verilator_top->S_AXIS_TVALID = 1;
  for(int i=20; i<32; i++){
    verilator_top->S_AXIS_TDATA = matrix[i/8][i%8];
    eval();
  }
  verilator_top->S_AXIS_TVALID = 0;
  
  // matw <- 0;
  verilator_top->S_AXI_AWADDR = 0;
  verilator_top->S_AXI_WDATA = 0;
  verilator_top->S_AXI_AWVALID = 1;
  verilator_top->S_AXI_WVALID = 1;
  eval();
  verilator_top->S_AXI_AWVALID = 0;
  verilator_top->S_AXI_WVALID = 0;
  eval();eval();


////////////////////// run /////////////////////////////
  // run <- 1;
  verilator_top->S_AXI_AWADDR = 0;
  verilator_top->S_AXI_WDATA = 2;
  verilator_top->S_AXI_AWVALID = 1;
  verilator_top->S_AXI_WVALID = 1;
  eval();
  verilator_top->S_AXI_AWVALID = 0;
  verilator_top->S_AXI_WVALID = 0;
  eval();eval();

  int sample[4][8];

  for(int num = 0; num < 2; num++){

    printf("\n--- Sample %d Input ---\n", num);
    for(int j=0; j<4; j++){
      for(int i=0; i<8; i++){
        sample[j][i] = rand() & 0x000000ff;
        printf("%3d ",sample[j][i]);
      }
      printf("\n");
    }

    verilator_top->S_AXIS_TVALID = 1;
    for(int i=0; i<20; i++){
      verilator_top->S_AXIS_TDATA = sample[i/8][i%8];
      eval();
    }
    verilator_top->S_AXIS_TVALID = 0;
    eval();
    verilator_top->S_AXIS_TVALID = 1;
    for(int i=20; i<32; i++){
      verilator_top->S_AXIS_TDATA = sample[i/8][i%8];
      eval();
    }
    verilator_top->S_AXIS_TVALID = 0;

    while(!verilator_top->M_AXIS_TVALID){
      eval();
    }

    printf("\n--- Sample %d Output ---\n", num);
    for(int j=0; j<4; j++){
      int sum[4] = {};
      for(int k=0; k<8; k++){
        for(int i=0; i<4; i++){
          sum[i] += matrix[i][k] * sample[j][k];
        }
      }
      for(int i=0; i<4; i++){
        printf("%6d ",verilator_top->M_AXIS_TDATA);
        if(verilator_top->M_AXIS_TDATA != sum[i]){
          printf("(Error Expecetd = %6d) ",sum[i]);
        }
        eval();
      }
      printf("\n");
      verilator_top->M_AXIS_TREADY = 0;
      eval();
      verilator_top->M_AXIS_TREADY = 1;
    }
  }

  // run <- 0;
  verilator_top->S_AXI_AWADDR = 0;
  verilator_top->S_AXI_WDATA = 0;
  verilator_top->S_AXI_AWVALID = 1;
  verilator_top->S_AXI_WVALID = 1;
  eval();
  verilator_top->S_AXI_AWVALID = 0;
  verilator_top->S_AXI_WVALID = 0;
  eval();eval();

  eval();eval();
  verilator_top->S_AXI_ARESETN = 0;
  verilator_top->AXIS_ARESETN = 0;
  eval();eval();

  // $finish; end /////////////////////////////
  delete verilator_top;
  tfp->close();
  return 0;
}
