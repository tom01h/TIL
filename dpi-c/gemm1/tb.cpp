#include "svdpi.h"
#include "dpiheader.h"
#include <stdio.h>
#include <stdlib.h>

DPI_LINK_DECL
int c_tb() {

  v_init();

  int array[64];
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
  v_write(0,1);
  for(int i=0; i<32; i++){
    array[i] = matrix[i/8][i%8];
  }
  v_send(array, 32);
  // matw <- 0;
  v_write(0,0);

////////////////////// run /////////////////////////////
  // run <- 1;
  v_write(0,2);

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

    for(int i=0; i<32; i++){
      array[i] = sample[i/8][i%8];
    }
    v_send(array, 32);

    v_receive(array, 16);

    printf("\n--- Sample %d Output ---\n", num);
    for(int j=0; j<4; j++){
      int sum[4] = {};
      for(int k=0; k<8; k++){
        for(int i=0; i<4; i++){
          sum[i] += matrix[i][k] * sample[j][k];
        }
      }
      for(int i=0; i<4; i++){
        printf("%6d ",array[j*4+i]);
        if(array[j*4+i] != sum[i]){
          printf("(Error Expecetd = %6d) ",sum[i]);
        }
      }
      printf("\n");
    }
  }

  // run <- 0;
  v_write(0,0);

  v_finish();
  return 0;
}
