;; 起動時のメッセージを出さない
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
;; バックスペースを使う
(keyboard-translate ?\C-h ?\C-?)
;; 日本語等幅フォント
(create-fontset-from-ascii-font "ＭＳ ゴシック-11:weight=normal:slant=normal" nil "gothic11")
(set-fontset-font "fontset-gothic11" 'japanese-jisx0213.2004-1 "ＭＳ ゴシック-11:weight=normal:slant=normal" nil 'append)
(add-to-list 'default-frame-alist '(font . "fontset-gothic11"))
;; US Key で日本語ON/OFFのエラー出さない
(global-set-key [M-kanji] 'ignore)

;; Tab @ fundamental
(setq default-tab-width 4)
(setq indent-line-function 'indent-to-left-margin)
;; タブを使わない
(setq-default indent-tabs-mode nil)
;; デフォルトの文字コードと改行コード
(set-default-coding-systems 'utf-8-unix)
;; パスとファイル名はShift_JIS
(setq default-file-name-coding-system 'japanese-cp932-dos)

;; Markdown Mode
(autoload 'markdown-mode "markdown-mode.el" "Major mode for editing Markdown files" t)
(setq auto-mode-alist (cons '("\\.md" . markdown-mode) auto-mode-alist))

;;Load verilog-mode only when needed
(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
(add-to-list 'auto-mode-alist '("\\.[ds]?vh?\\'" . verilog-mode))
;; Any files that end in .v should be in verilog mode
;(setq auto-mode-alist (cons '("\\.v\\'" . verilog-mode) auto-mode-alist))
;(setq auto-mode-alist (append '(("\\.sv$" . verilog-mode)) auto-mode-alist))
;; Any files in verilog mode shuold have their keywords colorized
;(add-hook 'verilog-mode-hook '(lambda () (font-look-mode 1)))
