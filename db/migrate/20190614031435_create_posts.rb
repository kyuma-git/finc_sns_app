class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :text
      t.integer :browse_status
      t.integer :user_id

      t.timestamps
    end
  end
end
