require 'rails_helper'

RSpec.describe Post, type: :model do
  describe Post do
    before do
      @user = FactoryBot.create(:user)
    end
    it "is valid with a text, user_id" do
      post = Post.new(
        text: 'hello',
        user_id: @user.id
      )
      expect(post).to be_valid
    end
    it 'is invalid without a text' do
      post = Post.new(text: nil)
      post.valid?
      expect(post.errors[:text]).to include("can't be blank")
    end
  end
end
