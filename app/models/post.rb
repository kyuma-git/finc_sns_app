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

  def author?(post, user)
    user.id == post.user_id
  end

  def logged_in_user_feed_posts(user)
    following_posts = user.fetch_following_user_posts
    Post.my_posts(user).or(following_posts).order(created_at: :desc)
  end

  def unlogged_in_user_feed_posts
    Post.where(publishing_policy: :unlimited).order(created_at: :desc)
  end
end
