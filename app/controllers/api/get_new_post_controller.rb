class Api::GetNewPostController < ApplicationController
  def get_new_post
    @post = Post.my_posts(current_user).last
    render json: @post
  end

  def get_post_image_url
    @post = Post.my_posts(current_user).last
    images = @post.images[0].image_data
    render json: images
  end
end
