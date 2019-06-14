class Comment < ApplicationRecord
  belongs_to :post

  has_many :likes, dependent: :destroy 

  enum browse_status: { 公開: 1, フォロワーのみ: 2, 自分のみ: 3 }
  
end
