# frozen_string_literal: true

class Admin::IndexController < ApplicationController
  def index
    @users = User.where(is_admin: false)
  end

  def show
    @user = User.find(params[:id])
  end
end
