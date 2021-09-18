#include "svdpi.h"
#include "dpiheader.h"

#include <windows.h>
#include <string>

union long_char {
    char c[8];
    long long l;
    int i;
};
 
DPI_LINK_DECL
int c_tb() {
    char *buf;
    HANDLE map_handle;
    HANDLE handle;
    int size;
    std::wstring fname;

    fname.append(L"tb.txt");
    handle = CreateFileW(fname.c_str(), GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE, 0,
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if(handle == INVALID_HANDLE_VALUE) {
        //fprintf(stderr, "file open failed\n");
        exit(1);
    }
    size = GetFileSize(handle, 0);
    map_handle = CreateFileMapping(handle, 0, PAGE_READWRITE, 0, 0, 0);
    buf = (char*)MapViewOfFile(map_handle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    if(handle != INVALID_HANDLE_VALUE) {
        CloseHandle(handle);
        handle = INVALID_HANDLE_VALUE;
    }

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

    UnmapViewOfFile(buf);
    if(map_handle != INVALID_HANDLE_VALUE) {
        CloseHandle(map_handle);
        map_handle = INVALID_HANDLE_VALUE;
    }

    return 0;    
}