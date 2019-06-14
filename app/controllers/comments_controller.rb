class CommentsController < ApplicationController
  before_action :check_user_login, only: [:new, :edit, :delete]
  before_action :set_comment, only: [:show, :edit,:update, :destroy]
  def index
    @comments = Comment.all.includes(:user)
  end

  def show
  end

  def new
    @comment = comment.new
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
  end

  def update
      if @comment.update(comment_params)
        redirect_to @comment, notice: '編集できました'
      else
        render :edit
      end
  end

  def destroy
    @comment.destroy
    redirect_to comments_url, notice: '削除できました'
  end

  private

  def set_comment
    @comment = comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(
      :text,
      :browse_status,
      :created_at,
      :updated_at
    ).merge(user_id: current_user.id, post_id: comment.post.id) #Todo: コメントidもマージする
  end
end
