# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :check_user_login, only: [:new, :edit, :delete]

  def new
    @comment = Comment.new
  end

  def create
    post = Post.find(params[:post_id])
    comment = post.comments.build(comment_params)
    if comment.save
      redirect_to posts_path
    else
      render :new
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    comment = Comment.find(params[:id])
    if comment.update(comment_params)
      redirect_to posts_path
    else
      render :edit
    end
  end

  #####################################
  #Todo: Like機能作成後、ポスト・コメントの削除でLikeが削除されるか確認
  #####################################
  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to posts_path
  end

  private

  def comment_params
    params.require(:comment).permit(
      :text,
      :publishing_policy,
      :post_id,
      :created_at,
      :updated_at
    ).merge(user_id: current_user.id)
  end
end
