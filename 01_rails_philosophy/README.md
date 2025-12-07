# 第1章：Railsの設計哲学とアーキテクチャを理解する - 実装

この章では、Railsの基本的な構造とアーキテクチャを実際に確認します。

## 前提条件

- Ruby 3.2以上がインストールされていること
- Rails 7.2以上がインストールされていること

Railsがインストールされていない場合は、以下のコマンドでインストールできます。

```bash
gem install rails -v '~> 7.2.0'
```

## 実装の進め方

### 1. Railsプロジェクトの作成

```bash
cd rails_tutorial/01_rails_philosophy
rails new sample_app --skip-test --skip-bundle
cd sample_app
```

オプションの説明を以下に示します。

`--skip-test`は、デフォルトのMinitestテストフレームワークをスキップします。第6章でRSpecを使用するため、ここでは不要です。

`--skip-bundle`は、初期の`bundle install`をスキップします。Gemfileを確認してから手動で実行します。

### 2. ディレクトリ構造の確認

プロジェクトが作成されたら、ディレクトリ構造を確認します。

```bash
cd sample_app
tree -L 2 -I 'node_modules|tmp|log'
```

主要なディレクトリの役割を以下に示します。

- `app/`にはアプリケーションコード（models, controllers, views）が配置されます
- `config/`には設定ファイルが配置されます
- `db/`にはデータベース関連ファイルが配置されます
- `public/`には静的ファイルが配置されます

### 3. ミドルウェアスタックの確認

Railsがどのようなミドルウェアを使用しているかを確認します。

```bash
cd sample_app
bundle install --gemfile ./Gemfile
rails middleware
```

このコマンドは、リクエストが通過するミドルウェアの一覧を表示します。各ミドルウェアの役割については、記事を参照してください。

### 4. ActiveSupportの機能を試す

Railsコンソールを起動して、ActiveSupportの便利なメソッドを試します。

```bash
cd sample_app
rails console
```

コンソール内で以下のコードを実行します。

```ruby
# 日付操作
7.days.from_now
2.weeks.ago
3.months.since(Time.current)

# 文字列操作
"user_name".camelize
"UserName".underscore
"person".pluralize
"people".singularize

# 便利なメソッド
"".blank?
nil.blank?
"text".present?

# 終了
exit
```

### 5. ルーティングとコントローラの動作確認

簡単なコントローラとビューを作成して、MVCの動作を確認します。

```bash
cd sample_app
rails generate controller Welcome index
```

このコマンドは以下のファイルを生成します。

- `app/controllers/welcome_controller.rb`
- `app/views/welcome/index.html.erb`
- ルーティング設定が`config/routes.rb`に追加されます

生成されたファイルを確認します。

```bash
cat app/controllers/welcome_controller.rb
cat app/views/welcome/index.html.erb
cat config/routes.rb
```

サーバを起動して動作を確認します。

```bash
rails server
```

ブラウザで`http://localhost:3000/welcome/index`にアクセスして、ビューが表示されることを確認します。

### 6. Gemfileの確認

依存関係管理を理解するため、Gemfileを確認します。

```bash
cd sample_app
cat Gemfile
```

各gemの役割とバージョン指定方法を確認してください。記事で説明した`~>`や`>=`の意味を実際のGemfileで確認できます。

### 7. 環境別設定の確認

環境別の設定ファイルを確認します。

```bash
cd sample_app
cat config/environments/development.rb
cat config/environments/test.rb
cat config/environments/production.rb
```

各環境で異なる設定がどのように記述されているかを確認してください。

## スクリプトの実行

このディレクトリには、Railsの機能を確認するためのスクリプトが用意されています。

### middleware_info.rb

ミドルウェアスタックの情報を表示するスクリプトです。

```bash
cd sample_app
rails runner ../middleware_info.rb
```

### activesupport_demo.rb

ActiveSupportの便利なメソッドを試すスクリプトです。

```bash
cd sample_app
rails runner ../activesupport_demo.rb
```

## まとめ

この実装を通じて、以下の点を確認しました。

- Railsプロジェクトの基本構造
- ディレクトリの役割と配置
- ミドルウェアスタックの構成
- ActiveSupportが提供する便利なメソッド
- MVCパターンの基本的な動作

次章では、ActiveRecordを使用したデータモデリングに進みます。
