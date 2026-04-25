# Rails実践チュートリアル

中級プログラマ向けのRails実践チュートリアルです。Railsの設計哲学を理解し、実装を通じて学習することを目的としています。

本チュートリアルの解説記事はZenn book として公開しています。

- Zenn book: [Rails実践チュートリアル](https://zenn.dev/okamyuji/books/rails_tutorial)

本リポジトリは各章のサンプル実装コードを提供します。記事を読みながら、対応するディレクトリ内のコードを動かして学習を進めてください。

## 対象読者

- プログラミングの基礎知識を持つ中級レベルの開発者
- 他の言語やフレームワークの経験があり、Railsを学びたい方
- Rubyの基本文法は理解しているが、Railsには不慣れな方

## チュートリアル構成

| 章 | テーマ | 実装ディレクトリ |
| --- | --- | --- |
| 第1章 | Railsの設計哲学とアーキテクチャを理解する | [01_rails_philosophy/](01_rails_philosophy/) |
| 第2章 | ActiveRecordによるデータモデリングの実践 | [02_activerecord/](02_activerecord/) |
| 第3章 | RESTfulなルーティングとコントローラ設計 | [03_routing_controllers/](03_routing_controllers/) |
| 第4章 | ビューの構造化とフロントエンド統合 | [04_views_frontend/](04_views_frontend/) |
| 第5章 | 認証と認可を実装する | [05_auth_authorization/](05_auth_authorization/) |
| 第6章 | テスト戦略とデバッグ手法 | [06_testing_debugging/](06_testing_debugging/) |
| 第7章 | 本番環境へのデプロイと運用 | [07_deployment_operations/](07_deployment_operations/) |

各章の実装ディレクトリには、その章のテーマを理解するためのサンプルコードと、動作確認用のスクリプトが含まれています。詳細は各ディレクトリの `README.md` を参照してください。

## 前提条件

- Ruby 3.2以上
- Rails 8.0以上
- PostgreSQL（第2章以降）
- Git

Railsをインストールするには、以下のコマンドを実行します。

```bash
gem install rails -v '~> 8.0.0'
```

## 学習の進め方

1. Zenn book で各章の記事を読み、理論と設計の意図を理解します
2. 本リポジトリの該当する実装ディレクトリの `README.md` に従って実装を進めます
3. 提供されているスクリプトを実行して動作を確認します
4. 自分でコードを修正して、挙動の違いを確かめながら理解を深めます

## ライセンス

このチュートリアルは学習目的で自由に使用できます。
