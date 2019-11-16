#include <stdio.h>

void main(){
  for(int b=8; b<16; b++){
    for(int q=0; q<=2; q++){
      int max, min;
      if(q==0){
        max = 2;//1.0/6.0;
        min = 0;
      }
      if(q==1){
        max = 5;//5.0/12.0;
        min = 1;//1.0/12.0;
      }
      if(q==2){
        max = 8;//2.0/3.0;
        min = 4;//1.0/3.0;
      }
      printf("b=%2d, q=%d, p=",b, q);
      for(int p=0; p<128; p++){
        if(q!=2){
          if(( (p+2)*12 <= max*8*(b+0) )&&
             ( (p-1)*12 >= min*8*(b+1) )  ){
            printf("%2d ",p);
          }
        }else{// q==2
          if(( (p-1)*12 <  max*8*(b+1) )&&
             ( (p-1)*12 >= min*8*(b+1) )  ){
            printf("%2d ",p);
          }
        }
      }
      printf("\n");
    }
  }
}

