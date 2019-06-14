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
end
