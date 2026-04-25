# frozen_string_literal: true

# バリデーションのデモンストレーション
# rails runner validation_demo.rb で実行します

puts "=" * 80
puts "バリデーションのデモンストレーション"
puts "=" * 80
puts ""

puts "デモ1: 基本的なバリデーション"
puts "-" * 40
puts ""

puts "正常なユーザーを作成:"
user = User.new(name: "Valid User", email: "valid@example.com", age: 25)
if user.valid?
  puts "✓ バリデーション成功"
  user.save
  puts "✓ ユーザーを保存しました"
else
  puts "✗ バリデーション失敗"
  user.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "名前が空のユーザーを作成:"
user = User.new(name: "", email: "test@example.com", age: 25)
if user.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  user.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "メールアドレスが不正なユーザーを作成:"
user = User.new(name: "Test User", email: "invalid-email", age: 25)
if user.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  user.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "年齢が範囲外のユーザーを作成:"
user = User.new(name: "Test User", email: "test2@example.com", age: 200)
if user.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  user.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "=" * 80
puts "デモ2: 長さのバリデーション"
puts "-" * 40
puts ""

puts "名前が短すぎるユーザー:"
user = User.new(name: "A", email: "test3@example.com")
if user.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  user.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "名前が長すぎるユーザー:"
long_name = "A" * 51
user = User.new(name: long_name, email: "test4@example.com")
if user.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  user.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "=" * 80
puts "デモ3: 一意性のバリデーション"
puts "-" * 40
puts ""

puts "既存のメールアドレスでユーザーを作成:"
existing_user = User.first
if existing_user
  puts "既存ユーザー: #{existing_user.name} (#{existing_user.email})"

  duplicate_user =
    User.new(
      name: "Duplicate User",
      email: existing_user.email # 既存のメールアドレスを使用
    )

  if duplicate_user.valid?
    puts "✓ バリデーション成功"
  else
    puts "✗ バリデーション失敗"
    duplicate_user.errors.full_messages.each { |message| puts "  - #{message}" }
  end
else
  puts "既存のユーザーがありません。先にseed_data.rbを実行してください。"
end
puts ""

puts "=" * 80
puts "デモ4: 記事のバリデーション"
puts "-" * 40
puts ""

user =
  User.first ||
    User.create!(name: "Article Author", email: "author@example.com")

puts "正常な記事を作成:"
article =
  user.articles.new(
    title: "Valid Article Title",
    content: "This is a valid article content with enough text.",
    published: false
  )
if article.valid?
  puts "✓ バリデーション成功"
  article.save
  puts "✓ 記事を保存しました"
else
  puts "✗ バリデーション失敗"
  article.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "タイトルが短すぎる記事:"
article = user.articles.new(title: "Hi", content: "This is content")
if article.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  article.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "本文が短すぎる記事:"
article = user.articles.new(title: "Valid Title Here", content: "Short")
if article.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  article.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "=" * 80
puts "デモ5: 条件付きバリデーション"
puts "-" * 40
puts ""

puts "下書きの記事（published_at不要）:"
article =
  user.articles.new(
    title: "Draft Article",
    content: "This is a draft article content.",
    published: false,
    published_at: nil
  )
if article.valid?
  puts "✓ バリデーション成功"
  article.save
  puts "✓ 下書き記事を保存しました"
else
  puts "✗ バリデーション失敗"
  article.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "公開済みの記事（published_at必須）:"
article =
  user.articles.new(
    title: "Published Article",
    content: "This is a published article content.",
    published: true,
    published_at: nil # 公開済みなのに公開日時がない
  )
if article.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  article.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "公開日時を設定した公開記事:"
article =
  user.articles.new(
    title: "Published Article with Date",
    content: "This is a published article with proper date.",
    published: true,
    published_at: Time.current
  )
if article.valid?
  puts "✓ バリデーション成功"
  article.save
  puts "✓ 公開記事を保存しました"
else
  puts "✗ バリデーション失敗"
  article.errors.full_messages.each { |message| puts "  - #{message}" }
end
puts ""

puts "=" * 80
puts "デモ6: エラーメッセージの詳細"
puts "-" * 40
puts ""

puts "複数のバリデーションエラーがある記事:"
article =
  user.articles.new(
    title: "",
    content: "Hi",
    published: true,
    published_at: nil
  )

if article.valid?
  puts "✓ バリデーション成功"
else
  puts "✗ バリデーション失敗"
  puts ""

  puts "すべてのエラーメッセージ:"
  article.errors.full_messages.each { |message| puts "  - #{message}" }
  puts ""

  puts "属性別のエラー:"
  article.errors.each { |error| puts "  #{error.attribute}: #{error.message}" }
  puts ""

  puts "特定の属性のエラー:"
  if article.errors[:title].any?
    puts "  title:"
    article.errors[:title].each { |message| puts "    - #{message}" }
  end
  if article.errors[:content].any?
    puts "  content:"
    article.errors[:content].each { |message| puts "    - #{message}" }
  end
end
puts ""

puts "=" * 80
puts "まとめ"
puts "=" * 80
puts ""

puts "バリデーションの目的:"
puts "  データの整合性を保証し、不正なデータの保存を防ぎます。"
puts ""

puts "バリデーションの種類:"
puts "  - presence: 値が存在するか"
puts "  - length: 文字列の長さ"
puts "  - format: 正規表現でのパターンマッチ"
puts "  - numericality: 数値の範囲"
puts "  - uniqueness: 一意性"
puts "  - カスタム: 独自のバリデーションロジック"
puts ""

puts "条件付きバリデーション:"
puts "  if/unless オプションで特定の条件でのみバリデーションを実行"
puts ""

puts "エラー処理:"
puts "  - valid?: バリデーションを実行（保存はしない）"
puts "  - errors.full_messages: すべてのエラーメッセージ"
puts "  - errors[:attribute]: 特定の属性のエラー"
puts "  - save: バリデーションが成功した場合のみ保存"
puts "  - save!: バリデーション失敗時に例外を発生"
puts ""

puts "ベストプラクティス:"
puts "  - データベース制約とモデルバリデーションの両方を使用"
puts "  - ユーザーフレンドリーなエラーメッセージを提供"
puts "  - 必要最小限のバリデーションに留める"
puts ""

puts "=" * 80

# クリーンアップ
User.where("email LIKE ?", "%test%@example.com").destroy_all
User.where(email: "valid@example.com").destroy_all
User.where(email: "author@example.com").destroy_all
