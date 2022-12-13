# STM32H7にULPI(USB3300)をつけてデータ転送する
## ファームウェア
- `firm/tinyusb`の下にtinyusbをクローンする
    - このリポジトリにあるファイルで上書きする
- tinyusb.icoからプロジェクトを作る
    - このリポジトリにあるファイルで上書きする
## ホスト
- `host/`で`cmake; make`