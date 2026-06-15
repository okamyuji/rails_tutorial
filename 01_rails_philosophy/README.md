# 第1章：Railsの設計哲学とアーキテクチャを理解する

`rails new` で生成した素のRailsアプリケーションです。
本章ではコードの追加はなく、ディレクトリ構造とRailsの規約を確認します。

## 動作確認

```bash
bin/rails server
# http://localhost:3000 でウェルカム画面を確認
```

## ミドルウェアスタックの確認

```bash
bin/rails middleware
# または
bin/rails runner middleware_info.rb
```

## ActiveSupportの体験

```bash
bin/rails console
```

```ruby
7.days.from_now
"user_name".camelize
"".blank?
```

スクリプトでまとめて確認する場合は以下を実行します。

```bash
bin/rails runner activesupport_demo.rb
```
