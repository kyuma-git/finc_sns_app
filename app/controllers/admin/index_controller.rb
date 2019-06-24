# frozen_string_literal: true

class Admin::IndexController < ApplicationController
  def index
    @users = User.where.not(is_admin: true)
  end

  def show
    @user = User.find(params[:id])
  end
end
