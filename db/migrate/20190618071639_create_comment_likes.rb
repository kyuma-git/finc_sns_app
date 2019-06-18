class CreateCommentLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :comment_likes do |t|
      t.references :post, index: { unique: true }, foreign_key: true
      t.references :user, index: { unique: true }, foreign_key: true
      t.timestamps
    end
  end
end
