class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :content
      t.boolean :published, default: false
      t.datetime :published_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :articles, [:user_id, :published_at]
  end
end
