# frozen_string_literal: true

# ApplicationHelper
# ビュー全体で使用できる共通のヘルパーメソッドを定義します

module ApplicationHelper
  # エラーメッセージをまとめて表示
  def error_messages_for(object, options = {})
    return unless object.errors.any?

    title =
      options[:title] ||
        "#{pluralize(object.errors.count, "error")} prohibited this from being saved:"

    content_tag :div, class: "error-messages alert alert-danger" do
      content_tag(:h4, title) +
        content_tag(:ul) do
          object
            .errors
            .full_messages
            .map { |msg| content_tag(:li, msg) }
            .join
            .html_safe
        end
    end
  end

  # フィールドにエラーがある場合のCSSクラスを返す
  def field_error_class(object, field)
    return "" unless object

    "field-with-errors" if object.errors[field].any?
  end

  # フィールドのエラーメッセージを表示
  def field_error_message(object, field)
    return unless object && object.errors[field].any?

    content_tag :span,
                object.errors[field].first,
                class: "error-message text-danger"
  end

  # ページタイトルを設定
  def page_title(title = nil)
    base_title = "My Blog"

    title.present? ? "#{title} | #{base_title}" : base_title
  end

  # アクティブなナビゲーション項目のCSSクラスを返す
  def active_class(path)
    current_page?(path) ? "active" : ""
  end
end
