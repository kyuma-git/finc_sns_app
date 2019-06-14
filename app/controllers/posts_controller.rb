class PostsController < ApplicationController
  before_action :check_user_login, only: [:new, :edit, :delete]
  before_action :set_post, only: [:show, :edit,:update, :destroy]
  def index
    #Todo: ログインしてる場合、フォローしてるユーザの投稿が表示されるほうに
    @posts = Post.all.includes(:user)
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post, notice: '投稿できました'
    else
      render :new
    end
  end

  def edit
  end

  def update
      if @post.update(post_params)
        redirect_to @post, notice: '編集できました'
      else
        render :edit
      end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: '削除できました'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(
      :text,
      :browse_status,
      :created_at,
      :updated_at
    ).merge(user_id: current_user.id)
  end

end
