# 3 PL 上の BRAM に DMA アクセスする

PL に作った BRAM  に dma を使ってアクセスします。

BRAM は mem モジュール内のオフセット 0x400 から始まる 1KB に配置しています。

DMA は Xilinx の AXI DMA IP を使います。

[udmabuf](https://github.com/ikwzm/udmabuf/blob/master/Readme.ja.md) を使ってハードウェアでキャッシュコヒーレンシを保証した  DMA 転送をします。

mem モジュールの実装はかなりいい加減なので流用することはあまり考えないでください。

### ブロックデザインを作る

[NahiViva](https://github.com/tokuden/NahiViva) で再現できるようにしました。説明は [こっち](http://nahitafu.cocolog-nifty.com/nahitafu/2019/05/post-2cfa5c.html) を見た方が良いかも。  
次のディレクトリ ```ArtyZ7/3_dam/``` に必要なファイルをダウンロードして、```open_project_gui.cmd``` 実行でプロジェクトが再現されます。

#### 手動でやるなら

1. Vivado でソースファイル （```Src/3_dma/mem.v``` ）を開く
2. ブロックデザインの中に ```mem``` を RTLモジュールとして追加する
3. ほかの部品を ```design_1.pdf``` を参考に追加して結線する
4. PL のクロックは 100MHz
5. アドレスマップは下記参照

| master | slave module | Start Address | End Address |
| ------ | ------------ | ------------- | ----------- |
| PS7    | mem          | 4000_0000     | 4000_0FFF   |
|        | AXI DMA      | 4040_0000     | 4040_0FFF   |
| DMA    | DDR          | 0000_0000     | 1FFF_FFFF   |

ACP 周りで Critical Warning 出るけど、良く分からないので放置しています。

```
[BD 41-1629] </processing_system7_0/S_AXI_ACP/ACP_M_AXI_GP0> is excluded from all addressable master spaces.
```

また、ACP を使うときには AxCACHE を 1111 or 1110 にする必要があるようなので ```Constant IP``` を使って 1111 を入れています。  
詳しい話は [ここ](https://qiita.com/ikwzm/items/b2ee2e2ade0806a9ec07) が参考になります。  
あと、PL の設定で ```Tie off AxUSER``` にチェックを入れています。

### Petalinux を作る

Vivado でビットストリーム込みの xsaファイルをエクスポート、```petalinux_dma/project_1```にコピーして、

```
$ source /opt/pkg/petalinux/2019.1/settings.sh
$ petalinux-create --type project --template zynq --name petalinux_dma
$ cd petalinux_dma/
$ petalinux-config --get-hw-description=./project_1
```

menuconfig の画面で ```Image Packaging Configuration ->  Root filesystem type -> EXT(SD...)``` を選択する。

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
具体的には ```CORA/3_dam/system-user.dtsi``` で ```project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi``` を上書きして、

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

```
root@petalinux_dma:~# mount /dev/mmcblk0p1 /mnt/
root@petalinux_dma:~# /mnt/test
```

実行後に devmem コマンドで 0x40000400 から始まる 1KB を確認してみてください。

また、test.c の後に test2.c も流してみてください。

さらに、以下のブートメッセージで udmabuf のアドレスを確認して、先頭から １KB を確認してみてください。

```
udmabuf udmabuf0: phys address   = 0x1f080000
udmabuf udmabuf1: phys address   = 0x1f100000
```