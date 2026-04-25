# 第4章：ビューの構造化とフロントエンド統合 - 実装

この章では、ビューの構造化とフロントエンド技術（Turbo、Stimulus）を実際に実装します。

## 前提条件

- Ruby 3.2以上
- Rails 8.0以上
- Node.js（Importmap使用時は不要）

## ディレクトリ構造

```text
04_views_frontend/
├── helpers/                    # ヘルパーモジュール
│   ├── application_helper.rb   # 共通ヘルパー（エラー表示等）
│   ├── articles_helper.rb      # 記事用ヘルパー
│   └── turbo_helper.rb         # Turbo用ヘルパー
├── javascript/                 # Stimulusコントローラ
│   ├── autosubmit_controller.js # 自動送信フォーム
│   ├── clipboard_controller.js  # クリップボードコピー
│   ├── counter_controller.js    # カウンター
│   ├── dropdown_controller.js   # ドロップダウンメニュー
│   ├── flash_controller.js      # フラッシュメッセージ
│   ├── form_controller.js       # 動的フォーム
│   ├── modal_controller.js      # モーダルダイアログ
│   └── tabs_controller.js       # タブナビゲーション
├── views/                      # ビューテンプレート
│   ├── admin/
│   │   └── _sidebar.html.erb   # 管理画面サイドバー
│   ├── articles/
│   │   ├── _article.html.erb   # 記事パーシャル
│   │   ├── _form.html.erb      # フォームパーシャル
│   │   ├── create.turbo_stream.erb  # 作成時Turbo Stream
│   │   ├── destroy.turbo_stream.erb # 削除時Turbo Stream
│   │   ├── edit.html.erb       # 編集ページ
│   │   ├── index.html.erb      # 一覧ページ
│   │   ├── new.html.erb        # 新規作成ページ
│   │   ├── show.html.erb       # 詳細ページ
│   │   └── update.turbo_stream.erb  # 更新時Turbo Stream
│   ├── comments/
│   │   └── _comment.html.erb   # コメントパーシャル
│   ├── layouts/
│   │   ├── admin.html.erb      # 管理画面レイアウト
│   │   └── application.html.erb # 基本レイアウト
│   └── shared/
│       ├── _flash.html.erb     # フラッシュメッセージ
│       ├── _footer.html.erb    # 共通フッター
│       └── _header.html.erb    # 共通ヘッダー
├── form_helper_demo.rb         # フォームヘルパーデモ
├── partial_demo.rb             # パーシャルデモ
├── README.md                   # このファイル
├── seed_data.rb                # サンプルデータ生成
├── turbo_stimulus_demo.rb      # Turbo/Stimulusデモ
└── view_demo.rb                # ビュー機能デモ
```

## デモスクリプトの実行

```bash
# 概要デモ
rails runner view_demo.rb

# パーシャルとレイアウトの詳細
rails runner partial_demo.rb

# フォームヘルパーの詳細
rails runner form_helper_demo.rb

# TurboとStimulusの詳細
rails runner turbo_stimulus_demo.rb

# サンプルデータの生成
rails runner seed_data.rb
```

## 主な実装内容

### 1. パーシャルとレイアウト

#### パーシャルの使用

```erb
<%# コレクションをパーシャルに渡す %>
<%= render @articles %>

<%# ローカル変数を明示的に渡す %>
<%= render "sidebar", article: @article, show_actions: true %>
```

#### レイアウトの継承

```erb
<%# 管理画面レイアウト（applicationを継承） %>
<% content_for :content do %>
  <div class="admin-layout">
    <%= render "admin/sidebar" %>
    <%= yield %>
  </div>
<% end %>
<%= render template: "layouts/application" %>
```

### 2. フォームヘルパー

#### form_with の使用

```erb
<%= form_with model: @article do |f| %>
  <%= error_messages_for(@article) %>
  
  <div class="field <%= field_error_class(@article, :title) %>">
    <%= f.label :title %>
    <%= f.text_field :title %>
    <%= field_error_message(@article, :title) %>
  </div>
  
  <%= f.submit %>
<% end %>
```

#### ネストした属性

```erb
<%= f.fields_for :images do |image_form| %>
  <%= image_form.text_field :url %>
  <%= image_form.check_box :_destroy %>
<% end %>
```

### 3. Turbo

#### Turbo Frames

```erb
<%= turbo_frame_tag "articles" do %>
  <%= render @articles %>
  <%= link_to "Load More", articles_path(page: @next_page) %>
<% end %>
```

#### Turbo Streams

```erb
<%# 複数要素を同時更新 %>
<%= turbo_stream.prepend "articles", @article %>
<%= turbo_stream.update "article_count", Article.count %>
<%= turbo_stream.replace "new_article_form" do %>
  <%= render "form", article: Article.new %>
<% end %>
```

### 4. Stimulus

#### ドロップダウンメニュー

```html
<div data-controller="dropdown">
  <button data-action="click->dropdown#toggle">Menu</button>
  <div data-dropdown-target="menu" class="hidden">
    <a href="#">Item 1</a>
  </div>
</div>
```

#### カウンター

```html
<div data-controller="counter" 
     data-counter-count-value="0"
     data-counter-max-value="10">
  <button data-action="click->counter#decrement">-</button>
  <span data-counter-target="display">0</span>
  <button data-action="click->counter#increment">+</button>
</div>
```

#### 自動送信フォーム

```html
<form data-controller="autosubmit" data-autosubmit-delay-value="500">
  <input type="text" 
         data-action="input->autosubmit#submit"
         placeholder="Search...">
</form>
```

#### モーダルダイアログ

```html
<div data-controller="modal">
  <button data-action="click->modal#show">Open</button>
  <div data-modal-target="dialog" class="hidden">
    <div data-modal-target="content">
      <h2>Modal Title</h2>
      <button data-action="click->modal#hide">Close</button>
    </div>
  </div>
</div>
```

## ベストプラクティス

### パーシャルの設計

1. **再利用可能な単位で分割** - 同じコードが2回以上出現したらパーシャル化
2. **ローカル変数を明示的に渡す** - 依存関係を明確にする
3. **1つのパーシャルは1つの責務** - 単一責任の原則

### フォームの設計

1. **form_with を標準として使用** - モデルベースのフォーム
2. **エラーメッセージを分かりやすく表示** - フィールドごとのエラー
3. **Strong Parameters で入力を制御** - セキュリティ対策

### Turboの活用

1. **Turbo Driveでページ遷移を高速化** - デフォルトで有効
2. **Turbo Framesで部分更新** - ページの一部だけを更新
3. **Turbo Streamsで複数要素を同時更新** - 複雑なUI更新

### Stimulusの設計

1. **小さく再利用可能なコントローラ** - 単一責任
2. **data属性で振る舞いを定義** - HTMLを中心に設計
3. **インラインJavaScriptは避ける** - 保守性向上

## 次のステップ

1. サーバーを起動: `rails server`
2. ブラウザでアクセス: `http://localhost:3000/articles`
3. 記事の一覧、詳細、作成、編集を確認
4. Turboによる高速なページ遷移を体験
5. Stimulusによる動的な操作を確認

次章では、認証と認可の実装に進みます。
