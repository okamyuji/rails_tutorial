module ApplicationHelper
  # バリデーションエラーメッセージをまとめて表示する
  def error_messages_for(object)
    return unless object.errors.any?

    content_tag :div, class: "error-messages" do
      content_tag(:h3, "#{pluralize(object.errors.count, 'error')} prohibited this from being saved:") +
      content_tag(:ul) do
        object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join.html_safe
      end
    end
  end

  # フィールドにエラーがあるときのCSSクラスを返す
  def field_error_class(object, field)
    "field-with-errors" if object.errors[field].any?
  end

  # フィールドのエラーメッセージを表示する
  def field_error_message(object, field)
    return unless object.errors[field].any?

    content_tag :span, object.errors[field].first, class: "error"
  end
end
