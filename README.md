# Rails実践チュートリアル

中級プログラマ向けのRails実践チュートリアルです。Railsの設計哲学を理解し、実装を通じて学習することを目的としています。

## 対象読者

- プログラミングの基礎知識を持つ中級レベルの開発者
- 他の言語やフレームワークの経験があり、Railsを学びたい方
- Rubyの基本文法は理解しているが、Railsには不慣れな方

## チュートリアル構成

各章は理論と実装の両方を含んでいます。`docs/`ディレクトリに記事、各章のディレクトリに実装コードがあります。

### 第1章：Railsの設計哲学とアーキテクチャを理解する

- 記事：[docs/01_rails_philosophy.md](docs/01_rails_philosophy.md)
- 実装：[01_rails_philosophy/](01_rails_philosophy/)

### 第2章：ActiveRecordによるデータモデリングの実践

- 記事：[docs/02_activerecord.md](docs/02_activerecord.md)
- 実装：[02_activerecord/](02_activerecord/)

### 第3章：RESTfulなルーティングとコントローラ設計

- 記事：[docs/03_routing_controllers.md](docs/03_routing_controllers.md)
- 実装：[03_routing_controllers/](03_routing_controllers/)

### 第4章：ビューの構造化とフロントエンド統合

- 記事：[docs/04_views_frontend.md](docs/04_views_frontend.md)
- 実装：[04_views_frontend/](04_views_frontend/)

### 第5章：認証と認可を実装する

- 記事：[docs/05_auth_authorization.md](docs/05_auth_authorization.md)
- 実装：[05_auth_authorization/](05_auth_authorization/)

### 第6章：テスト戦略とデバッグ手法

- 記事：[docs/06_testing_debugging.md](docs/06_testing_debugging.md)
- 実装：[06_testing_debugging/](06_testing_debugging/)

### 第7章：本番環境へのデプロイと運用

- 記事：[docs/07_deployment_operations.md](docs/07_deployment_operations.md)
- 実装：[07_deployment_operations/](07_deployment_operations/)

## 前提条件

- Ruby 3.2以上
- Rails 7.2以上
- PostgreSQL（第2章以降）
- Git

Railsをインストールするには、以下のコマンドを実行します。

```bash
gem install rails -v '~> 7.2.0'
```

## 学習の進め方

1. 各章の記事を読んで理論を理解します
2. 実装ディレクトリのREADMEに従って実装を進めます
3. 提供されているスクリプトを実行して動作を確認します
4. 自分でコードを修正して理解を深めます

## ライセンス

このチュートリアルは学習目的で自由に使用できます。
