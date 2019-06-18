# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.string :img_url, null: false
      t.integer :post_id, null: false

      t.timestamps
    end
  end
end
