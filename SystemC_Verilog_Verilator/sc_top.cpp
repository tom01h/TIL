#include "sc_top.h"

void sc_top::loop(){
  wa.write(0);
  ia.write(0);
  last.write(0);

  wait();

  while(true){
    for(int c=0; c<=1; c++){
      for(int y=0; y<=2; y++){
        for(int x=0; x<=2; x++){

          wa.write(c*9+y*3+x);
          ia.write(c*100+y*10+x);

          if(!((c==1)&&(y==2)&&(x==2))){
            wait();
          }
          while(!start.read()&(c==0)&&(y==0)&&(x==0)){
            wait();
          }
        }
      }
    }
    last.write(1);
    wait();
    last.write(0);
  }
}
