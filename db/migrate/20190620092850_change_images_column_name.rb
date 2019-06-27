# frozen_string_literal: true

class ChangeImagesColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :images, :img_url, :img_data

    remove_column :images, :post_id
    add_reference :images, :post, foreign_key: true
  end
end
