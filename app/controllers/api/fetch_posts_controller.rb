class Api::FetchPostsController < ApplicationController
  def fetch_a_page_of_posts
    if current_user
      posts = logged_in_user_feed_posts
    else
      posts = unlogged_in_user_feed_posts
    end
    render json: posts
  end
end
