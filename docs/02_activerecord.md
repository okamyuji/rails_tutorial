# 第2章：ActiveRecordによるデータモデリングの実践

本章では、RailsのORM（Object-Relational Mapping）であるActiveRecordを使用したデータモデリングの実践を学びます。マイグレーションによるスキーマ管理、モデルの関連付け、クエリ最適化、バリデーション、トランザクションなど、データベース操作の基礎から実践的なテクニックまでを網羅します。

## 2.1 マイグレーションで管理するスキーマ変更

### マイグレーションを使用する利点

データベーススキーマの変更を直接SQLで実行すると、以下のような問題が発生します。

- 変更履歴が残らない
- チーム開発で同期が困難
- 環境間での再現が難しい
- ロールバックが複雑

Railsのマイグレーションは、これらの問題を解決します。マイグレーションは、データベーススキーマの変更をRubyコードで記述し、バージョン管理できる仕組みです。

マイグレーションファイルの基本構造を見てみましょう。

```ruby
# db/migrate/20240101000000_create_articles.rb
class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :content
      t.boolean :published, default: false
      t.datetime :published_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

このマイグレーションは、`articles`テーブルを作成します。`change`メソッド内で定義された操作は、Railsが自動的に逆操作を推論できます。つまり、`rails db:rollback`を実行すると、テーブルが削除されます。

マイグレーションを実行します。

```bash
rails db:migrate
```

このコマンドは、まだ実行されていないマイグレーションを順番に実行します。実行状態は`schema_migrations`テーブルで管理されます。

マイグレーションの利点を具体的に見ていきましょう。

**履歴管理**: すべての変更がファイルとして記録されます。いつ、誰が、何を変更したかが明確です。

```bash
$ ls db/migrate/
20240101000000_create_users.rb
20240102000000_create_articles.rb
20240103000000_add_published_to_articles.rb
20240104000000_create_comments.rb
```

**データベース非依存**: RubyのDSL（Domain Specific Language）で記述するため、異なるデータベース（PostgreSQL、MySQL、SQLite）間で同じコードが動作します。

**チーム開発での再現性**: チームメンバーが同じマイグレーションを実行することで、全員が同じスキーマを持ちます。

```bash
# 新しいメンバーがプロジェクトに参加
git clone repository
bundle install
rails db:create
rails db:migrate
# これで全員と同じスキーマになる
```

**ロールバック可能性**: 問題が発生した場合、簡単に前の状態に戻せます。

```bash
# 最後のマイグレーションを取り消す
rails db:rollback

# 特定のバージョンまで戻す
rails db:migrate VERSION=20240102000000

# 全てのマイグレーションを取り消す
rails db:rollback STEP=100
```

### changeメソッドとup/downメソッドの使い分け

多くの場合、`change`メソッドで十分です。Railsは以下の操作の逆操作を自動推論できます。

- `create_table` ⇔ `drop_table`
- `add_column` ⇔ `remove_column`
- `add_index` ⇔ `remove_index`
- `add_reference` ⇔ `remove_reference`

しかし、複雑な操作やデータ変更を伴う場合は、明示的に`up`と`down`メソッドを定義します。

```ruby
class AddDefaultValueToArticlesPublished < ActiveRecord::Migration[7.2]
  def up
    change_column_default :articles, :published, from: nil, to: false
    # 既存のnullレコードをfalseに更新
    Article.where(published: nil).update_all(published: false)
  end

  def down
    change_column_default :articles, :published, from: false, to: nil
    # ロールバック時はnullに戻す
    Article.where(published: false).update_all(published: nil)
  end
end
```

逆操作が不可能な場合は、`reversible`ブロックを使用します。

```ruby
class ChangeArticlesContentType < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        # テキストをJSON型に変換
        execute <<-SQL
          ALTER TABLE articles 
          ALTER COLUMN content TYPE jsonb 
          USING content::jsonb
        SQL
      end

      dir.down do
        # JSON型をテキストに戻す
        execute <<-SQL
          ALTER TABLE articles 
          ALTER COLUMN content TYPE text 
          USING content::text
        SQL
      end
    end
  end
end
```

データ移行を伴うマイグレーションの例を見てみましょう。

```ruby
class SplitUserNameIntoFirstAndLastName < ActiveRecord::Migration[7.2]
  def up
    # 新しいカラムを追加
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    # 既存データを分割
    User.reset_column_information  # カラム情報を再読み込み
    User.find_each do |user|
      parts = user.name.to_s.split(' ', 2)
      user.update_columns(
        first_name: parts.first,
        last_name: parts.second
      )
    end

    # 古いカラムを削除
    remove_column :users, :name
  end

  def down
    # nameカラムを復元
    add_column :users, :name, :string

    # データを結合
    User.reset_column_information
    User.find_each do |user|
      full_name = [user.first_name, user.last_name].compact.join(' ')
      user.update_column(:name, full_name)
    end

    # 分割カラムを削除
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
```

### インデックスと外部キー制約の設定

インデックスは、データベースのクエリパフォーマンスを大幅に向上させます。適切なインデックスを設定することで、検索速度が数倍から数千倍になることもあります。

基本的なインデックスの追加方法を見てみましょう。

```ruby
class AddIndexToArticles < ActiveRecord::Migration[7.2]
  def change
    # 単一カラムのインデックス
    add_index :articles, :published_at
    add_index :articles, :user_id
    
    # ユニークインデックス
    add_index :articles, :slug, unique: true
    
    # 複合インデックス（複数カラム）
    add_index :articles, [:user_id, :published_at]
    add_index :articles, [:user_id, :created_at], order: { created_at: :desc }
  end
end
```

複合インデックスの順序は重要です。`[:user_id, :published_at]`というインデックスは、以下のクエリで効果を発揮します。

```ruby
# このクエリはインデックスを活用できる
Article.where(user_id: 1).where('published_at > ?', 1.week.ago)

# このクエリもインデックスを部分的に活用できる
Article.where(user_id: 1)

# しかし、このクエリはインデックスを活用できない
Article.where('published_at > ?', 1.week.ago)
```

インデックスは「左から順に」使用されます。`[:user_id, :published_at]`の場合、`user_id`だけを使う検索には効果がありますが、`published_at`だけを使う検索には効果がありません。

部分インデックス（PostgreSQL）を使用すると、特定の条件に合致する行だけをインデックス化できます。

```ruby
class AddPartialIndexToArticles < ActiveRecord::Migration[7.2]
  def change
    # 公開済み記事だけをインデックス化
    add_index :articles, :published_at, 
              where: "published = true",
              name: 'index_published_articles_on_published_at'
  end
end
```

外部キー制約は、データの整合性を保証します。親レコードが削除されたときに子レコードをどう扱うかを定義できます。

```ruby
class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
```

`on_delete`オプションで削除時の動作を指定できます。

- `:cascade`: 親レコード削除時に子レコードも削除
- `:nullify`: 親レコード削除時に外部キーをNULLに設定  
- `:restrict`: 子レコードが存在する場合、親レコードの削除を拒否

既存のテーブルに外部キー制約を追加する場合：

```ruby
class AddForeignKeyToComments < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :comments, :articles, on_delete: :cascade
    add_foreign_key :comments, :users, on_delete: :nullify
  end
end
```

外部キー制約により、以下のような不整合を防げます。

```ruby
# 外部キー制約がない場合（危険）
article = Article.find(1)
article.destroy
# コメントは残ったまま（孤児レコード）

# 外部キー制約（on_delete: :cascade）がある場合
article = Article.find(1)
article.destroy
# コメントも自動的に削除される
```

## 2.2 モデルの関連付けとクエリの最適化

### belongs_to、has_many、has_many throughの使い分け

ActiveRecordの関連付けは、モデル間の関係を宣言的に定義します。適切な関連付けを選択することで、コードが簡潔になり、データの整合性が保たれます。

**belongs_to関連付け**は、1対多の関係における「多」側を表現します。

```ruby
class Article < ApplicationRecord
  belongs_to :user
  belongs_to :category
end
```

この宣言により、以下のメソッドが使用可能になります。

```ruby
article = Article.find(1)
article.user          # 関連するUserを取得
article.user = user   # Userを関連付け
article.build_user    # 新しいUserインスタンスを作成（未保存）
article.create_user   # 新しいUserを作成して保存
```

Rails 5以降、`belongs_to`はデフォルトで必須です。オプショナルにする場合は明示的に指定します。

```ruby
class Article < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
end
```

**has_many関連付け**は、1対多の関係における「1」側を表現します。

```ruby
class User < ApplicationRecord
  has_many :articles
  has_many :comments
end
```

これにより、以下のメソッドが使用可能になります。

```ruby
user = User.find(1)
user.articles                    # 全ての記事を取得
user.articles.where(published: true)  # 公開記事のみ
user.articles.count              # 記事数
user.articles << article         # 記事を追加
user.articles.build(title: '新規記事')  # 新しい記事を作成（未保存）
user.articles.create(title: '新規記事') # 新しい記事を作成して保存
user.articles.destroy_all        # 全ての記事を削除
```

依存関係を指定することで、親レコード削除時の動作を制御できます。

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy  # ユーザー削除時に記事も削除
  has_many :comments, dependent: :nullify  # ユーザー削除時にuser_idをNULLに
  has_many :likes, dependent: :delete_all  # コールバックをスキップして削除（高速）
end
```

`dependent`オプションの違い：

- `:destroy`: 各子レコードのdestroyメソッドを呼び出す（コールバック実行）
- `:delete_all`: SQL DELETEを直接実行（コールバックなし、高速）
- `:nullify`: 外部キーをNULLに設定
- `:restrict_with_exception`: 子レコードがあれば例外を発生
- `:restrict_with_error`: 子レコードがあればエラーを追加

**has_many through関連付け**は、多対多の関係を中間モデル経由で表現します。

```ruby
class User < ApplicationRecord
  has_many :memberships
  has_many :groups, through: :memberships
end

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group
  
  # 中間テーブルに追加属性を持てる
  enum role: { member: 0, moderator: 1, admin: 2 }
end

class Group < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships
end
```

この設計により、ユーザーとグループの関係に役割情報を追加できます。

```ruby
user = User.find(1)
group = Group.find(1)

# 関連を作成
user.memberships.create(group: group, role: :admin)

# throughで直接アクセス
user.groups              # ユーザーが所属する全グループ
group.users              # グループの全メンバー

# 中間テーブルの属性にアクセス
membership = user.memberships.find_by(group: group)
membership.role          # => "admin"
membership.admin?        # => true

# 条件付きで関連を取得
user.groups.where(memberships: { role: :admin })
```

**has_and_belongs_to_many（HABTM）**は、シンプルな多対多関係に使用します。中間テーブルに追加属性が不要な場合に適しています。

```ruby
class Article < ApplicationRecord
  has_and_belongs_to_many :tags
end

class Tag < ApplicationRecord
  has_and_belongs_to_many :articles
end
```

ただし、多くの場合は`has_many through`の方が柔軟性が高いため推奨されます。後から中間テーブルに属性を追加する必要が生じた場合、HABTMからの移行は面倒です。

### N+1問題の仕組みと解決方法

N+1問題は、関連データを取得する際に最も頻繁に発生するパフォーマンス問題です。

問題のあるコードを見てみましょう。

```ruby
# N+1問題が発生するコード
articles = Article.limit(10)
articles.each do |article|
  puts article.user.name  # ここで毎回SQLが発行される
end

# 実行されるSQL:
# SELECT * FROM articles LIMIT 10           -- 1回
# SELECT * FROM users WHERE id = 1          -- 1回
# SELECT * FROM users WHERE id = 2          -- 1回
# ...（記事の数だけユーザー取得クエリが発行される）
# 合計11回のクエリ
```

`includes`メソッドを使用すると、関連データを事前読み込みできます。

```ruby
# N+1問題を解決
articles = Article.includes(:user).limit(10)
articles.each do |article|
  puts article.user.name
end

# 実行されるSQL:
# SELECT * FROM articles LIMIT 10                    -- 1回
# SELECT * FROM users WHERE id IN (1, 2, 3, ...)    -- 1回
# 合計2回のクエリ
```

`includes`は、2つの戦略を使い分けます。

**1. Eager Loading（eager_load）**: LEFT OUTER JOINを使用

```ruby
Article.eager_load(:user).limit(10)

# 実行されるSQL:
# SELECT articles.*, users.*
# FROM articles
# LEFT OUTER JOIN users ON users.id = articles.user_id
# LIMIT 10
```

**2. Preloading（preload）**: 別々のクエリで取得

```ruby
Article.preload(:user).limit(10)

# 実行されるSQL:
# SELECT * FROM articles LIMIT 10
# SELECT * FROM users WHERE id IN (1, 2, 3, ...)
```

`includes`は自動的に最適な戦略を選択しますが、明示的に指定することもできます。

ネストした関連の読み込みも可能です。

```ruby
# 記事、ユーザー、コメント、コメントのユーザーを一度に取得
articles = Article.includes(user: :profile, comments: :user)

articles.each do |article|
  puts article.user.name
  puts article.user.profile.bio
  article.comments.each do |comment|
    puts comment.user.name
  end
end

# 実行されるSQL:
# SELECT * FROM articles
# SELECT * FROM users WHERE id IN (...)
# SELECT * FROM profiles WHERE user_id IN (...)
# SELECT * FROM comments WHERE article_id IN (...)
# SELECT * FROM users WHERE id IN (...)（コメントのユーザー）
```

`joins`との違いを理解することが重要です。

```ruby
# joins: データをフィルタリングするが、関連データは読み込まない
Article.joins(:user).where(users: { active: true })
# N+1問題が発生する可能性あり

# includes: 関連データを事前読み込み
Article.includes(:user).where(users: { active: true })
# N+1問題は発生しない
```

`includes`と`joins`を組み合わせることもできます。

```ruby
# アクティブなユーザーの記事のみ取得し、ユーザー情報も事前読み込み
Article.joins(:user)
       .where(users: { active: true })
       .includes(:user, :comments)
```

### scopeとクエリメソッドの設計

scopeは、よく使うクエリを名前付きで定義できます。再利用性が高く、可読性も向上します。

```ruby
class Article < ApplicationRecord
  # 基本的なscope
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(created_at: :desc) }
  
  # パラメータを受け取るscope
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :created_after, ->(date) { where('created_at > ?', date) }
  
  # チェーン可能なscope
  scope :popular, -> { where('views_count > ?', 1000).order(views_count: :desc) }
  
  # 条件付きscope
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
end
```

scopeはチェーン可能なため、柔軟にクエリを組み立てられます。

```ruby
# scopeをチェーン
Article.published.recent.limit(10)
Article.by_user(current_user.id).published
Article.created_after(1.week.ago).popular

# 複数の条件を組み合わせ
Article.published
       .by_category(params[:category_id])
       .created_after(params[:start_date])
       .order(params[:sort])
       .page(params[:page])
```

scopeとクラスメソッドの使い分けを見てみましょう。

```ruby
class Article < ApplicationRecord
  # scopeで十分な場合
  scope :published, -> { where(published: true) }
  
  # 複雑なロジックが必要な場合はクラスメソッド
  def self.search(query)
    return all if query.blank?
    
    where('title LIKE ? OR content LIKE ?', "%#{query}%", "%#{query}%")
  end
  
  # 複数のテーブルを結合する複雑なクエリ
  def self.with_active_comments
    joins(:comments)
      .merge(Comment.active)
      .distinct
  end
  
  # 条件分岐が必要な場合
  def self.by_status(status)
    case status
    when 'published'
      published.where('published_at < ?', Time.current)
    when 'scheduled'
      published.where('published_at > ?', Time.current)
    when 'draft'
      draft
    else
      all
    end
  end
end
```

`default_scope`には注意が必要です。暗黙的な動作を引き起こし、予期しないバグの原因になります。

```ruby
# 避けるべきパターン
class Article < ApplicationRecord
  default_scope { where(deleted: false) }
end

# 削除済みレコードを取得できなくなる
Article.all  # deleted = false のレコードのみ
Article.unscoped.all  # default_scopeを無視
```

`default_scope`を使用する場合は、明示的にドキュメント化し、チーム全体で認識を共有すべきです。

## 2.3 バリデーションとコールバックの適切な使用

### データ整合性の多層保護

データの整合性は、複数の層で保護すべきです。モデルのバリデーションとデータベース制約を組み合わせることで、堅牢なアプリケーションを構築できます。

モデルのバリデーションは、ユーザーフレンドリーなエラーメッセージを提供します。

```ruby
class Article < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :published_at, presence: true, if: :published?
  
  # カスタムバリデーション
  validate :published_at_cannot_be_in_the_past, if: :published?
  
  private
  
  def published_at_cannot_be_in_the_past
    if published_at.present? && published_at < Time.current
      errors.add(:published_at, "は未来の日時を指定してください")
    end
  end
end
```

データベース制約は、アプリケーション層をバイパスした操作からもデータを保護します。

```ruby
class AddConstraintsToArticles < ActiveRecord::Migration[7.2]
  def change
    change_column_null :articles, :title, false
    change_column_null :articles, :content, false
    add_index :articles, :slug, unique: true
    
    # CHECK制約（PostgreSQL）
    execute <<-SQL
      ALTER TABLE articles
      ADD CONSTRAINT check_title_length
      CHECK (char_length(title) >= 5 AND char_length(title) <= 200)
    SQL
  end
end
```

両方を使用することで、二重の防御を実現します。

```ruby
# モデルバリデーションが失敗
article = Article.new
article.valid?  # => false
article.errors.full_messages  # => ["Title can't be blank"]

# バリデーションをスキップして保存を試みる
article.save(validate: false)
# => ActiveRecord::NotNullViolation（データベース制約で阻止される）
```

### 条件付きバリデーションとカスタムバリデーション

条件付きバリデーションにより、特定の状況でのみバリデーションを適用できます。

```ruby
class Article < ApplicationRecord
  validates :published_at, presence: true, if: :published?
  validates :scheduled_at, presence: true, if: :scheduled?
  validates :draft_note, presence: true, unless: :published?
  
  # 複数条件
  validates :content, length: { minimum: 100 }, 
            if: [:published?, :feature_article?]
  
  # Procを使用
  validates :tags, presence: true, 
            if: Proc.new { |article| article.published? && article.category.requires_tags? }
end
```

カスタムバリデータを作成することで、複雑な検証ロジックを再利用できます。

```ruby
# app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add(attribute, (options[:message] || "は有効なメールアドレスではありません"))
    end
  end
end

class User < ApplicationRecord
  validates :email, email: true
  validates :secondary_email, email: { message: "の形式が正しくありません" }
end
```

より複雑な検証が必要な場合は、カスタムバリデーションメソッドを使用します。

```ruby
class Article < ApplicationRecord
  validate :ensure_unique_title_per_user
  validate :check_profanity_in_content
  
  private
  
  def ensure_unique_title_per_user
    existing = Article.where(user_id: user_id, title: title)
    existing = existing.where.not(id: id) if persisted?
    
    if existing.exists?
      errors.add(:title, "は既に使用されています")
    end
  end
  
  def check_profanity_in_content
    prohibited_words = ['spam', 'scam']
    if prohibited_words.any? { |word| content.to_s.downcase.include?(word) }
      errors.add(:content, "に不適切な表現が含まれています")
    end
  end
end
```

### コールバックとトランザクションの使用

コールバックは、モデルのライフサイクルイベントにフックできます。

```ruby
class Article < ApplicationRecord
  before_validation :normalize_title
  before_save :generate_slug
  after_save :update_user_article_count
  after_commit :notify_followers, on: :create
  
  private
  
  def normalize_title
    self.title = title.strip.squeeze(' ') if title.present?
  end
  
  def generate_slug
    self.slug = title.parameterize if slug.blank?
  end
  
  def update_user_article_count
    user.update_column(:articles_count, user.articles.count)
  end
  
  def notify_followers
    NotifyFollowersJob.perform_later(self)
  end
end
```

コールバックの実行順序を理解することが重要です。

```text
# 作成時
before_validation
after_validation
before_save
before_create
# データベースへの保存
after_create
after_save
after_commit

# 更新時
before_validation
after_validation
before_save
before_update
# データベースへの保存
after_update
after_save
after_commit
```

コールバックの乱用は避けるべきです。複雑なビジネスロジックは、サービスオブジェクトに抽出する方が保守性が高くなります。

```ruby
# 避けるべきパターン
class Article < ApplicationRecord
  after_save :send_notification
  after_save :update_search_index
  after_save :clear_cache
  after_save :log_activity
  # コールバックが多すぎて追跡困難
end

# 推奨パターン
class Article < ApplicationRecord
  # 必要最小限のコールバックのみ
  after_commit :publish_event, on: [:create, :update]
  
  private
  
  def publish_event
    ArticleEventPublisher.publish(self)
  end
end

# app/services/article_publisher.rb
class ArticlePublisher
  def initialize(article)
    @article = article
  end
  
  def publish
    Article.transaction do
      @article.update!(published: true, published_at: Time.current)
      send_notification
      update_search_index
      clear_cache
      log_activity
    end
  end
  
  private
  
  def send_notification
    # 通知ロジック
  end
  
  # ...
end
```

トランザクションは、複数の操作を原子的に実行します。

```ruby
class User < ApplicationRecord
  def transfer_funds(recipient, amount)
    User.transaction do
      # トランザクション内では全て成功するか、全て失敗する
      self.balance -= amount
      save!
      
      recipient.balance += amount
      recipient.save!
      
      Transfer.create!(
        from: self,
        to: recipient,
        amount: amount
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    # トランザクションがロールバックされる
    Rails.logger.error("Transfer failed: #{e.message}")
    false
  end
end
```

ネストしたトランザクションは、セーブポイントとして機能します。

```ruby
User.transaction do
  user.update!(name: 'New Name')
  
  User.transaction(requires_new: true) do
    # 独立したトランザクション
    user.create_log!(action: 'name_change')
  end
  
  # ログ作成が失敗しても、名前変更は成功する
end
```

## まとめ

この章では、ActiveRecordを使用したデータモデリングの実践を学びました。

マイグレーションは、データベーススキーマの変更を管理する強力な仕組みです。履歴管理、ロールバック可能性、チーム開発での再現性を提供します。インデックスと外部キー制約により、パフォーマンスとデータ整合性を保証します。

モデルの関連付けは、`belongs_to`、`has_many`、`has_many through`を適切に使い分けることで、データの関係性を明確に表現できます。N+1問題は`includes`で解決し、scopeにより再利用可能なクエリを定義します。

バリデーションとデータベース制約の両方を使用することで、堅牢なデータ整合性を実現します。コールバックは最小限に留め、複雑なロジックはサービスオブジェクトに抽出すべきです。トランザクションにより、複数の操作を安全に実行できます。

次章では、RESTfulなルーティングとコントローラ設計について学びます。
