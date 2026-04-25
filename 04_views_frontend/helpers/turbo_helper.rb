# frozen_string_literal: true

# TurboHelper
# Turbo関連のヘルパーメソッドを定義します

module TurboHelper
  # Turbo Frameのラッパーを生成
  #
  # @param id [String] フレームID
  # @param options [Hash] オプション
  # @yield ブロック内のコンテンツ
  # @return [String] Turbo Frame HTML
  def turbo_frame_wrapper(id, options = {}, &)
    defaults = { data: { turbo_action: "advance" } }

    turbo_frame_tag(id, defaults.deep_merge(options), &)
  end

  # 遅延読み込み用のTurbo Frameを生成
  #
  # @param id [String] フレームID
  # @param src [String] 読み込み元URL
  # @param loading_text [String] 読み込み中のテキスト
  # @return [String] Turbo Frame HTML
  def lazy_turbo_frame(id, src:, loading_text: "Loading...")
    turbo_frame_tag id, src: src, loading: "lazy" do
      content_tag :div, class: "loading-placeholder" do
        content_tag(:span, loading_text, class: "loading-text") +
          content_tag(:div, "", class: "loading-spinner")
      end
    end
  end

  # Turbo Stream用のフラッシュメッセージを生成
  #
  # @param type [Symbol] メッセージタイプ（:notice, :alert, :success, :error）
  # @param message [String] メッセージ内容
  # @return [String] Turbo Stream HTML
  def turbo_stream_flash(type, message)
    turbo_stream.prepend "flash_messages" do
      render partial: "shared/flash_message",
             locals: {
               type: type,
               message: message
             }
    end
  end

  # Turbo確認ダイアログのdata属性を生成
  #
  # @param message [String] 確認メッセージ
  # @return [Hash] data属性
  def turbo_confirm_data(message)
    { turbo_confirm: message }
  end

  # Turbo無効化のdata属性を生成
  #
  # @return [Hash] data属性
  def turbo_disable_data
    { turbo: false }
  end

  # Turbo Streamアクションのヘルパー
  module StreamActions
    # 要素を追加
    def stream_append(target, content = nil, &)
      turbo_stream.append(target, content, &)
    end

    # 要素を先頭に追加
    def stream_prepend(target, content = nil, &)
      turbo_stream.prepend(target, content, &)
    end

    # 要素を置換
    def stream_replace(target, content = nil, &)
      turbo_stream.replace(target, content, &)
    end

    # 要素を更新（内部コンテンツのみ）
    def stream_update(target, content = nil, &)
      turbo_stream.update(target, content, &)
    end

    # 要素を削除
    def stream_remove(target)
      turbo_stream.remove(target)
    end

    # 要素の前に挿入
    def stream_before(target, content = nil, &)
      turbo_stream.before(target, content, &)
    end

    # 要素の後に挿入
    def stream_after(target, content = nil, &)
      turbo_stream.after(target, content, &)
    end
  end

  include StreamActions
end
