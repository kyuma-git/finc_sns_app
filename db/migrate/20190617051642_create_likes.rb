# frozen_string_literal: true

class CreateLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      t.references :post
      t.references :user
      t.timestamps
    end
    add_foreign_key :post, :user
  end
end
