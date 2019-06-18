# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # deviseのsign_upパラメータにnameを追加する記述
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def check_user_login
    unless current_user
      store_location
      flash[:alert] = 'ログインまたは新規登録が必要です'
      redirect_to new_user_registration_path
    end
  end
end
