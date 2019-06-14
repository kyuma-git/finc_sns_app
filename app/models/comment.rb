class Comment < ApplicationRecord
  belongs_to :post

  has_many :likes, dependent: :destroy 
end
