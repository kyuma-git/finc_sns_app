# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :check_user_login, only: [:new, :edit, :delete]
  def index
    @comments = Comment.all.includes(:user)
  end

  def show
    @comment = comment.find(params[:id])
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = comment.new(comment_params)
    if @comment.save
      redirect_to @comment, notice: '投稿できました'
    else
      render :new
    end
  end

  def edit
    @comment = comment.find(params[:id])
  end

  def update
    @comment = comment.find(params[:id])
    if @comment.update(comment_params)
      redirect_to @comment, notice: '編集できました'
    else
      render :edit
    end
  end

  def destroy
    @comment = comment.find(params[:id])
    @comment.destroy
    redirect_to comments_url, notice: '削除できました'
  end

  private

  def comment_params
    params.require(:comment).permit(
      :text,
      :browse_status,
      :created_at,
      :updated_at
    ).merge(user_id: current_user.id, post_id: comment.post.id) # TODO: コメントidもmergeする
  end
end
