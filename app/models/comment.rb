# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_many :commentlikes, dependent: :destroy

  validates :text, presence: true

  enum publishing_policy: { unlimited: 1, friend_limited: 2, self_limited: 3 }

  def add_like(user)
    commentlikes.create(user_id: user.id)
  end

  def delete_like(user)
    commentlikes.find_by(user_id: user.id).destroy
  end

  def author?(comment, user)
    user.id == comment.user_id
  end
end
