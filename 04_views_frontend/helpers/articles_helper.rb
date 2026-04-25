# frozen_string_literal: true

# ArticlesHelper
# 記事関連のビューで使用するヘルパーメソッドを定義します

module ArticlesHelper
  # 記事のステータスバッジを生成
  #
  # @param article [Article] 記事オブジェクト
  # @return [String] HTMLのバッジ要素
  def article_status_badge(article)
    if article.published?
      content_tag :span, class: "badge badge-success" do
        concat(
          content_tag(
            :svg,
            class: "badge-icon",
            fill: "none",
            stroke: "currentColor",
            viewBox: "0 0 24 24"
          ) do
            tag.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: "M5 13l4 4L19 7"
            )
          end
        )
        concat(" Published")
      end
    else
      content_tag :span, class: "badge badge-secondary" do
        concat(
          content_tag(
            :svg,
            class: "badge-icon",
            fill: "none",
            stroke: "currentColor",
            viewBox: "0 0 24 24"
          ) do
            edit_path =
              "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5" \
                "m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
            tag.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: edit_path
            )
          end
        )
        concat(" Draft")
      end
    end
  end

  # 記事の要約を生成
  #
  # @param article [Article] 記事オブジェクト
  # @param length [Integer] 最大文字数（デフォルト: 200）
  # @return [String] 要約テキスト
  def article_summary(article, length: 200)
    truncate(strip_tags(article.content), length: length, omission: "...")
  end

  # 記事の読了時間を計算
  #
  # @param article [Article] 記事オブジェクト
  # @param words_per_minute [Integer] 1分あたりの読む単語数（デフォルト: 200）
  # @return [String] 読了時間の文字列
  def reading_time(article, words_per_minute: 200)
    words = article.content.split.size
    minutes = (words.to_f / words_per_minute).ceil

    if minutes < 1
      "Less than 1 min read"
    elsif minutes == 1
      "1 min read"
    else
      "#{minutes} min read"
    end
  end

  # 記事の公開日をフォーマット
  #
  # @param article [Article] 記事オブジェクト
  # @param format [Symbol] 日付フォーマット（:short, :long, :relative）
  # @return [String] フォーマットされた日付
  def formatted_publish_date(article, format: :long)
    date = article.published_at || article.created_at

    case format
    when :short
      date.strftime("%Y-%m-%d")
    when :long
      date.strftime("%B %d, %Y")
    when :relative
      "#{time_ago_in_words(date)} ago"
    else
      date.to_s
    end
  end

  # 記事のソートオプションを生成
  #
  # @return [Array<Array>] select用のオプション配列
  def article_sort_options
    [
      ["Newest First", "newest"],
      ["Oldest First", "oldest"],
      ["Most Comments", "popular"],
      %w[A-Z title_asc],
      %w[Z-A title_desc]
    ]
  end

  # 記事のフィルターオプションを生成
  #
  # @return [Array<Array>] select用のオプション配列
  def article_filter_options
    [["All Articles", ""], %w[Published published], %w[Drafts draft]]
  end

  # 記事のカードクラスを生成
  #
  # @param article [Article] 記事オブジェクト
  # @return [String] CSSクラス文字列
  def article_card_class(article)
    classes = ["article-card"]
    classes << "article-card--published" if article.published?
    classes << "article-card--draft" unless article.published?
    if article.respond_to?(:featured?) && article.featured?
      classes << "article-card--featured"
    end
    classes.join(" ")
  end

  # 記事のシェアURLを生成
  #
  # @param article [Article] 記事オブジェクト
  # @param platform [Symbol] SNSプラットフォーム
  # @return [String] シェアURL
  def share_url(article, platform)
    article_url = url_for(article)
    title = CGI.escape(article.title)

    case platform
    when :twitter
      "https://twitter.com/intent/tweet?text=#{title}&url=#{article_url}"
    when :facebook
      "https://www.facebook.com/sharer/sharer.php?u=#{article_url}"
    when :linkedin
      "https://www.linkedin.com/shareArticle?mini=true&url=#{article_url}&title=#{title}"
    when :email
      "mailto:?subject=#{title}&body=#{article_url}"
    else
      article_url
    end
  end

  # 記事のメタタグを生成
  #
  # @param article [Article] 記事オブジェクト
  # @return [String] メタタグHTML
  def article_meta_tags(article)
    tags = []

    # 基本的なメタタグ
    tags << tag.meta(
      name: "description",
      content: article_summary(article, length: 160)
    )
    tags << tag.meta(name: "author", content: article.user.name)

    # Open Graph タグ
    tags << tag.meta(property: "og:title", content: article.title)
    tags << tag.meta(
      property: "og:description",
      content: article_summary(article, length: 160)
    )
    tags << tag.meta(property: "og:type", content: "article")
    tags << tag.meta(property: "og:url", content: url_for(article))

    # Twitter Card タグ
    tags << tag.meta(name: "twitter:card", content: "summary")
    tags << tag.meta(name: "twitter:title", content: article.title)
    tags << tag.meta(
      name: "twitter:description",
      content: article_summary(article, length: 160)
    )

    safe_join(tags)
  end

  # 前後の記事へのナビゲーションリンクを生成
  #
  # @param article [Article] 現在の記事
  # @return [Hash] prev/nextのリンク情報
  def article_navigation(article)
    {
      prev:
        Article
          .where("created_at < ?", article.created_at)
          .order(created_at: :desc)
          .first,
      next:
        Article
          .where("created_at > ?", article.created_at)
          .order(created_at: :asc)
          .first
    }
  end
end
