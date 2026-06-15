class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      add_column :users, :encrypted_password, :string, null: false, default: ""
      add_column :users, :reset_password_token, :string
      add_column :users, :reset_password_sent_at, :datetime
      add_column :users, :remember_created_at, :datetime
      add_column :users, :role, :integer, default: 0

      add_index :users, :reset_password_token, unique: true
    end
  end
end
