# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :text, presence: true

  enum publishing_policy: { unlimited: 1, friend_limited: 2, self_limited: 3 }
end
