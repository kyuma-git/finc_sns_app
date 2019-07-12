# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :postlikes, dependent: :destroy
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images

  validates :text, presence: true, length: { maximum: 140 }

  enum publishing_policy: { unlimited: 1, follower_limited: 2, self_limited: 3 }

  scope :my_posts, -> (user) {where(user_id: user.id)}

  def add_like(user)
    postlikes.create(user_id: user.id)
  end

  def delete_like(user)
    postlikes.find_by(user_id: user.id).destroy
  end
end
