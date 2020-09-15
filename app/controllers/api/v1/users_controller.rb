class Api::V1::UsersController < Api::BaseController
  before_filter :authenticate_with_token!, except: [:create, :forgot_password]

  def create
    params.require(:device_id)
    user = User.new(user_params)
    if user.save && user.next!
      update_user_device(user)
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS), data: user.sign_in_response}
    else
      render json: { status: StatusCode.response_message(StatusCode::USER_FAILED_TO_CREATE, user.errors.full_messages.join(','))}
    end
  end

  def show
    render json: {status: StatusCode.response_message(StatusCode::SUCCESS), details: current_user.details}
  end

  def forgot_password
    params.require(:email)
    params.require(:type)

    user = User.find_by(email: params[:email], type: params[:type])
    if user.present?
      user.send_reset_password_instructions
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS, 'Password reset link has been mailed to you. Please check')}
    else
      render json: {status: StatusCode.response_message(StatusCode::LOGIN_NO_USER_FOUND)}
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :phone_no, :type, :date_of_birth, :gender)
    end
end
