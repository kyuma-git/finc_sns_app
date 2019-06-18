class CommentLikesController < ApplicationController
  def create
    @comment = Comment.find(params[:comment_id])
    @comment.add_like(current_user)
    redirect_to @comment.post
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.delete_like(current_user)
    redirect_to @comment.post
  end
end
