class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :likes, dependent: :destroy

  enum browse_status: { 公開: 1, フォロワーのみ: 2, 自分のみ: 3 }

end
