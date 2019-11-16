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
      for(int p=0; p<32; p++){
        if(q!=2){
          if(( (p+1)*12 <= max*2*(b+0) )&&
             ( (p+0)*12 >= min*2*(b+1) )  ){
            printf("%2d ",p);
          }else{
            //printf("NG:b=%2d, p=%2d, q=%d, min=%f, max=%f, MIN=%f, MAX=%f\n",
            //b ,p, q, min/12.0, max/12.0,
            //((p+0.0)/(b+1.0)/2), ((p+1.0)/(b+0.0)/2));
          }
        }else{ // q==2
          if(( (p+0)*12 <  max*2*(b+1) )&&
             ( (p+0)*12 >= min*2*(b+1) )  ){
            printf("%2d ",p);
          }
        }
      }
      printf("\n");
    }
  }
}

