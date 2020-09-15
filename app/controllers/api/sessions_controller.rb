class Api::SessionsController < Api::BaseController
  before_filter :authenticate_with_token!, except: [:create]

  def create
    params.require(:email)
    params.require(:password)
    params.require(:type)
    params.require(:device_id)
    user_password = params[:password]
    user_email = params[:email]
    user_type = params[:type].try(:upcase)
    user = user_email.present? && User.find_by(email: user_email, type: user_type)

    if user.blank?
      render json: {status: StatusCode.response_message(StatusCode::LOGIN_NO_USER_FOUND)}
    elsif user.valid_password?(user_password)
      sign_in user, store: false
      user.generate_authentication_token!
      user.login_status = User.login_statuses[:logged_in]
      update_user_device(user)
      user.save
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS), data: user.sign_in_response}
    else
      render json: {status: StatusCode.response_message(StatusCode::LOGIN_INVALID_EMAIL_OR_PASSWORD)}
    end
  end

  def destroy
    current_user.generate_authentication_token!
    current_user.login_status = User.login_statuses[:logged_out]
    if current_user.save
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
    else
      render json: {status: StatusCode.response_message(StatusCode::LOGOUT_FAILED)}
    end
  end
end
