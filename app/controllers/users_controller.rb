# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.where.not(id: current_user.id).includes(:passive_relationships)
  end

  def show
    @user = User.find(params[:id])
    # このユーザのポスト一覧（余裕があったら作る）
    # @posts = @user.posts.paginate(page: params[:page])
  end

  def new
    new_user_session_path
  end

  def destroy
    destroy_user_session_path
  end

  #####################################################################
  # Todo: フォローしてるユーザ、フォローしてるユーザの取得（余裕があったら作る）
  # def following
  #     @user  = User.find(params[:id])
  #     @users = @user.following
  #     render 'show_follow'
  # end

  # def followers
  #   @user  = User.find(params[:id])
  #   @users = @user.followers
  #   render 'show_follower'
  # end
  #####################################################################
end
