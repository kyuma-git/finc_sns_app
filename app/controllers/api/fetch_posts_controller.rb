class Api::FetchPostsController < ApplicationController
  def fetch_a_page_of_posts
    if current_user
      posts = Post.new().logged_in_user_feed_posts(current_user).page(params[:page])
    else
      posts = Post.new().unlogged_in_user_feed_posts.page(params[:page])
    end
    render json: posts
  end
end
