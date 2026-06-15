user = User.find_or_create_by!(email: "alice@example.com") do |u|
  u.name = "Alice"
end

3.times do |i|
  article = Article.find_or_create_by!(title: "サンプル記事 #{i + 1}") do |a|
    a.content = "これはサンプル記事#{i + 1}の本文です。動作確認用のデータとして使用します。"
    a.user = user
  end

  2.times do |j|
    Comment.find_or_create_by!(
      article: article,
      body: "記事#{i + 1}へのコメント#{j + 1}です。"
    ) do |c|
      c.user = user
    end
  end
end
