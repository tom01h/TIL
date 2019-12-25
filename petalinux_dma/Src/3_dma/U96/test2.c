#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

volatile int *mem;
volatile int *dma;
volatile int *src;
volatile int *dst;
unsigned long src_phys;
unsigned long dst_phys;

int data;

void dma_reset(){
  dma[0x30/4] = 4;
  dma[0x00/4] = 4;
  while (dma[0x00/4] & 0x4);
}

void main(){
  int fd0,fd1,dmaf,memf;

  if ((fd0  = open("/sys/class/udmabuf/udmabuf0/phys_addr", O_RDONLY)) != -1) {
    char attr[1024];
    read(fd0, attr, 1024);
    sscanf(attr, "%lx", &src_phys);
    close(fd0);
  }
  if ((fd0  = open("/sys/class/udmabuf/udmabuf1/phys_addr", O_RDONLY)) != -1) {
    char attr[1024];
    read(fd0, attr, 1024);
    sscanf(attr, "%lx", &dst_phys);
    close(fd0);
  }

  if ((fd0 = open("/dev/udmabuf0", O_RDWR)) < 0) {
    perror("open");
    return;
  }
  if ((fd1 = open("/dev/udmabuf1", O_RDWR)) < 0) {
    perror("open");
    return;
  }
  if ((dmaf = open("/dev/uio4", O_RDWR | O_SYNC)) < 0) {
    perror("open");
    return;
  }
  if ((memf = open("/dev/uio5", O_RDWR | O_SYNC)) < 0) {
    perror("open");
    return;
  }

  mem = (int*)mmap(NULL, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, memf, 0);
  if (mem == MAP_FAILED) {
    perror("mmap");
    close(memf);
    return;
  }
  dma = (int*)mmap(NULL, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, dmaf, 0);
  if (dma == MAP_FAILED) {
    perror("mmap");
    close(dmaf);
    return;
  }
  src = (int*)mmap(NULL, 0x00080000, PROT_READ | PROT_WRITE, MAP_SHARED, fd0, 0);
  if (src == MAP_FAILED) {
    perror("mmap");
    close(fd0);
    return;
  }
  dst = (int*)mmap(NULL, 0x00080000, PROT_READ | PROT_WRITE, MAP_SHARED, fd1, 0);
  if (dst == MAP_FAILED) {
    perror("mmap");
    close(fd1);
    return;
  }


  // AXI DMA transfer rx
  dma_reset();
  dma[0x30/4] = 1;
  dma[0x48/4] = dst_phys;
  dma[0x58/4] = 256*4;

  // MEM DMA Read Mode
  mem[0x00/4]=2;
  mem[0x04/4]=256;

  // Wait for the rx to finish
  while ((dma[0x34/4] & 0x1000)!=0x1000);

  // MEM DMA Idle
  mem[0x00/4]=0;


  for(int i=0; i<256; i++){
    data = (~i<<16|i);
    if(dst[i]!=data){
      printf("err %d\n",i);
      return;
    }
  }
  printf("pass\n");
}
