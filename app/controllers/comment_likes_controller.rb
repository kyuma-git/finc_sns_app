class CommentLikesController < ApplicationController
  def create
    @post = Comment.find(params[:id])
    @post.add_like(current_user)
  end

  def destroy
    @post = Comment.find(params[:id])
    @post.delete_like(current_user)
  end
end
