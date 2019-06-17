# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :text, null: false
      t.integer :browse_status, default: 1
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
