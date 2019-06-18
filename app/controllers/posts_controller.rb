# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :check_user_login, only: [:new, :edit, :delete]
  def index
    if current_user
      @posts = current_user.feed.order(created_at: :desc)
      @comment = Comment.all
    else
      @posts = Post.all.order(created_at: :desc)
    end
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments
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
    @post = Post.find(params[:id])
  end

  #####################################
  #Todo: Like機能作成後、ポスト・コメントの削除でLikeが削除されるか確認
  #####################################
  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to @post, notice: '編集できました'
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_url, notice: '削除できました'
  end

  private

  def post_params
    params.require(:post).permit(
      :text,
      :publishing_policy,
      :created_at,
      :updated_at
    ).merge(user_id: current_user.id)
  end
end
