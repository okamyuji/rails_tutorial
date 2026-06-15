# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      # email column and its unique index already exist from create_users migration
      change_table :users do |t|
        ## Database authenticatable
        t.string :encrypted_password, null: false, default: ""

        ## Recoverable
        t.string   :reset_password_token
        t.datetime :reset_password_sent_at

        ## Rememberable
        t.datetime :remember_created_at

        ## OmniAuth
        t.string :provider
        t.string :uid

        ## Role
        t.integer :role, default: 0, null: false
      end

      add_index :users, :reset_password_token, unique: true
      add_index :users, [:provider, :uid], unique: true
    end
  end
end
