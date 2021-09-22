#include "svdpi.h"
#include "dpiheader.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

union long_char {
    char c[8];
    long long l;
    int i;
};
 
DPI_LINK_DECL
int c_tb() {
    int fd = open("./tb.txt", O_RDWR, S_IRUSR | S_IWUSR);
    if(fd == -1){
        printf("file open error\n");
        exit(1);
    }
    struct stat st;
    if(fstat(fd, &st) < 0){
        exit(1);
    }
    volatile char *buf = (char *)mmap(NULL, st.st_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    while(1){
        if(buf[0] != 0){
            if(buf[0] == 1){
                v_init();
            }
            else if(buf[0] == 2){
                buf[0] = 0;
                v_finish();
                break;
            }
            else if(buf[0] == 3){
                union long_char address, data;
                for(int i=0; i<8; i++){
                    address.c[i] = buf[i+8];
                    data.c[i] = buf[i+16];
                }
                v_write(address.i, data.i);
            }
            else if(buf[0] == 4){
                int array[64];
                union long_char data, size;
                for(int i=0; i<8; i++){
                    size.c[i] = buf[i+8];
                }
                for(int i=0; i<size.i; i++){
                    for(int j=0; j<8; j++){
                        data.c[j] = buf[i*8+j+16];
                    }
                    array[i] = data.i;
                }
                v_send(array, size.i);
            }                
            else if(buf[0] == 5){
                int array[64];
                union long_char data, size;
                for(int i=0; i<8; i++){
                    size.c[i] = buf[i+8];
                }
                v_receive(array, size.i);
                for(int i=0; i<size.i; i++){
                    data.i = array[i];
                    for(int j=0; j<8; j++){
                        buf[i*8+j+16] = data.c[j];
                    }
                }
            }
            buf[0] = 0;
        }
    }

    munmap((void*)buf, st.st_size);

    return 0;    
}