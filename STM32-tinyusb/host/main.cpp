#include <stdio.h>
#include <sys/time.h>

#include <unistd.h>
#include <stdlib.h>

#define BUFFERSIZE 512*512
//#define BUFFERSIZE 64

#include <libusb.h>
#define PMODUSB_VID       0x0483
#define PMODUSB_PID       0x5741
#define PMODUSB_INTF      2
#define PMODUSB_READ_EP   0x84
#define PMODUSB_WRITE_EP  0x03
libusb_context *usb_ctx;
libusb_device_handle *dev_handle;

int device_init()
{
    int ret;

    if (libusb_init(&usb_ctx) < 0) {
        printf("[ERROR] libusb init failed!\n");
        return -1;
    }
    dev_handle = libusb_open_device_with_vid_pid(usb_ctx, PMODUSB_VID, PMODUSB_PID);
    if (!dev_handle) {
        printf("[ERROR] failed to open usb device!\n");
        libusb_exit(usb_ctx);
        return -1;
    }
    ret = libusb_claim_interface(dev_handle, PMODUSB_INTF);
    if (ret) {
        printf("[!] libusb error while claiming PMODUSB interface\n");
        libusb_close(dev_handle);
        libusb_exit(usb_ctx);
        return -1;
    }

    return 0; // success
}

void device_close()
{
    if (dev_handle)
        libusb_close(dev_handle);
    if (usb_ctx)
        libusb_exit(usb_ctx);
}

int read_dev(int size, u_int8_t *receive_data) {
    int r;
    int actual_length = 0;

    r = libusb_bulk_transfer(dev_handle, PMODUSB_READ_EP, receive_data, size, &actual_length, 1000);
    if (r < 0) {
        device_close();
        return -1;
    }

    return actual_length;
}

int write_dev(int size, u_int8_t *send_data) {
    int r;
    int actual_length = 0;

    r = libusb_bulk_transfer(dev_handle, PMODUSB_WRITE_EP, send_data, size , &actual_length, 1000);
    if ( r != 0 ){
        printf("write_dev error %d\n", r);
        device_close();
        return -1;
    }

    return actual_length;
}

int main(){
    unsigned int sec;
    int nsec;
    double d_sec;
    struct timespec start_time, end_time;

    u_int8_t aTxBuffer[BUFFERSIZE];    // バッファ
    u_int8_t aRxBuffer[BUFFERSIZE];    // バッファ

    int microsecond = 1 * 1000 * 1000;

    // Init
    if (device_init() != 0) {
        return -1;
    }

    while(1){
        for(int i = 0; i < BUFFERSIZE; i++){
            aTxBuffer[i] = rand();
        }

        clock_gettime(CLOCK_REALTIME, &start_time);

        int actual_length = 0;

        actual_length = write_dev(BUFFERSIZE, aTxBuffer);
        if(actual_length < 0){
            printf("write error\n");    
            return -1;
        }

        actual_length = read_dev(BUFFERSIZE, aRxBuffer);

        clock_gettime(CLOCK_REALTIME, &end_time);
        sec = end_time.tv_sec - start_time.tv_sec;
        nsec = end_time.tv_nsec - start_time.tv_nsec;
        d_sec = (double)sec + (double)nsec / (1000 * 1000 * 1000);
        printf("time:%f, %f Mpbs\n", d_sec, BUFFERSIZE*8*2*1/d_sec/1000/1000);

        //actual_length = read_dev(aRxBuffer);
        for(int i = 0; i < BUFFERSIZE/16; i++){
            for(int j = 0; j < 16; j++){
                if(aTxBuffer[i*16+j] != aRxBuffer[i*16+j]){
                    printf("Error %i, %02x, %02x ", i*16+j, aTxBuffer[i*16+j], aRxBuffer[i*16+j]);
                } else {
                    //printf("%02x ",aTxBuffer[i*16+j]);
                }
            }
            //printf("\n");
        }
        //printf("\n");
      
        usleep(microsecond);

    }
    return 0;
}