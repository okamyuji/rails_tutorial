# frozen_string_literal: true

# フォームヘルパーとバリデーションエラー表示のデモンストレーション
# rails runner form_helper_demo.rb で実行します

puts "=" * 80
puts "フォームヘルパーとバリデーションエラー表示のデモンストレーション"
puts "=" * 80
puts ""

puts "1. form_with の基本的な使い方"
puts "-" * 40
puts ""

puts "■ モデルベースのフォーム:"
puts ""

model_form_example = <<~ERB
  <%# 新規作成フォーム（POST /articles） %>
  <%= form_with model: @article do |f| %>
    <%= f.label :title %>
    <%= f.text_field :title %>
  #{"  "}
    <%= f.label :content %>
    <%= f.text_area :content %>
  #{"  "}
    <%= f.submit %>
  <% end %>

  <%# 編集フォーム（PATCH /articles/:id） %>
  <%# form_with は自動的にHTTPメソッドを判断 %>
  <%= form_with model: @article do |f| %>
    <%# @article.persisted? の場合は PATCH %>
  <% end %>
ERB

puts model_form_example
puts ""

puts "■ 生成されるHTML:"
puts ""

generated_html = <<~HTML
  <form action="/articles" method="post" data-turbo="true">
    <input type="hidden" name="authenticity_token" value="...">
  #{"  "}
    <label for="article_title">Title</label>
    <input type="text" name="article[title]" id="article_title">
  #{"  "}
    <label for="article_content">Content</label>
    <textarea name="article[content]" id="article_content"></textarea>
  #{"  "}
    <input type="submit" name="commit" value="Create Article">
  </form>
HTML

puts generated_html
puts ""

puts "2. 様々なフォーム要素"
puts "-" * 40
puts ""

form_elements = <<~ERB
  <%= form_with model: @article do |f| %>
    <%# テキストフィールド %>
    <%= f.text_field :title, class: "form-control", placeholder: "Enter title" %>
  #{"  "}
    <%# テキストエリア %>
    <%= f.text_area :content, rows: 10, cols: 50 %>
  #{"  "}
    <%# パスワードフィールド %>
    <%= f.password_field :password %>
  #{"  "}
    <%# メールフィールド %>
    <%= f.email_field :email %>
  #{"  "}
    <%# 数値フィールド %>
    <%= f.number_field :price, min: 0, max: 1000, step: 0.01 %>
  #{"  "}
    <%# 日付フィールド %>
    <%= f.date_field :published_at %>
  #{"  "}
    <%# チェックボックス %>
    <%= f.check_box :published %>
    <%= f.label :published, "Publish this article" %>
  #{"  "}
    <%# ラジオボタン %>
    <%= f.radio_button :status, "draft" %>
    <%= f.label :status_draft, "Draft" %>
    <%= f.radio_button :status, "published" %>
    <%= f.label :status_published, "Published" %>
  #{"  "}
    <%# セレクトボックス %>
    <%= f.select :category_id, Category.all.collect { |c| [c.name, c.id] },#{" "}
                 { include_blank: "Select category" },#{" "}
                 { class: "form-select" } %>
  #{"  "}
    <%# コレクションセレクト %>
    <%= f.collection_select :user_id, User.all, :id, :name,#{" "}
                            { prompt: "Select author" } %>
  #{"  "}
    <%# 隠しフィールド %>
    <%= f.hidden_field :user_id, value: current_user.id %>
  #{"  "}
    <%# ファイルアップロード %>
    <%= f.file_field :image, accept: "image/*" %>
  #{"  "}
    <%# 送信ボタン %>
    <%= f.submit "Save", class: "btn btn-primary", data: { disable_with: "Saving..." } %>
  <% end %>
ERB

puts form_elements
puts ""

puts "3. バリデーションエラーの表示"
puts "-" * 40
puts ""

puts "■ エラーメッセージをまとめて表示:"
puts ""

error_summary = <<~ERB
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
ERB

puts error_summary
puts ""

puts "■ フィールドごとにエラーを表示:"
puts ""

field_errors = <<~ERB
  <%= form_with model: @article do |f| %>
    <div class="field <%= 'field-with-errors' if @article.errors[:title].any? %>">
      <%= f.label :title %>
      <%= f.text_field :title %>
      <% if @article.errors[:title].any? %>
        <span class="error-message"><%= @article.errors[:title].first %></span>
      <% end %>
    </div>
  <% end %>
ERB

puts field_errors
puts ""

puts "■ ヘルパーメソッドを使用:"
puts ""

helper_methods = <<~RUBY
  # app/helpers/application_helper.rb
  module ApplicationHelper
    def error_messages_for(object)
      return unless object.errors.any?
  #{"    "}
      content_tag :div, class: 'error-messages' do
        content_tag(:h3, "\#{pluralize(object.errors.count, 'error')} prohibited this from being saved:") +
        content_tag(:ul) do
          object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join.html_safe
        end
      end
    end
  #{"  "}
    def field_error_class(object, field)
      'field-with-errors' if object.errors[field].any?
    end
  #{"  "}
    def field_error_message(object, field)
      return unless object.errors[field].any?
      content_tag :span, object.errors[field].first, class: 'error-message'
    end
  end
RUBY

puts helper_methods
puts ""

puts "■ ヘルパーを使用したフォーム:"
puts ""

form_with_helpers = <<~ERB
  <%= error_messages_for(@article) %>

  <%= form_with model: @article do |f| %>
    <div class="field <%= field_error_class(@article, :title) %>">
      <%= f.label :title %>
      <%= f.text_field :title %>
      <%= field_error_message(@article, :title) %>
    </div>
  #{"  "}
    <%= f.submit %>
  <% end %>
ERB

puts form_with_helpers
puts ""

puts "4. ネストした属性（accepts_nested_attributes_for）"
puts "-" * 40
puts ""

puts "■ モデルの設定:"
puts ""

nested_model = <<~RUBY
  # app/models/article.rb
  class Article < ApplicationRecord
    has_many :images, dependent: :destroy
    accepts_nested_attributes_for :images,#{" "}
                                  allow_destroy: true,
                                  reject_if: :all_blank
  end

  # app/models/image.rb
  class Image < ApplicationRecord
    belongs_to :article
    validates :url, presence: true
  end
RUBY

puts nested_model
puts ""

puts "■ フォームの実装:"
puts ""

nested_form = <<~ERB
  <%= form_with model: @article do |f| %>
    <%= f.text_field :title %>
    <%= f.text_area :content %>
  #{"  "}
    <h3>Images</h3>
    <%= f.fields_for :images do |image_form| %>
      <div class="nested-fields">
        <%= image_form.text_field :url, placeholder: "Image URL" %>
        <%= image_form.text_field :caption, placeholder: "Caption" %>
        <%= image_form.check_box :_destroy %>
        <%= image_form.label :_destroy, "Remove" %>
      </div>
    <% end %>
  #{"  "}
    <%= f.submit %>
  <% end %>
ERB

puts nested_form
puts ""

puts "■ コントローラのStrong Parameters:"
puts ""

strong_params = <<~RUBY
  # app/controllers/articles_controller.rb
  def article_params
    params.require(:article).permit(
      :title,
      :content,
      images_attributes: [:id, :url, :caption, :_destroy]
    )
  end
RUBY

puts strong_params
puts ""

puts "5. Turboとの統合"
puts "-" * 40
puts ""

turbo_form = <<~ERB
  <%# Turboを有効にしたフォーム（デフォルト） %>
  <%= form_with model: @article do |f| %>
    <%# Turbo Driveがフォーム送信を処理 %>
  <% end %>

  <%# Turboを無効にしたフォーム %>
  <%= form_with model: @article, data: { turbo: false } do |f| %>
    <%# 通常のフォーム送信 %>
  <% end %>

  <%# Turbo Frameを指定 %>
  <%= form_with model: @article, data: { turbo_frame: "articles" } do |f| %>
    <%# レスポンスは指定したTurbo Frameを更新 %>
  <% end %>

  <%# 確認ダイアログを表示 %>
  <%= form_with model: @article, data: { turbo_confirm: "Are you sure?" } do |f| %>
  <% end %>
ERB

puts turbo_form
puts ""

puts "=" * 80
puts "ベストプラクティス"
puts "=" * 80
puts ""

puts "1. フォームの設計:"
puts "   - form_with を標準として使用"
puts "   - モデルベースのフォームを優先"
puts "   - 適切なHTMLセマンティクスを使用"
puts ""

puts "2. エラー表示:"
puts "   - ユーザーフレンドリーなメッセージを提供"
puts "   - フィールドごとのエラー表示を実装"
puts "   - エラー時にフォームの入力値を保持"
puts ""

puts "3. アクセシビリティ:"
puts "   - label要素を適切に使用"
puts "   - aria属性でエラー状態を伝達"
puts "   - フォーカス管理を適切に行う"
puts ""

puts "4. セキュリティ:"
puts "   - CSRFトークンを含める（自動）"
puts "   - Strong Parametersで入力を制限"
puts "   - 適切なバリデーションを実装"
puts ""

puts "=" * 80
