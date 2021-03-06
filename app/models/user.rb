# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :active_relationships, class_name:  'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy

  has_many :following, through: 'active_relationships', source: 'followed'
  has_many :followers, through: 'passive_relationships', source: 'follower'

  has_many :postlikes, dependent: :destroy
  has_many :commentlikes, dependent: :destroy

  validates :name, :email, :password, presence: true

  def follow(other_user)
    active_relationships.create!(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by!(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def fetch_following_user_ids
    Relationship.where(follower_id: id).pluck(:followed_id)
  end

  def fetch_following_user_posts
    posts = Post.where(user_id: fetch_following_user_ids).where.not(publishing_policy: :self_limited)
  end
end
