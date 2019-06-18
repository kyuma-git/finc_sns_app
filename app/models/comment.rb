# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_many :likes, dependent: :destroy

  enum publishing_policy: { unlimited: 1, friend_limited: 2, self_limited: 3 }
end
