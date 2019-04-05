void loop::loop(){
  while(true){
    if(start.read()){
      for(int c=0; c<3; c++){
        for(int y=0; y<3; y++){
          for(int x=0; x<3; x++){
            wa.write(c*9+y*3+x);
            ia.write(c*100+y*10+x);
            wait();
          }
        }
      }
      last.write(1);
      wait();
      last.write(0);
    } else {
      wait();
    }
  }
}
