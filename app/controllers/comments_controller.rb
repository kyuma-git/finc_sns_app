# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :check_user_login, only: %i[new edit delete]

  def new
    @comment = Comment.new
  end

  def create
    @post = Post.find(params[:post_id])
    comment = @post.comments.build(comment_params)
    if comment.save
      redirect_to post_path(@post)
    else
      render :new
    end
  end

  def edit
    post = Post.find(params[:post_id])
    @comment = post.comments.find(params[:id])
    unless @comment.author?(@comment, current_user)
      redirect_to post_path(post)
      flash[:alert] = '編集、削除の権限はありません'
    end
  end

  def update
    post = Post.find(params[:id])
    @comment = Comment.find(params[:id])
    unless @comment.author?(@comment, current_user)
      redirect_to post_path(post)
      flash[:alert] = '編集、削除の権限はありません'
    end
    if @comment.update(comment_params)
      redirect_to post
    else
      render :edit
    end
  end

  def destroy
    post = Post.find(params[:post_id])
    @comment = post.comments.find(params[:id])
    unless @comment.author?(@comment, current_user)
      flash[:alert] = '編集、削除の権限はありません'
      return redirect_to post_path(post)
    end
    @comment.destroy
    redirect_to posts_path
  end

  private

  def comment_params
    params.require(:comment).permit(
      :text,
      :post_id,
      :created_at,
      :updated_at
    ).merge(user_id: current_user.id)
  end
end
