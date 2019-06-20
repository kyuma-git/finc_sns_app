# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :check_user_login, only: %i[new edit delete]
  def index
    if current_user
      @posts = current_user.feed.order(created_at: :desc)
    else
      @posts = Post.where(publishing_policy: 1).order(created_at: :desc)
    end
  end

  def show
    if current_user
      @post = current_user.feed.find(params[:id])
      @comments = @post.comments
    else
      @post = Post.where(publishing_policy: 1).find(params[:id])
      @comments = @post.comments
    end
  end

  def new
    @post = Post.new
    3.times { @post.images.build }
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
    @post = current_user.feed.find(params[:id])
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
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_url
  end

  private

  def post_params
    params.require(:post).permit(
      :text,
      :publishing_policy,
      :created_at,
      :updated_at,
      images_attributes: [:image, :id]
    ).merge(user_id: current_user.id)
  end
end
