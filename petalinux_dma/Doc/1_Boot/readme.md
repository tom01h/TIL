# 1 Petalinux をブートする

SD カード上に root ファイルシステムを持つ Petalinux を作成して Zynq でブートします。

### ブロックデザインを作る

[NahiViva](https://github.com/tokuden/NahiViva) で再現できるようにしました。説明は [こっち](http://nahitafu.cocolog-nifty.com/nahitafu/2019/05/post-2cfa5c.html) を見た方が良いかも。  
ディレクトリ ```ArtyZ7/1_Boot/``` に必要なファイルをダウンロードして、```open_project_gui.cmd``` 実行でプロジェクトが再現されます。

#### 手動でやるなら

1. Vivado で PS だけを配置したブロックデザインを作成する (design_1.pdf 参照)

### Petalinux を作る

Vivado でビットストリーム込みの xsa ファイルをエクスポート、```petalinux_dma/project_1```にコピーして、

```
$ source /opt/pkg/petalinux/settings.sh
$ petalinux-create --type project --template zynq --name petalinux_dma
$ cd petalinux_dma/
$ petalinux-config --get-hw-description=./project_1
```

menuconfig の画面で ```Image Packaging Configuration ->  Root filesystem type -> EXT(SD...)``` を選択する。

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

### 実行する

SD カードを挿入して Zynq をブートします。

login,password 共に root でログインできます。