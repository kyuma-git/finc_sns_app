# frozen_string_literal: true

class PostLikesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @post.add_like(current_user)
    redirect_to @post
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post.delete_like(current_user)
    redirect_to @post
  end
end
