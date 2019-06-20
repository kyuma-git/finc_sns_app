# frozen_string_literal: true

class RenameCommentsColumnToPublisingPolicy < ActiveRecord::Migration[5.2]
  def change
    rename_column :comments, :browse_status, :publishing_policy
  end
end
