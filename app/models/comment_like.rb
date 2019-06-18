class CommentLike < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :comment

  validates :user_id, :post_id
end
