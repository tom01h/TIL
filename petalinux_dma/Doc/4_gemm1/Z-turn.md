# 4 PL 上の 行列乗算器(1)を使う

PL に作った行列乗算器を使って計算します。  
IP は 行列メモリ、入力データバッファ、出力データバッファを持ち、それぞれ dma を使ってアクセスします。

アドレス0のレジスタのビット0に1を書くと行列メモリ書き込みモードに入ります。  
このモードで AXIストリームからデータを入力して行列メモリに書き込みます。  
書き込める行列のサイズは4行8列固定で、列→行の順にデータを送ります。

アドレス0のレジスタのビット1に1を書くと行列乗算モードに入ります。  
データ入力→行列乗算→結果出力の順に実行します。  
入力データは8行4列固定で、行→列の順にデータを送ります。  
AXI ストリームからデータを入力し終わると行列乗算を開始し、計算が終わると AXI ストリームから結果を出力します。  
4行4列の乗算結果の出力が終わると、次の入力データ待ち状態となります。

IP の行列乗算機能は疑似コードを書くとこんな感じ。

```
    for(int j=0; j<4; j++){
      int sum[4] = {};
      for(int k=0; k<8; k++){
      	int d = in_buf[j][k];
# parallel for
        for(int i=0; i<4; i++){
          sum[i] += matrix[i][k] * d;
        }
      }
      for(int i=0; i<4; i++){
        out_buf[j][i] = sum[i];
      }
    }
```

データの入出力には Xilinx の AXI DMA IP を使います。  
また、[udmabuf](https://github.com/ikwzm/udmabuf/blob/master/Readme.ja.md) を使ってハードウェアでキャッシュコヒーレンシを保証した  DMA 転送をします。

行列乗算モジュールの実装はかなりいい加減なので流用することはあまり考えないでください。

## RTL シミュレーションを実行する

SystemC + Verilator とコラボした協調検証環境(全部手彫り)です。

##### ツールのバージョン

- g++ (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0
- Verilator 4.010 2019-01-27 rev UNKNOWN_REV
- SystemC 2.3.3-Accellera

##### 環境

テストベンチは ```tb.cpp``` です。だらだら長く書いていますが、まぁ、見た通りです。  
レジスタ設定のための AXI Lite 書き込みと、データ読み書きの AXIストリームデータを生成しています。  
流してみるのが早いと思います。

##### 実行法

```
$ make
$ ./sim/Vtop
```

## FPGA で実行する

### ブロックデザインを作る

[NahiViva](https://github.com/tokuden/NahiViva) で再現できるようにしました。説明は [こっち](http://nahitafu.cocolog-nifty.com/nahitafu/2019/05/post-2cfa5c.html) を見た方が良いかも。  
次のディレクトリ ```Zturn/4_gemm1/``` に必要なファイルをダウンロードして、```open_project_gui.cmd``` 実行でプロジェクトが再現されます。

#### 手動でやるなら

1. サンプルデザイン ```mys-xc7z020-trd``` のブロックデザインを開いて Zynq 以外を消す。*
2. Vivado でソースファイル （```Src/4_gemm1/top.v, buf.sv, control.sv, core.sv, ex_ctl.sv, loop_lib.sv``` ）を開く
3. ブロックデザインの中に ```top``` を RTLモジュールとして追加する
4. ほかの部品を ```design_1.pdf``` を参考に追加して結線する
5. PL のクロックは 100MHz
6. アドレスマップは下記参照

| master | slave module | Start Address | End Address |
| ------ | ------------ | ------------- | ----------- |
| PS7    | top          | 4000_0000     | 4000_0FFF   |
|        | AXI DMA      | 4040_0000     | 4040_0FFF   |
| DMA    | DDR          | 0000_0000     | 1FFF_FFFF   |

*) 付属の DVD に入っていた mys-xc7z020-trd.rar を解凍します。

ACP を使うときには AxCACHE を 1111 or 1110 にする必要があるようなので ```Constant IP``` を使って 1111 を入れています。  
詳しい話は [ここ](https://qiita.com/ikwzm/items/b2ee2e2ade0806a9ec07) が参考になります。  
あと、PL の設定で ```Tie off AxUSER``` にチェックを入れています。

### Petalinux を作る

Vivado でビットストリーム込みの hdf ファイルをエクスポート、```petalinux_dma/mys-xc7z020-trd.sdk```にコピーして、

```
$ source /opt/pkg/petalinux/2019.1/settings.sh
$ petalinux-create --type project --template zynq --name petalinux_dma
$ cd petalinux_dma/
$ petalinux-config --get-hw-description=./mys-xc7z020-trd.sdk
```

menuconfig の画面で ```Image Packaging Configuration ->  Root filesystem type -> SD card``` を選択する。

DMA 転送に使うバッファ用に [udmabuf](https://github.com/ikwzm/udmabuf/blob/master/Readme.ja.md) を作る。

```
$ petalinux-create -t modules --name udmabuf --enable
$ petalinux-build -c rootfs
```

ダウンロードしたファイルで ```project-spec/meta-user/recipes-modules/udmabuf/files/``` を置き換えて、

```
$ petalinux-build -c udmabuf
```

続けて、udmabuf の設定をして、DMA と mem のアドレス空間を uio にする。  
DMA に ```dma-coherent``` を設定する。  
デバイスツリーに ```dma-coherent``` 付きで udmabuf を追加する。  
具体的には ```Zturn/4_gemm1/system-user.dtsi``` で ```project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi``` を上書きして、

```
$ petalinux-build
```

続けて、

```
$ petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot
```

生成物は ```images/linux/BOOT.bin, image.ub, rootfs.ext4``` です。

BOOT.bin,  image.ub を SDカード(FAT32) にコピーする。

```
$ cp images/linux/BOOT.bin /media/tom01h/BOOT
$ cp images/linux/image.ub /media/tom01h/BOOT
```

rootfs.ext4 を SDカード(ext4) にコピーする。SD カードをアンマウントして、

```
$ sudo dd if=images/linux/rootfs.ext4 of=/dev/sdb2 bs=16M
$ sudo sync
$ sudo resize2fs /dev/sdb2
$ sudo sync
```

### プログラムをコンパイルする

ホストPCでクロスコンパイルして SDカード(FAT32) にコピーする。

```
$ ${SDK path}/gnu/aarch32/nt/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-gcc.exe  test.c -o test
```

### 実行する

SD カードを挿入して Zynq をブートします。

login,password 共に root でログインできます。

```
root@petalinux_dma:~# mount /dev/mmcblk0p1 /mnt/
root@petalinux_dma:~# /mnt/test
```


