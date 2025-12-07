# 第4章：ビューの構造化とフロントエンド統合

## 4.1 パーシャルとレイアウトによる再利用設計

### 重複するビューコードを抽出する判断基準

ビューコードの重複は、保守性を低下させる主要な要因です。パーシャルを使用することで、重複を排除し、変更を一箇所で管理できます。

パーシャルは、再利用可能なビューの断片です。アンダースコアで始まるファイル名で定義します。

```erb
<%# app/views/articles/_article.html.erb %>
<div class="article">
  <h2><%= article.title %></h2>
  <p class="author">by <%= article.user.name %></p>
  <div class="content">
    <%= article.content %>
  </div>
  <div class="meta">
    <span><%= article.created_at.strftime('%Y-%m-%d') %></span>
    <span><%= article.comments.count %> comments</span>
  </div>
</div>
```

このパーシャルは、以下のように呼び出します。

```erb
<%# app/views/articles/index.html.erb %>
<h1>Articles</h1>
<%= render @articles %>
```

Railsは、コレクションを渡すと自動的に各要素に対してパーシャルを呼び出します。変数名は、パーシャル名から自動的に決定されます。この例では、`article`変数が各要素に割り当てられます。

パーシャルを作成すべき判断基準を以下に示します。

同じコードが2回以上出現する場合は、パーシャルに抽出すべきです。DRY原則に従い、重複を避けます。

異なるビュー間で共有される要素は、パーシャルに適しています。ヘッダー、フッター、ナビゲーション、フォーム要素などです。

複雑なビューを小さな部品に分解することで、可読性が向上します。1つのビューファイルが100行を超える場合、パーシャルへの分割を検討すべきです。

テストしやすさも重要な判断基準です。パーシャルは独立してテストできるため、ビューのテストが容易になります。

### レイアウトの継承で共通構造を管理する方法

レイアウトは、ページ全体の構造を定義します。すべてのビューで共通のHTML構造を一箇所で管理できます。

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
<head>
  <title><%= content_for?(:title) ? yield(:title) : "My App" %></title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>
</head>
<body>
  <%= render "shared/header" %>
  
  <main class="container">
    <%= render "shared/flash" if flash.any? %>
    <%= yield %>
  </main>
  
  <%= render "shared/footer" %>
</body>
</html>
```

`yield`は、個別のビューコンテンツが挿入される場所を示します。`content_for`を使用すると、レイアウトの特定の領域にコンテンツを注入できます。

```erb
<%# app/views/articles/show.html.erb %>
<% content_for :title do %>
  <%= @article.title %> - My App
<% end %>

<article>
  <h1><%= @article.title %></h1>
  <%= @article.content %>
</article>
```

レイアウトは継承できます。特定のコントローラ用のレイアウトを作成することで、セクションごとに異なるデザインを適用できます。

```ruby
class AdminController < ApplicationController
  layout "admin"
end
```

これにより、`app/views/layouts/admin.html.erb`が使用されます。動的にレイアウトを変更することもできます。

```ruby
class ArticlesController < ApplicationController
  layout :determine_layout

  private

  def determine_layout
    current_user&.admin? ? "admin" : "application"
  end
end
```

ネストしたレイアウトも実装できます。

```erb
<%# app/views/layouts/admin.html.erb %>
<% content_for :content do %>
  <div class="admin-sidebar">
    <%= render "admin/sidebar" %>
  </div>
  <div class="admin-main">
    <%= yield %>
  </div>
<% end %>
<%= render template: "layouts/application" %>
```

この設計により、`application.html.erb`の構造を維持しながら、管理画面専用のレイアウトを追加できます。

### ローカル変数とインスタンス変数の使い分け

パーシャルでは、ローカル変数とインスタンス変数の両方を使用できます。適切に使い分けることで、依存関係が明確になります。

インスタンス変数を直接使用する方法は、シンプルですが依存関係が暗黙的です。

```erb
<%# app/views/articles/_sidebar.html.erb %>
<div class="sidebar">
  <h3><%= @article.title %></h3>
  <p>Related articles...</p>
</div>
```

この実装では、パーシャルがコントローラで設定された`@article`に依存しています。依存関係が明示されていないため、パーシャルの再利用性が低くなります。

ローカル変数を明示的に渡す方法は、依存関係が明確です。

```erb
<%# app/views/articles/show.html.erb %>
<%= render "sidebar", article: @article %>

<%# app/views/articles/_sidebar.html.erb %>
<div class="sidebar">
  <h3><%= article.title %></h3>
  <p>Related articles...</p>
</div>
```

この実装では、パーシャルが`article`ローカル変数に依存していることが明確です。テストやデバッグが容易になります。

デフォルト値を設定することもできます。

```erb
<%# app/views/articles/_sidebar.html.erb %>
<% article ||= @article %>
<div class="sidebar">
  <h3><%= article.title %></h3>
  <p>Related articles...</p>
</div>
```

ただし、この方法は依存関係を曖昧にするため、推奨されません。明示的にローカル変数を渡す方が優れています。

使い分けの原則を以下に示します。

再利用可能なパーシャルは、ローカル変数を使用すべきです。依存関係が明確になり、異なるコンテキストで使用できます。

コントローラ固有のパーシャルは、インスタンス変数を使用しても問題ありません。ただし、明示的なローカル変数の方が望ましいです。

複雑なデータ構造を渡す場合は、ローカル変数を使用します。どのデータがパーシャルで使用されるかが明確になります。

## 4.2 Formヘルパーとバリデーションエラーの表示

### form_withが生成するHTMLの仕組み

`form_with`は、Railsのフォームを構築する標準的な方法です。モデルと連携して、適切なHTMLを生成します。

```erb
<%= form_with model: @article do |f| %>
  <%= f.label :title %>
  <%= f.text_field :title %>
  
  <%= f.label :content %>
  <%= f.text_area :content %>
  
  <%= f.submit %>
<% end %>
```

このコードは、以下のようなHTMLを生成します。

```html
<form action="/articles" method="post" data-turbo="true">
  <input type="hidden" name="authenticity_token" value="...">
  
  <label for="article_title">Title</label>
  <input type="text" name="article[title]" id="article_title">
  
  <label for="article_content">Content</label>
  <textarea name="article[content]" id="article_content"></textarea>
  
  <input type="submit" name="commit" value="Create Article">
</form>
```

`form_with`は、モデルの状態に基づいてフォームを自動設定します。新規レコードの場合はPOSTメソッド、既存レコードの場合はPATCHメソッドを使用します。

```erb
<%# 新規作成フォーム %>
<%= form_with model: Article.new do |f| %>
  <%# POST /articles に送信される %>
<% end %>

<%# 編集フォーム %>
<%= form_with model: @article do |f| %>
  <%# PATCH /articles/:id に送信される %>
<% end %>
```

ネストしたリソースにも対応します。

```erb
<%= form_with model: [@article, @comment] do |f| %>
  <%# POST /articles/:article_id/comments に送信される %>
  <%= f.text_area :content %>
  <%= f.submit %>
<% end %>
```

各フォーム要素は、適切な`name`属性を生成します。これにより、コントローラでStrong Parametersが正しく動作します。

```ruby
# params[:article][:title]
# params[:article][:content]
```

### バリデーションエラーを見やすく表示する実装

バリデーションエラーは、ユーザーにとって分かりやすく表示すべきです。Railsは、モデルのエラー情報をビューで簡単に表示できる仕組みを提供します。

エラーメッセージをまとめて表示する方法を示します。

```erb
<% if @article.errors.any? %>
  <div class="error-messages">
    <h3><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h3>
    <ul>
      <% @article.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

この実装では、すべてのエラーメッセージがリストで表示されます。ユーザーは何を修正すべきか一目で分かります。

フィールドごとにエラーを表示する方法もあります。

```erb
<%= form_with model: @article do |f| %>
  <div class="field <%= 'field-with-errors' if @article.errors[:title].any? %>">
    <%= f.label :title %>
    <%= f.text_field :title %>
    <% if @article.errors[:title].any? %>
      <span class="error"><%= @article.errors[:title].first %></span>
    <% end %>
  </div>
  
  <div class="field <%= 'field-with-errors' if @article.errors[:content].any? %>">
    <%= f.label :content %>
    <%= f.text_area :content %>
    <% if @article.errors[:content].any? %>
      <span class="error"><%= @article.errors[:content].first %></span>
    <% end %>
  </div>
  
  <%= f.submit %>
<% end %>
```

この実装では、各フィールドの下に個別のエラーメッセージが表示されます。ユーザーは該当するフィールドで直接エラーを確認できます。

エラー表示をヘルパーメソッドに抽出することで、再利用性が向上します。

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def error_messages_for(object)
    return unless object.errors.any?
    
    content_tag :div, class: 'error-messages' do
      content_tag(:h3, "#{pluralize(object.errors.count, 'error')} prohibited this from being saved:") +
      content_tag(:ul) do
        object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join.html_safe
      end
    end
  end
  
  def field_error_class(object, field)
    'field-with-errors' if object.errors[field].any?
  end
  
  def field_error_message(object, field)
    return unless object.errors[field].any?
    
    content_tag :span, object.errors[field].first, class: 'error'
  end
end
```

ビューでの使用例を示します。

```erb
<%= error_messages_for(@article) %>

<%= form_with model: @article do |f| %>
  <div class="field <%= field_error_class(@article, :title) %>">
    <%= f.label :title %>
    <%= f.text_field :title %>
    <%= field_error_message(@article, :title) %>
  </div>
  
  <%= f.submit %>
<% end %>
```

### 複数のモデルを扱うフォームの構築

1つのフォームで複数のモデルを扱う場合、`accepts_nested_attributes_for`を使用します。

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank
end
```

フォームでネストした属性を扱います。

```erb
<%= form_with model: @article do |f| %>
  <%= f.label :title %>
  <%= f.text_field :title %>
  
  <%= f.label :content %>
  <%= f.text_area :content %>
  
  <h3>Images</h3>
  <%= f.fields_for :images do |image_form| %>
    <div class="nested-fields">
      <%= image_form.label :url %>
      <%= image_form.text_field :url %>
      
      <%= image_form.label :caption %>
      <%= image_form.text_field :caption %>
      
      <%= image_form.check_box :_destroy %>
      <%= image_form.label :_destroy, "Remove" %>
    </div>
  <% end %>
  
  <%= f.submit %>
<% end %>
```

コントローラでStrong Parametersを適切に設定します。

```ruby
def article_params
  params.require(:article).permit(
    :title,
    :content,
    images_attributes: [:id, :url, :caption, :_destroy]
  )
end
```

`_destroy`パラメータにより、チェックボックスで関連レコードを削除できます。JavaScriptと組み合わせることで、動的にフィールドを追加・削除できます。

## 4.3 TurboとStimulusによる動的なインタラクション

### Turboで画面遷移を高速化する仕組み

Turboは、ページ全体をリロードせずにコンテンツを更新する技術です。ユーザーエクスペリエンスが大幅に向上します。

Turbo Driveは、リンクとフォームを自動的に監視し、AJAXリクエストに変換します。レスポンスのHTMLで現在のページを置き換えます。

```erb
<%= link_to "Articles", articles_path %>
<%# 通常のリンクだが、Turbo Driveが自動的にAJAX化する %>
```

特定のリンクでTurboを無効化する場合は、`data-turbo="false"`を指定します。

```erb
<%= link_to "Download PDF", article_path(@article, format: :pdf), data: { turbo: false } %>
```

Turbo Framesは、ページの特定の部分だけを更新します。

```erb
<%# app/views/articles/index.html.erb %>
<%= turbo_frame_tag "articles" do %>
  <%= render @articles %>
  <%= link_to "Load More", articles_path(page: @next_page) %>
<% end %>
```

`link_to`がTurbo Frame内にある場合、そのフレームだけが更新されます。ページの他の部分は影響を受けません。

Turbo Streamsは、複数の要素を同時に更新できます。

```erb
<%# app/views/articles/create.turbo_stream.erb %>
<%= turbo_stream.prepend "articles", @article %>
<%= turbo_stream.update "article_count", Article.count %>
<%= turbo_stream.replace "new_article_form", partial: "form", locals: { article: Article.new } %>
```

このレスポンスは、3つの異なる要素を同時に更新します。記事を先頭に追加し、カウントを更新し、フォームをリセットします。

### Stimulusコントローラで再利用可能なJavaScriptを書く

Stimulusは、HTMLに直接JavaScriptの振る舞いを追加するフレームワークです。コントローラ、アクション、ターゲットの3つの概念で構成されます。

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
  
  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
```

HTMLで使用します。

```erb
<div data-controller="dropdown">
  <button data-action="click->dropdown#toggle">
    Menu
  </button>
  
  <div data-dropdown-target="menu" class="hidden">
    <a href="#">Item 1</a>
    <a href="#">Item 2</a>
  </div>
</div>
```

`data-controller`は、要素にStimulusコントローラを割り当てます。`data-action`は、イベントとアクションを結びつけます。`data-{controller}-target`は、コントローラから参照できる要素を定義します。

フォームの自動送信を実装する例を示します。

```javascript
// app/javascript/controllers/autosubmit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 500)
  }
}
```

検索フォームで使用します。

```erb
<%= form_with url: search_path, method: :get, data: { controller: "autosubmit" } do |f| %>
  <%= f.text_field :q, data: { action: "input->autosubmit#submit" } %>
<% end %>
```

ユーザーが入力を停止してから500ミリ秒後に、フォームが自動送信されます。リアルタイム検索のユーザーエクスペリエンスを提供します。

Stimulusコントローラは、値を持つことができます。

```javascript
// app/javascript/controllers/counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { count: Number }
  
  increment() {
    this.countValue++
  }
  
  countValueChanged() {
    this.element.textContent = this.countValue
  }
}
```

```erb
<div data-controller="counter" data-counter-count-value="0">
  <button data-action="click->counter#increment">+1</button>
  <span>0</span>
</div>
```

値が変更されると、`{value}ValueChanged`メソッドが自動的に呼ばれます。リアクティブな動作を簡潔に実装できます。

### ImportmapによるJavaScript管理の最適化

Importmapは、ビルドステップなしでモダンなJavaScriptを使用できる仕組みです。npmパッケージをCDN経由で読み込みます。

```ruby
# config/importmap.rb
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin_all_from "app/javascript/controllers", under: "controllers"
```

JavaScriptファイルで直接インポートできます。

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"
```

外部ライブラリを追加する場合は、`bin/importmap`コマンドを使用します。

```bash
bin/importmap pin chart.js
```

これにより、`config/importmap.rb`に設定が追加され、CDN経由でライブラリが読み込まれます。

Importmapの利点は、ビルドステップが不要なことです。JavaScriptの変更が即座に反映されます。開発体験が向上します。

複雑なフロントエンドを構築する場合は、esbuildやWebpackなどのバンドラーを検討すべきです。ただし、多くのRailsアプリケーションでは、Importmapで十分です。

## まとめ

この章では、ビューの構造化とフロントエンド統合について学びました。

パーシャルとレイアウトにより、ビューコードの重複を排除し、保守性を向上させます。ローカル変数を明示的に渡すことで、依存関係が明確になります。レイアウトの継承により、共通構造を効率的に管理できます。

Formヘルパーは、モデルと連携して適切なHTMLを生成します。バリデーションエラーを分かりやすく表示することで、ユーザーエクスペリエンスが向上します。ネストした属性により、1つのフォームで複数のモデルを扱えます。

TurboとStimulusは、モダンなインタラクションを実現します。Turboでページ遷移を高速化し、Stimulusで再利用可能なJavaScriptを構築します。Importmapにより、ビルドステップなしでモダンなJavaScriptが使用できます。

次章では、認証と認可の実装について学びます。Deviseによるユーザー認証、Punditによる権限管理、セキュリティのベストプラクティスを習得します。
