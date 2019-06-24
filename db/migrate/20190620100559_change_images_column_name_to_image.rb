# frozen_string_literal: true

class ChangeImagesColumnNameToImage < ActiveRecord::Migration[5.2]
  def change
    rename_column :images, :img_data, :image_data
  end
end
