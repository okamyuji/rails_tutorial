# frozen_string_literal: true

# このマイグレーションは、既存のテーブルにインデックスを追加する例です。
# パフォーマンス最適化のために、頻繁に検索されるカラムにインデックスを追加します。

class AddIndexesExample < ActiveRecord::Migration[7.2]
  def change
    # 単一カラムのインデックス
    # published_at カラムにインデックスを追加
    # 公開日時で記事を検索することが多いため
    add_index :articles, :published_at

    # published カラムにインデックスを追加
    # 公開済み/下書きでフィルタリングすることが多いため
    add_index :articles, :published

    # email カラムにユニークインデックスを追加
    # メールアドレスは一意である必要があるため
    add_index :users, :email, unique: true

    # 複合インデックス
    # user_id と published_at の組み合わせでインデックスを作成
    # 「特定ユーザーの最近の記事」を検索することが多いため
    add_index :articles, %i[user_id published_at]

    # user_id と article_id の組み合わせでインデックスを作成
    # 「特定ユーザーの特定記事へのコメント」を検索することが多いため
    add_index :comments, %i[user_id article_id]

    # 部分インデックス（PostgreSQLのみ）
    # 公開済みの記事のみにインデックスを作成
    # add_index :articles, :published_at, where: "published = true", name: 'index_published_articles_on_published_at'
  end
end

# インデックスを追加する際の考慮事項:
#
# 1. 検索頻度
#    - WHERE句で頻繁に使用されるカラムにインデックスを追加
#    - JOIN条件で使用されるカラムにインデックスを追加
#
# 2. カーディナリティ
#    - 値のバリエーションが多いカラムがインデックスに適している
#    - 例: email（高カーディナリティ）vs boolean（低カーディナリティ）
#
# 3. 複合インデックスの順序
#    - 最も選択性の高いカラムを先頭に配置
#    - クエリのWHERE句の順序に合わせる
#
# 4. トレードオフ
#    - インデックスは検索を高速化するが、書き込みを遅くする
#    - インデックスはディスク容量を消費する
#    - 必要最小限のインデックスを維持する
