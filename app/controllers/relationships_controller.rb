# frozen_string_literal: true

class RelationshipsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      @user = User.find(params[:relationship][:followed_id])
      current_user.follow(@user)
      redirect_to users_path
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @user = Relationship.find(params[:id]).followed
      current_user.unfollow(@user)
      redirect_to users_path
    end
  end
end
