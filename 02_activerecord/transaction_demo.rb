# frozen_string_literal: true

# トランザクションのデモンストレーション
# rails runner transaction_demo.rb で実行します

puts "=" * 80
puts "トランザクションのデモンストレーション"
puts "=" * 80
puts ""

# データが存在するか確認
if User.count == 0
  puts "エラー: サンプルデータが存在しません"
  puts "まず seed_data.rb を実行してください"
  exit 1
end

puts "デモ1: トランザクションなしでの複数操作"
puts "-" * 40
puts ""

puts "トランザクションなしで3つの操作を実行します"
puts ""

initial_user_count = User.count

begin
  user1 = User.create!(name: "Transaction User 1", email: "trans1@example.com")
  puts "✓ ユーザー1を作成しました: #{user1.name}"
  
  user2 = User.create!(name: "Transaction User 2", email: "trans2@example.com")
  puts "✓ ユーザー2を作成しました: #{user2.name}"
  
  # 意図的にエラーを発生させる（メールアドレスなし）
  user3 = User.create!(name: "Transaction User 3", email: nil)
  puts "✓ ユーザー3を作成しました: #{user3.name}"
rescue ActiveRecord::RecordInvalid => e
  puts "✗ エラーが発生しました: #{e.message}"
end

puts ""
puts "結果:"
puts "  操作前のユーザー数: #{initial_user_count}"
puts "  操作後のユーザー数: #{User.count}"
puts "  増加したユーザー数: #{User.count - initial_user_count}"
puts ""

puts "問題点:"
puts "  3つの操作のうち2つは成功し、1つは失敗しました。"
puts "  しかし、成功した2つのレコードはデータベースに残っています。"
puts "  これは部分的な成功であり、データの整合性が保証されません。"
puts ""

# クリーンアップ
User.where("email LIKE ?", "trans%@example.com").destroy_all

puts "=" * 80
puts "デモ2: トランザクションを使用した複数操作"
puts "-" * 40
puts ""

puts "トランザクション内で3つの操作を実行します"
puts ""

initial_user_count = User.count

begin
  User.transaction do
    user1 = User.create!(name: "Transaction User 1", email: "trans1@example.com")
    puts "✓ ユーザー1を作成しました: #{user1.name}"
    
    user2 = User.create!(name: "Transaction User 2", email: "trans2@example.com")
    puts "✓ ユーザー2を作成しました: #{user2.name}"
    
    # 意図的にエラーを発生させる
    user3 = User.create!(name: "Transaction User 3", email: nil)
    puts "✓ ユーザー3を作成しました: #{user3.name}"
  end
rescue ActiveRecord::RecordInvalid => e
  puts "✗ エラーが発生しました: #{e.message}"
  puts "✓ トランザクションがロールバックされました"
end

puts ""
puts "結果:"
puts "  操作前のユーザー数: #{initial_user_count}"
puts "  操作後のユーザー数: #{User.count}"
puts "  増加したユーザー数: #{User.count - initial_user_count}"
puts ""

puts "利点:"
puts "  エラーが発生したため、すべての変更がロールバックされました。"
puts "  データベースは元の状態のままです。"
puts "  データの整合性が保証されています。"
puts ""

puts "=" * 80
puts "デモ3: 実践的な例 - 銀行の送金処理"
puts "-" * 40
puts ""

# アカウントを表現するシンプルな構造体
Account = Struct.new(:id, :name, :balance) do
  def self.find(id)
    # 簡易的な実装
    case id
    when 1
      new(1, "Alice", 1000)
    when 2
      new(2, "Bob", 500)
    end
  end
  
  def update!(attributes)
    self.balance = attributes[:balance] if attributes[:balance]
    self
  end
end

puts "初期状態:"
alice_account = Account.find(1)
bob_account = Account.find(2)
puts "  Aliceの残高: #{alice_account.balance}円"
puts "  Bobの残高: #{bob_account.balance}円"
puts ""

amount = 200
puts "AliceからBobに#{amount}円を送金します"
puts ""

# トランザクションなしの場合（コメントアウト）
# puts "トランザクションなしで送金:"
# begin
#   alice_account.balance -= amount
#   alice_account.update!(balance: alice_account.balance)
#   puts "✓ Aliceの残高を減らしました"
#   
#   # ここでエラーが発生すると...
#   raise "ネットワークエラー"
#   
#   bob_account.balance += amount
#   bob_account.update!(balance: bob_account.balance)
#   puts "✓ Bobの残高を増やしました"
# rescue => e
#   puts "✗ エラー: #{e.message}"
#   puts "問題: Aliceの残高は減ったが、Bobには届いていない！"
# end

puts "トランザクションを使用した送金:"
success = false

begin
  # 実際のRailsアプリケーションではActiveRecordモデルを使用
  # User.transaction do
  #   alice_account.update!(balance: alice_account.balance - amount)
  #   bob_account.update!(balance: bob_account.balance + amount)
  # end
  
  # デモ用のシミュレーション
  puts "  トランザクション開始"
  puts "  ✓ Aliceの残高を#{alice_account.balance - amount}円に変更"
  puts "  ✓ Bobの残高を#{bob_account.balance + amount}円に変更"
  puts "  トランザクションコミット"
  
  alice_account.balance -= amount
  bob_account.balance += amount
  success = true
rescue => e
  puts "  ✗ エラー発生: #{e.message}"
  puts "  トランザクションロールバック"
end

puts ""
if success
  puts "送金完了:"
  puts "  Aliceの残高: #{alice_account.balance}円 (-#{amount}円)"
  puts "  Bobの残高: #{bob_account.balance}円 (+#{amount}円)"
else
  puts "送金失敗:"
  puts "  Aliceの残高: #{alice_account.balance}円 (変更なし)"
  puts "  Bobの残高: #{bob_account.balance}円 (変更なし)"
end
puts ""

puts "=" * 80
puts "デモ4: ネストしたトランザクション"
puts "-" * 40
puts ""

puts "親トランザクション内で子トランザクションを実行します"
puts ""

User.transaction do
  puts "親トランザクション開始"
  
  user = User.create!(name: "Parent Transaction User", email: "parent@example.com")
  puts "  ✓ ユーザーを作成: #{user.name}"
  
  begin
    User.transaction do
      puts "  子トランザクション開始"
      
      article = user.articles.create!(title: "Nested Transaction Article", content: "Content here")
      puts "    ✓ 記事を作成: #{article.title}"
      
      # 子トランザクションでエラーを発生させる
      raise ActiveRecord::Rollback, "子トランザクションのロールバック"
    end
  rescue ActiveRecord::Rollback => e
    puts "    ✗ 子トランザクションがロールバックされました"
  end
  
  puts "  親トランザクション継続中"
  
  # 親トランザクションはコミットされる
  puts "親トランザクション完了"
end

puts ""
puts "注意:"
puts "  PostgreSQLではセーブポイントを使用してネストをサポートします。"
puts "  一部のデータベースでは完全なネストがサポートされていません。"
puts ""

# クリーンアップ
User.where("email LIKE ?", "%transaction%@example.com").destroy_all

puts "=" * 80
puts "まとめ"
puts "=" * 80
puts ""

puts "トランザクションの目的:"
puts "  複数の操作を1つのアトミックな単位として実行します。"
puts "  すべて成功するか、すべて失敗するかのどちらかです。"
puts ""

puts "使用すべき場合:"
puts "  - 複数のレコードを同時に作成/更新する場合"
puts "  - データの整合性が重要な場合（送金、在庫管理など）"
puts "  - 失敗時にすべての変更を取り消す必要がある場合"
puts ""

puts "注意点:"
puts "  - トランザクション内で時間のかかる処理を避ける"
puts "  - 外部APIへのリクエストはトランザクション外で実行"
puts "  - デッドロックに注意（複数のトランザクションが互いを待つ状態）"
puts ""

puts "=" * 80
