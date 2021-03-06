# frozen_string_literal: true
require "post.rb"

class PostsController < ApplicationController
  before_action :check_user_login, only: %i[new edit delete]
  def index
    if current_user
      @posts = Post.new().logged_in_user_feed_posts(current_user).page(params[:page]).includes(:user, :images)
      @post = Post.new
      Post::IMAGE_MAX_LENGTH.times { @post.images.build }
    else
      @posts = Post.new().unlogged_in_user_feed_posts.page(params[:page])
    end
  end

  def show
    if current_user
      @post = Post.new().logged_in_user_feed_posts(current_user).find(params[:id])
      @comments = @post.comments
    else
      @post = Post.where(publishing_policy: :unlimited).find(params[:id])
      @comments = @post.comments
    end
  end

  def new
    @post = Post.new
    Post::IMAGE_MAX_LENGTH.times { @post.images.build }
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      render json: @post, status: 200
    else
      @errors = @post.errors.full_messages
      render json: @errors, status: 422
    end
  end

  def edit
    @post = Post.find(params[:id])
    Post::IMAGE_MAX_LENGTH.times { @post.images.build }
    unless @post.author?(@post, current_user)
      redirect_to post_path(@post)
      flash[:alert] = '編集、削除の権限はありません'
    end
  end

  def update
    @post = Post.find(params[:id])
    unless @post.author?(@post, current_user)
      redirect_to post_path(@post)
      flash[:alert] = '編集、削除の権限はありません'
    end
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  def destroy
    post = Post.find(params[:id])
    unless post.author?(post, current_user)
      flash[:alert] = '編集、削除の権限はありません'
      return redirect_to post_path(post)
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
