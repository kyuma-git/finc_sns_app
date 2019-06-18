# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :check_user_login, only: [:new, :edit, :delete]

  def new
    @comment = Comment.new
  end

  def create
    post = Post.find(params[:post_id])
    if post
      @comment = post.comments.build(comment_params)
    
      if @comment.save
        redirect_to posts_path, notice: '投稿できました'
      else
        render :new
      end
    else
      redirect_to post_path(post), alert: '投稿が存在しません'
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      redirect_to posts_path, notice: '編集できました'
    else
      render :edit
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy!
    redirect_to posts_path, notice: '削除できました'
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
