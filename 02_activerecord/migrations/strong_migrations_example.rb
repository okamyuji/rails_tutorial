# strong_migrations による「危険なマイグレーション」のCI自動検出例
#
# Gemfileに以下を追記:
#
#   gem 'strong_migrations'
#
# その上で `bin/rails generate strong_migrations:install` を実行すると、
# 各マイグレーション実行時に危険な操作を自動検出して停止します。
# CIでマイグレーションをドライランすれば、レビューに頼らず本番事故を防げます。

# ------------------------------------------------------------
# 危険例 1: NOT NULL + default の同時追加
# 古いMySQLや一部Postgresのバージョンでは全行書き換えが走り、
# 本番テーブルへの長時間ロックが発生する可能性があります。
# ------------------------------------------------------------
class AddEmailToUsersUnsafe < ActiveRecord::Migration[7.2]
  def change
    # strong_migrationsはこの記述を実行前に止めて、
    # 「カラム追加 → backfill → NOT NULL付与」の3段階に分けるよう促します。
    add_column :users, :email, :string, null: false, default: ""
  end
end

# ------------------------------------------------------------
# 推奨例: 3段階に分けた安全な追加
# ------------------------------------------------------------
class AddEmailToUsersStep1 < ActiveRecord::Migration[7.2]
  def change
    # Step 1: nullableで追加（即時、ロック短い）
    add_column :users, :email, :string
  end
end

class AddEmailToUsersStep2 < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # Step 2: 既存行を埋める（バックフィルは別ジョブやrakeに切り出す方がより安全）
    User.in_batches(of: 1_000).update_all(email: "")
  end

  def down
    # 何もしない（ロールバックでは値を戻さない）
  end
end

class AddEmailToUsersStep3 < ActiveRecord::Migration[7.2]
  def change
    # Step 3: NOT NULL制約を付与
    change_column_null :users, :email, false
  end
end

# ------------------------------------------------------------
# 危険例 2: 大量データ移行をマイグレーション内で行う
# strong_migrationsは「マイグレーション内のActiveRecord操作」を警告し、
# 別のRakeタスクへ切り出すことを促します。
# ------------------------------------------------------------
class BackfillArticleSlugs < ActiveRecord::Migration[7.2]
  def up
    # 数百万件のレコードを更新するような処理は、
    # マイグレーションではなくrakeタスク or 専用ジョブに切り出すべきです。
    # それでもどうしても必要な場合は safety_assured を明示する。
    safety_assured do
      Article
        .in_batches(of: 1_000)
        .each do |batch|
          batch.update_all("slug = lower(replace(title, ' ', '-'))")
        end
    end
  end

  def down
    # ロールバック処理（必要に応じて）
  end
end

# ------------------------------------------------------------
# CIでの活用
# ------------------------------------------------------------
# .github/workflows/ci.yml に以下を追加して、
# マイグレーションを実行できるかを毎回検証できます。
#
#   - name: Migration dry-run
#     env:
#       DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
#       RAILS_ENV: test
#     run: |
#       bundle exec rails db:create
#       bundle exec rails db:migrate
#
# strong_migrations が危険操作を検出した場合、CIがexit 1で落ちるため、
# 「main ブランチにマージしたら本番がロックで止まる」という事故を未然に防げます。
