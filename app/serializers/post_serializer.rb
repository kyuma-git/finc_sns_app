class PostSerializer < ActiveModel::Serializer
  attributes :id, :text, :publishing_policy, :user_id, :created_at

  belongs_to :user
  has_many :images
  has_many :postlikes
  has_many :comments
end
