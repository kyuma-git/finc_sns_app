require 'rails_helper'

RSpec.describe Api::FetchPostsController, type: :controller do
  describe "GET / posts api" do
    it "response status which is success" do
      api_fetch_a_page_of_posts_path
      expect(response).to be_success
    end
  end
end
