class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    end

    def check_user_login
      p '-------------------'
      p 'check_user_login is called!'
      unless current_user
        store_location
        flash[:alert] = 'ログインまたは新規登録が必要です'
        redirect_to new_user_registration_path
      end
    end

    # def check_author
    #   p '-------------------'
    #   p 'check_author is called!'
    #   if current_user.id = @post.user_id
    # end
end
