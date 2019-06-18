class RenamePostsColumnToPublisingPolicy < ActiveRecord::Migration[5.2]
  def change
    rename_column :posts, :browse_status, :publishing_policy
  end
end
