class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
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
