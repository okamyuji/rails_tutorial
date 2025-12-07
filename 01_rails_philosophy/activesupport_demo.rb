# frozen_string_literal: true

# このスクリプトは、ActiveSupportが提供する便利なメソッドを
# デモンストレーションします。RailsがどのようにRubyを拡張して
# いるかを理解できます。

puts "=" * 80
puts "ActiveSupport デモンストレーション"
puts "=" * 80
puts ""

# セクション1：日付と時刻の操作
puts "1. 日付と時刻の操作"
puts "-" * 40
puts ""

current_time = Time.current
puts "現在時刻: #{current_time}"
puts ""

puts "7日後: #{7.days.from_now}"
puts "2週間前: #{2.weeks.ago}"
puts "3ヶ月後: #{3.months.since(current_time)}"
puts "1年前: #{1.year.ago}"
puts ""

puts "より複雑な計算も可能です"
puts "2週間と3日後: #{(2.weeks + 3.days).from_now}"
puts "1ヶ月と15日前: #{(1.month + 15.days).ago}"
puts ""

# セクション2：文字列の変換
puts "2. 文字列の変換"
puts "-" * 40
puts ""

test_string = "user_name"
puts "元の文字列: #{test_string}"
puts "キャメルケース: #{test_string.camelize}"
puts "パスカルケース: #{test_string.camelize(:lower)}"
puts ""

test_string2 = "UserName"
puts "元の文字列: #{test_string2}"
puts "スネークケース: #{test_string2.underscore}"
puts ""

# セクション3：複数形と単数形
puts "3. 複数形と単数形の変換"
puts "-" * 40
puts ""

words = ["person", "child", "mouse", "ox", "sheep", "fish", "user"]
words.each do |word|
  puts "#{word.ljust(10)} → #{word.pluralize}"
end
puts ""

plural_words = ["people", "children", "mice", "oxen", "sheep", "fish", "users"]
plural_words.each do |word|
  puts "#{word.ljust(10)} → #{word.singularize}"
end
puts ""

# セクション4：文字列の人間向け表現
puts "4. 文字列の人間向け表現"
puts "-" * 40
puts ""

puts "user_name → #{('user_name').humanize}"
puts "employee_salary → #{('employee_salary').humanize}"
puts "author_id → #{('author_id').humanize}"
puts ""

puts "タイトル化:"
puts "hello world → #{('hello world').titleize}"
puts "the lord of the rings → #{('the lord of the rings').titleize}"
puts ""

# セクション5：blank?とpresent?
puts "5. blank? と present? の使用"
puts "-" * 40
puts ""

test_values = [nil, "", "   ", "text", [], [1, 2], {}, {key: "value"}]
test_values.each do |value|
  value_str = value.inspect.ljust(20)
  puts "#{value_str} blank?: #{value.blank?.to_s.ljust(5)} present?: #{value.present?}"
end
puts ""

puts "blank? は nil、空文字、空白文字のみ、空の配列、空のハッシュで true を返します"
puts "present? は blank? の逆です"
puts ""

# セクション6：数値の便利なメソッド
puts "6. 数値の便利なメソッド"
puts "-" * 40
puts ""

puts "1024バイト = #{1024.bytes} バイト"
puts "5キロバイト = #{5.kilobytes} バイト"
puts "2メガバイト = #{2.megabytes} バイト"
puts ""

puts "複数形チェック:"
puts "1.zero? = #{1.zero?}"
puts "0.zero? = #{0.zero?}"
puts "5.positive? = #{5.positive?}"
puts "(-3).negative? = #{(-3).negative?}"
puts ""

# セクション7：配列の便利なメソッド
puts "7. 配列の便利なメソッド"
puts "-" * 40
puts ""

array = [1, 2, 3, 4, 5]
puts "元の配列: #{array.inspect}"
puts ""

puts "最初の要素から2つ: #{array.first(2).inspect}"
puts "最後の要素から3つ: #{array.last(3).inspect}"
puts "2番目の要素: #{array.second}"
puts "3番目の要素: #{array.third}"
puts ""

puts "配列をグループ化:"
grouped = array.in_groups_of(2)
grouped.each_with_index do |group, index|
  puts "グループ#{index + 1}: #{group.inspect}"
end
puts ""

# セクション8：ハッシュの便利なメソッド
puts "8. ハッシュの便利なメソッド"
puts "-" * 40
puts ""

options = { name: "Alice", age: 30, city: "Tokyo" }
puts "元のハッシュ: #{options.inspect}"
puts ""

puts "キーを文字列に変換:"
string_keys = options.stringify_keys
puts string_keys.inspect
puts ""

puts "特定のキーのみを抽出:"
puts options.slice(:name, :city).inspect
puts ""

puts "特定のキーを除外:"
puts options.except(:age).inspect
puts ""

# セクション9：try メソッド
puts "9. try メソッドで安全なメソッド呼び出し"
puts "-" * 40
puts ""

user = nil
puts "nil オブジェクトに対する safe navigation:"
puts "user.try(:upcase) = #{user.try(:upcase).inspect}"
puts "通常の user&.upcase と同様ですが、引数も渡せます"
puts ""

text = "hello"
puts "text.try(:upcase) = #{text.try(:upcase)}"
puts "text.try(:[], 0..2) = #{text.try(:[], 0..2)}"
puts ""

# セクション10：with_options
puts "10. with_options で設定を共有"
puts "-" * 40
puts ""

puts "Rails の設定などで使用される DRY な記法です"
puts "同じオプションを複数の設定で共有できます"
puts ""
puts "例（実際には実行しません）:"
puts "  with_options if: :user_signed_in? do"
puts "    validates :username, presence: true"
puts "    validates :email, presence: true"
puts "  end"
puts ""

puts "=" * 80
puts "デモンストレーション完了"
puts "=" * 80
puts ""
puts "ActiveSupportは、これらの便利なメソッドにより"
puts "Rubyコードをより読みやすく、保守しやすくします。"
