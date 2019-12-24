# 2 PL 上の BRAM に uio アクセスする 

PL に作った BRAM  に uio を使ってアクセスします。

BRAM は mem モジュール内のオフセット 0x400 から始まる 1KB に配置しています。

### ブロックデザインを作る

[NahiViva](https://github.com/tokuden/NahiViva) で再現できるようにしました。説明は [こっち](http://nahitafu.cocolog-nifty.com/nahitafu/2019/05/post-2cfa5c.html) を見た方が良いかも。  
ディレクトリ ```ArtyZ7/2_uio/``` に必要なファイルをダウンロードして、```open_project_gui.cmd``` 実行でプロジェクトが再現されます。

#### 手動でやるなら

1. Vivado でソースファイル （```Src/2_uio/mem.v``` ）を開く
2. ブロックデザインの中に ```mem``` を RTLモジュールとして追加する
3. ほかの部品を ```design_1.pdf``` を参考に追加して結線する
4. PL のクロックは 100MHz
5. アドレスマップは下記参照

| master | slave module | Start Address | End Address |
| ------ | ------------ | ------------- | ----------- |
| PS7    | mem          | 4000_0000     | 4000_0FFF   |

mem モジュールの中で BRAM はオフセット 0x400 から始まる 1KB が割り当てられています。 

### Petalinux を作る

Vivado でビットストリーム込みの xsa ファイルをエクスポート、```petalinux_dma/project_1```にコピーして、

```
$ source /opt/pkg/petalinux/settings.sh
$ petalinux-create --type project --template zynq --name petalinux_dma
$ cd petalinux_dma/
$ petalinux-config --get-hw-description=./project_1
```

menuconfig の画面で ```Image Packaging Configuration ->  Root filesystem type -> EXT(SD...)``` を選択する。

mem のアドレス空間を uio にする。    
具体的には ```Src/2_uio/system-user.dtsi``` で ```project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi``` を上書きして、

```
$ petalinux-build
```

続けて、

```
$ petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot
```

生成物は ```images/linux/BOOT.bin, image.ub, rootfs.tar.gz``` です。

BOOT.bin,  image.ub を SDカード(FAT32) にコピーする。

```
$ cp images/linux/BOOT.bin /media/tom01h/BOOT
$ cp images/linux/image.ub /media/tom01h/BOOT
```

rootfs.tar.gz を SDカード(ext4) にコピーする。

```
$ sudo tar xvf images/linux/rootfs.tar.gz -C /media/tom01h/${mount_point}
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

ブート後、Zynq の Linux 上で

```
root@petalinux_dma:~# mount /dev/mmcblk0p1 /mnt/
root@petalinux_dma:~# /mnt/test
```

実行後に devmem コマンドで 0x40000400 から始まる 1KB を確認してみてください。

