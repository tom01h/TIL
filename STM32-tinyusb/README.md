# STM32H7にULPI(USB3300)をつけてデータ転送する
## ファームウェア
- `firm/tinyusb`の下にtinyusbをクローンする
    - このリポジトリにあるファイルで上書きする
- tinyusb.icoからプロジェクトを作る
    - このリポジトリにあるファイルで上書きする
- [ここ](https://github.com/hathach/tinyusb/discussions/633)に従って参照パスを追加する
```
- Right click the project, go to properties. in C/C++ General -> Paths and Symbols, in the "Includes" tab add a path, make it a workspace path, point it to the tinyusb/src directory. Then, in the "Source Location" tab, add folder, and also point it to tinyusb/src
- Add a tusb_config.h to your "Core/Inc"
```

## ホスト
- `host/`で`cmake; make`