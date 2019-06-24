# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :check_user_login, only: %i[new edit delete]
  def index
    if current_user
      logged_in_user_feed_posts
    else
      unlogged_in_user_feed_posts
    end
  end

  def show
    if current_user
      @post = logged_in_user_feed_posts.find(params[:id])
      @comments = @post.comments
    else
      @post = Post.where(publishing_policy: :unlimited).find(params[:id])
      @comments = @post.comments
    end
  end

  def new
    @post = Post.new
    Constants::IMAGE_MAX_LENGTH.times { @post.images.build }
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post
    else
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])
    unless author?(@post)
      redirect_to post_path(@post)
      flash[:alert] = '編集、削除の権限はありません'
    end
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  def destroy
    post = Post.find(params[:id])
    unless author?(@post)
      redirect_to post_path(@post)
      flash[:alert] = '編集、削除の権限はありません'
    end
    post.destroy
    redirect_to posts_url
  end

  private

  def post_params
    params.require(:post).permit(
      :text,
      :publishing_policy,
      :created_at,
      :updated_at,
      images_attributes: %i[image id]
    ).merge(user_id: current_user.id)
  end
end
