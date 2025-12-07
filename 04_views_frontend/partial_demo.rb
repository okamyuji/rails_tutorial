# frozen_string_literal: true

# パーシャルとレイアウトのデモンストレーション
# rails runner partial_demo.rb で実行します

puts '=' * 80
puts 'パーシャルとレイアウトのデモンストレーション'
puts '=' * 80
puts ''

puts 'このデモでは、以下の機能を確認できます:'
puts '-' * 40
puts ''

puts '1. パーシャルの基本的な使い方'
puts '-' * 40
puts ''

puts '■ パーシャルの命名規則:'
puts '  - ファイル名はアンダースコアで始まる: _article.html.erb'
puts '  - 呼び出し時はアンダースコアを省略: render "article"'
puts ''

puts '■ パーシャルの呼び出し方法:'
puts ''

partial_examples = <<~RUBY
# 1. 単一オブジェクトをレンダリング
<%= render @article %>
# → app/views/articles/_article.html.erb を使用
# → ローカル変数 article に @article が渡される

# 2. コレクションをレンダリング
<%= render @articles %>
# → 各記事に対して _article.html.erb をレンダリング
# → 自動的にローカル変数 article が各要素に設定される

# 3. 明示的にパーシャルを指定
<%= render partial: "articles/article", locals: { article: @article } %>

# 4. コレクションを明示的に指定
<%= render partial: "articles/article", collection: @articles %>

# 5. ローカル変数名を変更
<%= render partial: "articles/article", collection: @articles, as: :post %>
# → ローカル変数 post として各要素にアクセス

# 6. 空の場合のフォールバック
<%= render @articles || "No articles found" %>

# 7. カウンターを使用
<%= render partial: "articles/article", collection: @articles, counter: :article_counter %>
# → article_counter でインデックスにアクセス可能
RUBY

puts partial_examples
puts ''

puts '2. ローカル変数とインスタンス変数の使い分け'
puts '-' * 40
puts ''

puts '■ 推奨: ローカル変数を明示的に渡す'
puts ''

local_var_example = <<~ERB
<%# 呼び出し側 %>
<%= render "sidebar", article: @article, show_actions: true %>

<%# パーシャル側 (_sidebar.html.erb) %>
<div class="sidebar">
  <h3><%= article.title %></h3>
  <% if show_actions %>
    <%= link_to "Edit", edit_article_path(article) %>
  <% end %>
</div>
ERB

puts local_var_example
puts ''

puts '■ 非推奨: インスタンス変数を直接使用'
puts ''

instance_var_example = <<~ERB
<%# パーシャル側 - 依存関係が不明確 %>
<div class="sidebar">
  <h3><%= @article.title %></h3>  <%# どこから来たのか分からない %>
</div>
ERB

puts instance_var_example
puts ''

puts '3. レイアウトの継承'
puts '-' * 40
puts ''

puts '■ 基本的なレイアウト構造:'
puts ''

layout_example = <<~ERB
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
<head>
  <title><%= content_for?(:title) ? yield(:title) : "My App" %></title>
  <%= csrf_meta_tags %>
  <%= stylesheet_link_tag "application" %>
  <%= javascript_importmap_tags %>
</head>
<body>
  <%= render "shared/header" %>
  
  <main class="container">
    <%= yield %>  <%# ここに個別ページのコンテンツが挿入される %>
  </main>
  
  <%= render "shared/footer" %>
</body>
</html>
ERB

puts layout_example
puts ''

puts '■ content_for の使用:'
puts ''

content_for_example = <<~ERB
<%# app/views/articles/show.html.erb %>
<% content_for :title do %>
  <%= @article.title %> - My App
<% end %>

<% content_for :sidebar do %>
  <%= render "sidebar", article: @article %>
<% end %>

<article>
  <h1><%= @article.title %></h1>
  <%= @article.content %>
</article>

<%# レイアウト側で yield :sidebar として表示 %>
ERB

puts content_for_example
puts ''

puts '■ レイアウトの継承（ネスト）:'
puts ''

nested_layout_example = <<~ERB
<%# app/views/layouts/admin.html.erb %>
<% content_for :content do %>
  <div class="admin-layout">
    <aside class="sidebar">
      <%= render "admin/sidebar" %>
    </aside>
    <main class="main-content">
      <%= yield %>
    </main>
  </div>
<% end %>

<%# applicationレイアウトを継承 %>
<%= render template: "layouts/application" %>
ERB

puts nested_layout_example
puts ''

puts '4. コントローラでのレイアウト指定'
puts '-' * 40
puts ''

controller_layout_example = <<~RUBY
# 固定のレイアウトを指定
class AdminController < ApplicationController
  layout "admin"
end

# 動的にレイアウトを決定
class ArticlesController < ApplicationController
  layout :determine_layout
  
  private
  
  def determine_layout
    current_user&.admin? ? "admin" : "application"
  end
end

# アクションごとにレイアウトを変更
class ArticlesController < ApplicationController
  layout "application"
  layout "print", only: [:print]
  
  def print
    # printアクションでは "print" レイアウトを使用
  end
end

# レイアウトを使用しない
class Api::ArticlesController < ApplicationController
  layout false  # または layout nil
end
RUBY

puts controller_layout_example
puts ''

puts '=' * 80
puts 'ベストプラクティス'
puts '=' * 80
puts ''

puts '1. パーシャルの設計原則:'
puts '   - 単一責任: 1つのパーシャルは1つの目的に集中'
puts '   - 再利用性: 異なるコンテキストで使用可能に設計'
puts '   - 明示的な依存関係: ローカル変数で依存を明確化'
puts '   - 適切な粒度: 大きすぎず、小さすぎず'
puts ''

puts '2. パーシャル抽出の判断基準:'
puts '   - 同じコードが2回以上出現する'
puts '   - 複数のビューで共有される要素'
puts '   - ビューファイルが100行を超える'
puts '   - テストを容易にしたい部分'
puts ''

puts '3. レイアウトの設計原則:'
puts '   - 共通要素の集約: ヘッダー、フッター、ナビゲーション'
puts '   - 柔軟な拡張ポイント: content_for で個別ページから注入可能に'
puts '   - セマンティックなHTML: アクセシビリティを考慮'
puts ''

puts '=' * 80
puts 'ディレクトリ構造の例'
puts '=' * 80
puts ''

directory_structure = <<~TEXT
app/views/
├── layouts/
│   ├── application.html.erb    # 基本レイアウト
│   ├── admin.html.erb          # 管理画面レイアウト
│   └── mailer.html.erb         # メール用レイアウト
├── shared/
│   ├── _header.html.erb        # 共通ヘッダー
│   ├── _footer.html.erb        # 共通フッター
│   ├── _flash.html.erb         # フラッシュメッセージ
│   └── _sidebar.html.erb       # 共通サイドバー
├── articles/
│   ├── index.html.erb          # 一覧ページ
│   ├── show.html.erb           # 詳細ページ
│   ├── new.html.erb            # 新規作成ページ
│   ├── edit.html.erb           # 編集ページ
│   ├── _article.html.erb       # 記事パーシャル
│   ├── _form.html.erb          # フォームパーシャル
│   └── _sidebar.html.erb       # 記事固有のサイドバー
└── admin/
    └── _sidebar.html.erb       # 管理画面サイドバー
TEXT

puts directory_structure
puts ''

puts '=' * 80

