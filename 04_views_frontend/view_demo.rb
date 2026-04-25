# frozen_string_literal: true

# ビュー機能のデモンストレーション
# rails runner view_demo.rb で実行します

puts "=" * 80
puts "ビューとフロントエンド機能のデモンストレーション"
puts "=" * 80
puts ""

puts "このデモでは、以下の機能を確認できます:"
puts "-" * 40
puts ""

puts "1. パーシャル（Partials）:"
puts "   - 記事の表示を再利用可能なパーシャルに抽出"
puts "   - ヘッダー、フッター、フラッシュメッセージの共通化"
puts "   - ローカル変数を使用した依存関係の明示化"
puts ""

puts "2. レイアウト（Layouts）:"
puts "   - application.html.erb でページ全体の構造を管理"
puts "   - content_for を使用したセクションごとのコンテンツ注入"
puts "   - ネストしたレイアウトによる柔軟な構造"
puts ""

puts "3. フォームヘルパー（Form Helpers）:"
puts "   - form_with によるモデルベースのフォーム"
puts "   - バリデーションエラーの自動表示"
puts "   - ネストした属性の処理"
puts ""

puts "4. Turbo:"
puts "   - Turbo Drive による高速なページ遷移"
puts "   - Turbo Frames による部分的な更新"
puts "   - Turbo Streams による複数要素の同時更新"
puts ""

puts "5. Stimulus:"
puts "   - dropdown_controller: ドロップダウンメニュー"
puts "   - autosubmit_controller: 自動送信フォーム"
puts "   - counter_controller: カウンター"
puts "   - form_controller: 動的フォーム"
puts "   - modal_controller: モーダルダイアログ"
puts "   - tabs_controller: タブナビゲーション"
puts "   - flash_controller: フラッシュメッセージ"
puts "   - clipboard_controller: クリップボードコピー"
puts ""

puts "=" * 80
puts "提供されているファイル"
puts "=" * 80
puts ""

puts "■ ビューファイル:"
puts "  views/layouts/"
puts "    - application.html.erb    # 基本レイアウト"
puts "    - admin.html.erb          # 管理画面レイアウト"
puts "  views/shared/"
puts "    - _header.html.erb        # 共通ヘッダー"
puts "    - _footer.html.erb        # 共通フッター"
puts "    - _flash.html.erb         # フラッシュメッセージ"
puts "  views/articles/"
puts "    - index.html.erb          # 記事一覧"
puts "    - show.html.erb           # 記事詳細"
puts "    - new.html.erb            # 新規作成"
puts "    - edit.html.erb           # 編集"
puts "    - _article.html.erb       # 記事パーシャル"
puts "    - _form.html.erb          # フォームパーシャル"
puts "    - create.turbo_stream.erb # 作成時のTurbo Stream"
puts "    - update.turbo_stream.erb # 更新時のTurbo Stream"
puts "    - destroy.turbo_stream.erb # 削除時のTurbo Stream"
puts "  views/comments/"
puts "    - _comment.html.erb       # コメントパーシャル"
puts "  views/admin/"
puts "    - _sidebar.html.erb       # 管理画面サイドバー"
puts ""

puts "■ ヘルパーファイル:"
puts "  helpers/"
puts "    - application_helper.rb   # 共通ヘルパー（エラー表示等）"
puts "    - articles_helper.rb      # 記事用ヘルパー"
puts "    - turbo_helper.rb         # Turbo用ヘルパー"
puts ""

puts "■ Stimulusコントローラ:"
puts "  javascript/"
puts "    - dropdown_controller.js  # ドロップダウンメニュー"
puts "    - autosubmit_controller.js # 自動送信フォーム"
puts "    - counter_controller.js   # カウンター"
puts "    - form_controller.js      # 動的フォーム"
puts "    - modal_controller.js     # モーダルダイアログ"
puts "    - tabs_controller.js      # タブナビゲーション"
puts "    - flash_controller.js     # フラッシュメッセージ"
puts "    - clipboard_controller.js # クリップボードコピー"
puts ""

puts "■ デモスクリプト:"
puts "  - view_demo.rb              # 概要デモ（このファイル）"
puts "  - partial_demo.rb           # パーシャルとレイアウト"
puts "  - form_helper_demo.rb       # フォームヘルパー"
puts "  - turbo_stimulus_demo.rb    # TurboとStimulus"
puts "  - seed_data.rb              # サンプルデータ生成"
puts ""

puts "=" * 80
puts "実装例"
puts "=" * 80
puts ""

puts "パーシャルの使用:"
puts "-" * 40
puts ""

partial_example = <<~ERB
  <%# app/views/articles/index.html.erb %>
  <h1>Articles</h1>

  <%# コレクションをパーシャルに渡す %>
  <%= render @articles %>

  <%# 上記は以下と同等: %>
  <% @articles.each do |article| %>
    <%= render 'article', article: article %>
  <% end %>
ERB

puts partial_example
puts ""

puts "フォームヘルパーの使用:"
puts "-" * 40
puts ""

form_example = <<~ERB
  <%= form_with model: @article do |f| %>
    <%= error_messages_for(@article) %>
  #{"  "}
    <div class="field <%= field_error_class(@article, :title) %>">
      <%= f.label :title %>
      <%= f.text_field :title, class: 'form-control' %>
      <%= field_error_message(@article, :title) %>
    </div>
  #{"  "}
    <div class="field">
      <%= f.label :content %>
      <%= f.text_area :content, class: 'form-control', rows: 10 %>
    </div>
  #{"  "}
    <%= f.submit class: 'btn btn-primary' %>
  <% end %>
ERB

puts form_example
puts ""

puts "Turbo Framesの使用:"
puts "-" * 40
puts ""

turbo_frame_example = <<~ERB
  <%# 記事一覧をTurbo Frameで囲む %>
  <%= turbo_frame_tag "articles" do %>
    <%= render @articles %>
    <%= link_to "Load More", articles_path(page: @next_page) %>
  <% end %>

  <%# 遅延読み込み %>
  <%= turbo_frame_tag "comments",#{" "}
                      src: article_comments_path(@article),#{" "}
                      loading: "lazy" do %>
    <p>Loading comments...</p>
  <% end %>
ERB

puts turbo_frame_example
puts ""

puts "Turbo Streamsの使用:"
puts "-" * 40
puts ""

turbo_stream_example = <<~ERB
  <%# app/views/articles/create.turbo_stream.erb %>
  <%= turbo_stream.prepend "articles", @article %>
  <%= turbo_stream.update "article_count", Article.count %>
  <%= turbo_stream.replace "new_article_form" do %>
    <%= render "form", article: Article.new %>
  <% end %>
ERB

puts turbo_stream_example
puts ""

puts "Stimulusコントローラの使用:"
puts "-" * 40
puts ""

stimulus_example = <<~HTML
  <!-- ドロップダウンメニュー -->
  <div data-controller="dropdown">
    <button data-action="click->dropdown#toggle">Menu</button>
    <div data-dropdown-target="menu" class="hidden">
      <a href="#">Item 1</a>
      <a href="#">Item 2</a>
    </div>
  </div>

  <!-- カウンター -->
  <div data-controller="counter"#{" "}
       data-counter-count-value="0"
       data-counter-min-value="0"
       data-counter-max-value="10">
    <button data-action="click->counter#decrement">-</button>
    <span data-counter-target="display">0</span>
    <button data-action="click->counter#increment">+</button>
  </div>

  <!-- 自動送信フォーム -->
  <form data-controller="autosubmit" data-autosubmit-delay-value="500">
    <input type="text"#{" "}
           data-action="input->autosubmit#submit"
           placeholder="Search...">
  </form>

  <!-- モーダル -->
  <div data-controller="modal">
    <button data-action="click->modal#show">Open Modal</button>
    <div data-modal-target="dialog" class="hidden">
      <div data-modal-target="content">
        <h2>Modal Title</h2>
        <button data-action="click->modal#hide">Close</button>
      </div>
    </div>
  </div>
HTML

puts stimulus_example
puts ""

puts "=" * 80
puts "ベストプラクティス"
puts "=" * 80
puts ""

puts "1. パーシャルの設計:"
puts "   - 再利用可能な単位で分割"
puts "   - ローカル変数を明示的に渡す"
puts "   - 1つのパーシャルは1つの責務に集中"
puts ""

puts "2. フォームの設計:"
puts "   - form_with を標準として使用"
puts "   - エラーメッセージを分かりやすく表示"
puts "   - Strong Parameters で入力を制御"
puts ""

puts "3. Turboの活用:"
puts "   - Turbo Driveでページ遷移を高速化"
puts "   - Turbo Framesで部分更新"
puts "   - Turbo Streamsで複数要素を同時更新"
puts ""

puts "4. Stimulusの設計:"
puts "   - 小さく再利用可能なコントローラを作成"
puts "   - data属性で振る舞いを定義"
puts "   - インラインJavaScriptは避ける"
puts ""

puts "5. パフォーマンス:"
puts "   - 遅延読み込みを活用"
puts "   - キャッシュを適切に使用"
puts "   - 必要な場合のみJavaScriptを読み込む"
puts ""

puts "=" * 80
puts "次のステップ"
puts "=" * 80
puts ""

puts "各デモスクリプトを実行して詳細を確認:"
puts ""
puts "  rails runner partial_demo.rb       # パーシャルとレイアウト"
puts "  rails runner form_helper_demo.rb   # フォームヘルパー"
puts "  rails runner turbo_stimulus_demo.rb # TurboとStimulus"
puts "  rails runner seed_data.rb          # サンプルデータ生成"
puts ""

puts "実際にアプリケーションを起動して確認:"
puts ""
puts "  1. rails server でサーバーを起動"
puts "  2. http://localhost:3000/articles にアクセス"
puts "  3. 記事の一覧、詳細、作成、編集を確認"
puts ""

puts "=" * 80
