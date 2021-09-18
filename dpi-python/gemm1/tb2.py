import mmap
import top

def py_tb():
    with open("tb.txt", "r+b") as f:
        mm = mmap.mmap(f.fileno(), 0)
        while True:
            mm.seek(0)
            if mm[0:1] != b'\0':
                if mm[0:1] == b'\1':
                    top.c_init()
                    
                elif mm[0:1] == b'\2':
                    mm[0:1] = b'\0'
                    top.c_finish()
                    break
                    
                elif mm[0:1] == b'\3':
                    address = int.from_bytes(mm[8:16], byteorder='little')
                    data = int.from_bytes(mm[16:24], byteorder='little')
                    top.c_write(address, data)
                    
                elif mm[0:1] == b'\4':
                    list = []
                    for i in range(int.from_bytes(mm[8:16], byteorder='little')):
                        list.append(int.from_bytes(mm[8*i+16:8*i+24], byteorder='little'))
                    top.c_send(list)
                    
                elif mm[0:1] == b'\5':
                    num = int.from_bytes(mm[8:16], byteorder='little')
                    list = top.c_receive(num)
                    mm[8:16] = len(list).to_bytes(8, byteorder='little')
                    for i in range(len(list)):
                        mm[8*i+16:8*i+24] = list[i].to_bytes(8, byteorder='little')

                mm[0:1] = b'\0'

if __name__ == '__main__':
    py_tb()