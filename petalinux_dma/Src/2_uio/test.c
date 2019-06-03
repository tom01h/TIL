#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

volatile int *mem;

int data;

void main(){
  int fd;

  if ((fd = open("/dev/uio0", O_RDWR | O_SYNC)) < 0) {
    perror("open");
    return;
  }
  mem = (int*)mmap(NULL, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (mem == MAP_FAILED) {
    perror("mmap");
    close(fd);
    return;
  }

  for(int i=0; i<256; i++){
    data = (~i<<16|i);
    mem[0x400/4+i]=data;
  }
  //mem[0x400/4+100]=100;
  for(int i=0; i<256; i++){
    data = (~i<<16|i);
    if(mem[0x400/4+i]!=data){
      printf("err %d\n",i);
      return;
    }
  }
  printf("pass\n");
}
