module Authenticable

  # Devise methods overwrites
  def current_user
    return @current_user if @current_user.present?

    @current_user = if request.headers['Authorization'].present?
      User.find_by(auth_token: request.headers['Authorization'])
    else
      super
    end
    ActiveRecord::Base.current_user = @current_user
    @current_user
  end

  def authenticate_with_token!
    render json: {status: StatusCode.response_message(StatusCode::INCORRECT_AUTHENTICATION)} unless current_user.present?
  end
end
