# frozen_string_literal: true

# TurboとStimulusのデモンストレーション
# rails runner turbo_stimulus_demo.rb で実行します

puts "=" * 80
puts "TurboとStimulusによる動的なインタラクション"
puts "=" * 80
puts ""

puts "1. Turbo Drive"
puts "-" * 40
puts ""

puts "■ 概要:"
puts "  Turbo Driveは、ページ全体をリロードせずにコンテンツを更新します。"
puts "  リンクとフォームを自動的に監視し、AJAXリクエストに変換します。"
puts ""

turbo_drive_example = <<~ERB
  <%# 通常のリンク（Turbo Driveが自動的にAJAX化） %>
  <%= link_to "Articles", articles_path %>

  <%# Turboを無効にしたリンク %>
  <%= link_to "Download PDF", article_path(@article, format: :pdf),#{" "}
              data: { turbo: false } %>

  <%# 特定の方法でページを更新 %>
  <%= link_to "Articles", articles_path,#{" "}
              data: { turbo_action: "replace" } %>
  <%# replace: 履歴に追加せずに置換 %>
  <%# advance: 履歴に追加（デフォルト） %>
ERB

puts turbo_drive_example
puts ""

puts "2. Turbo Frames"
puts "-" * 40
puts ""

puts "■ 概要:"
puts "  Turbo Framesは、ページの特定の部分だけを更新します。"
puts "  frame内のリンクやフォームは、そのframe内のコンテンツのみを更新します。"
puts ""

turbo_frames_example = <<~ERB
  <%# 記事一覧をTurbo Frameで囲む %>
  <%= turbo_frame_tag "articles" do %>
    <%= render @articles %>
  #{"  "}
    <%# このリンクはarticles frameのみを更新 %>
    <%= link_to "Load More", articles_path(page: @next_page) %>
  <% end %>

  <%# 遅延読み込み %>
  <%= turbo_frame_tag "comments", src: article_comments_path(@article), loading: "lazy" do %>
    <p>Loading comments...</p>
  <% end %>

  <%# 別のframeを更新するリンク %>
  <%= link_to "Edit", edit_article_path(@article),#{" "}
              data: { turbo_frame: "modal" } %>

  <%# frameを抜け出すリンク %>
  <%= link_to "View All", articles_path,#{" "}
              data: { turbo_frame: "_top" } %>
ERB

puts turbo_frames_example
puts ""

puts "3. Turbo Streams"
puts "-" * 40
puts ""

puts "■ 概要:"
puts "  Turbo Streamsは、複数の要素を同時に更新できます。"
puts "  サーバーからのレスポンスで、DOMの複数箇所を操作できます。"
puts ""

turbo_streams_example = <<~ERB
  <%# app/views/articles/create.turbo_stream.erb %>

  <%# 記事を先頭に追加 %>
  <%= turbo_stream.prepend "articles" do %>
    <%= render @article %>
  <% end %>

  <%# カウントを更新 %>
  <%= turbo_stream.update "article_count" do %>
    <%= Article.count %>
  <% end %>

  <%# フォームをリセット %>
  <%= turbo_stream.replace "new_article_form" do %>
    <%= render "form", article: Article.new %>
  <% end %>

  <%# フラッシュメッセージを表示 %>
  <%= turbo_stream.prepend "flash_messages" do %>
    <div class="flash-success">Article created!</div>
  <% end %>
ERB

puts turbo_streams_example
puts ""

puts "■ Turbo Streamのアクション:"
puts ""

stream_actions = <<~TEXT
  append   - ターゲットの末尾に追加
  prepend  - ターゲットの先頭に追加
  replace  - ターゲットを置換（要素全体）
  update   - ターゲットの内部コンテンツを更新
  remove   - ターゲットを削除
  before   - ターゲットの前に挿入
  after    - ターゲットの後に挿入
TEXT

puts stream_actions
puts ""

puts "4. Stimulus コントローラ"
puts "-" * 40
puts ""

puts "■ 概要:"
puts "  Stimulusは、HTMLに直接JavaScriptの振る舞いを追加するフレームワークです。"
puts "  コントローラ、アクション、ターゲットの3つの概念で構成されます。"
puts ""

stimulus_basic = <<~JAVASCRIPT
  // app/javascript/controllers/dropdown_controller.js
  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    // ターゲット要素を定義
    static targets = ["menu"]
  #{"  "}
    // 値を定義（HTMLのdata属性から取得）
    static values = {
      open: { type: Boolean, default: false }
    }
  #{"  "}
    // メニューの表示/非表示を切り替え
    toggle() {
      this.menuTarget.classList.toggle("hidden")
    }
  #{"  "}
    // メニューを非表示
    hide(event) {
      if (!this.element.contains(event.target)) {
        this.menuTarget.classList.add("hidden")
      }
    }
  #{"  "}
    // コントローラがDOMに接続されたとき
    connect() {
      document.addEventListener("click", this.hide.bind(this))
    }
  #{"  "}
    // コントローラがDOMから切断されたとき
    disconnect() {
      document.removeEventListener("click", this.hide.bind(this))
    }
  }
JAVASCRIPT

puts stimulus_basic
puts ""

puts "■ HTMLでの使用:"
puts ""

stimulus_html = <<~HTML
  <div data-controller="dropdown">
    <button data-action="click->dropdown#toggle">
      Menu
    </button>
  #{"  "}
    <div data-dropdown-target="menu" class="hidden">
      <a href="#">Item 1</a>
      <a href="#">Item 2</a>
    </div>
  </div>
HTML

puts stimulus_html
puts ""

puts "■ Stimulusの主要な概念:"
puts ""

stimulus_concepts = <<~TEXT
  1. コントローラ (data-controller)
     - 要素にStimulusコントローラを割り当て
     - 例: data-controller="dropdown"

  2. アクション (data-action)
     - イベントとメソッドを結びつけ
     - 形式: イベント->コントローラ#メソッド
     - 例: data-action="click->dropdown#toggle"

  3. ターゲット (data-{controller}-target)
     - コントローラから参照できる要素を定義
     - 例: data-dropdown-target="menu"

  4. 値 (data-{controller}-{name}-value)
     - HTMLからコントローラに値を渡す
     - 例: data-dropdown-open-value="false"

  5. クラス (data-{controller}-{name}-class)
     - CSSクラス名をHTMLで設定
     - 例: data-dropdown-active-class="is-active"
TEXT

puts stimulus_concepts
puts ""

puts "5. 実践的なStimulusコントローラ例"
puts "-" * 40
puts ""

puts "■ 自動送信フォーム:"
puts ""

autosubmit_example = <<~JAVASCRIPT
  // app/javascript/controllers/autosubmit_controller.js
  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    static values = {
      delay: { type: Number, default: 500 }
    }
  #{"  "}
    submit() {
      clearTimeout(this.timeout)
      this.timeout = setTimeout(() => {
        this.element.requestSubmit()
      }, this.delayValue)
    }
  }
JAVASCRIPT

puts autosubmit_example
puts ""

autosubmit_html = <<~ERB
  <%= form_with url: search_path, method: :get,#{" "}
                data: { controller: "autosubmit" } do |f| %>
    <%= f.text_field :q,#{" "}
                     data: { action: "input->autosubmit#submit" },
                     placeholder: "Search..." %>
  <% end %>
ERB

puts autosubmit_html
puts ""

puts "■ カウンター:"
puts ""

counter_example = <<~JAVASCRIPT
  // app/javascript/controllers/counter_controller.js
  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    static targets = ["display"]
    static values = { count: Number }
  #{"  "}
    increment() {
      this.countValue++
    }
  #{"  "}
    decrement() {
      this.countValue--
    }
  #{"  "}
    // 値が変更されると自動的に呼ばれる
    countValueChanged() {
      this.displayTarget.textContent = this.countValue
    }
  }
JAVASCRIPT

puts counter_example
puts ""

counter_html = <<~HTML
  <div data-controller="counter" data-counter-count-value="0">
    <button data-action="click->counter#decrement">-</button>
    <span data-counter-target="display">0</span>
    <button data-action="click->counter#increment">+</button>
  </div>
HTML

puts counter_html
puts ""

puts "6. Importmap"
puts "-" * 40
puts ""

puts "■ 概要:"
puts "  Importmapは、ビルドステップなしでモダンなJavaScriptを使用できる仕組みです。"
puts ""

importmap_example = <<~RUBY
  # config/importmap.rb
  pin "application", preload: true
  pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
  pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
  pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

  # コントローラを一括登録
  pin_all_from "app/javascript/controllers", under: "controllers"

  # 外部ライブラリを追加
  # bin/importmap pin chart.js
RUBY

puts importmap_example
puts ""

puts "=" * 80
puts "ベストプラクティス"
puts "=" * 80
puts ""

puts "1. Turboの使い方:"
puts "   - デフォルトでTurbo Driveを活用"
puts "   - 部分更新にはTurbo Framesを使用"
puts "   - 複数要素の更新にはTurbo Streamsを使用"
puts "   - 必要な場合のみTurboを無効化"
puts ""

puts "2. Stimulusの設計原則:"
puts "   - 小さく、再利用可能なコントローラを作成"
puts "   - HTMLを中心に設計（progressive enhancement）"
puts "   - グローバル状態を避ける"
puts "   - イベントリスナーを適切にクリーンアップ"
puts ""

puts "3. パフォーマンス:"
puts '   - 遅延読み込みを活用（loading="lazy"）'
puts "   - 不要なJavaScriptを避ける"
puts "   - キャッシュを適切に設定"
puts ""

puts "=" * 80
