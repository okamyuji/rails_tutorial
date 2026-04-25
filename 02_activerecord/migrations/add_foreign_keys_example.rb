# frozen_string_literal: true

# このマイグレーションは、外部キー制約を追加する例です。
# データベースレベルでデータ整合性を保証します。

class AddForeignKeysExample < ActiveRecord::Migration[8.0]
  def change
    # 基本的な外部キー制約
    # articles テーブルの user_id が users テーブルの id を参照することを保証
    add_foreign_key :articles, :users

    # comments テーブルの user_id が users テーブルの id を参照
    add_foreign_key :comments, :users

    # comments テーブルの article_id が articles テーブルの id を参照
    add_foreign_key :comments, :articles

    # 削除時の動作を指定した外部キー制約
    # on_delete: :cascade - 親レコードが削除されたら子レコードも削除
    add_foreign_key :articles, :users, on_delete: :cascade

    # on_delete: :nullify - 親レコードが削除されたら外部キーをNULLに設定
    # add_foreign_key :comments, :users, on_delete: :nullify

    # on_delete: :restrict - 子レコードが存在する場合、親レコードの削除を防ぐ
    # add_foreign_key :comments, :articles, on_delete: :restrict

    # カラム名が規約に従わない場合
    # column オプションで外部キーカラム名を明示的に指定
    # add_foreign_key :articles, :users, column: :author_id, primary_key: :id

    # 複合外部キー（Rails 7.1以降）
    # add_foreign_key :line_items, :orders, column: [:shop_id, :order_id], primary_key: [:shop_id, :id]
  end
end

# 外部キー制約を追加する理由:
#
# 1. データ整合性の保証
#    - 存在しない親レコードを参照する子レコードの作成を防ぐ
#    - アプリケーションのバグによるデータ破損を防ぐ
#
# 2. 削除時の動作の制御
#    - cascade: 親が削除されたら子も削除（記事を削除したらコメントも削除）
#    - nullify: 親が削除されたら外部キーをNULLに（ユーザーを削除してもコメントは残す）
#    - restrict: 子が存在する限り親を削除できない
#
# 3. パフォーマンス
#    - データベースが参照整合性を効率的にチェックできる
#    - インデックスと組み合わせることで JOIN のパフォーマンスが向上
#
# 4. ドキュメントとしての価値
#    - テーブル間の関連がスキーマに明示される
#    - 新しいチームメンバーがデータ構造を理解しやすい
#
# 注意点:
#
# 1. 既存データとの整合性
#    - 外部キー制約を追加する前に、既存データが整合性を満たしているか確認
#    - 不整合なデータがあると制約の追加に失敗する
#
# 2. パフォーマンスへの影響
#    - 制約のチェックには僅かなオーバーヘッドがある
#    - ただし、データ整合性のメリットの方が遥かに大きい
#
# 3. マイグレーションの順序
#    - 親テーブルのマイグレーションを先に実行
#    - 外部キー制約は後から追加することも可能
