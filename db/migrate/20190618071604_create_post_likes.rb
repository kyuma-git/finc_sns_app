class CreatePostLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :post_likes do |t|
      t.references :post, index: { unique: true }, foreign_key: true
      t.references :user, index: { unique: true }, foreign_key: true
      t.timestamps
    end
  end
end
