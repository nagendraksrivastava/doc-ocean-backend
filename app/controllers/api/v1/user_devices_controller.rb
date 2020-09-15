class Api::V1::UserDevicesController < Api::BaseController
  skip_before_filter :authenticate_with_token!, only: [:create_or_update]

  def create_or_update
    params.require(:checksum)
    params.require(:device_id)
    params.require(:push_notification_reg_id)

    if UserDevice.valid_checksum?(params[:device_id], params[:checksum])
      user_device = UserDevice.find_or_initialize_by(device_id: params[:device_id])
      user_device.push_notification_reg_id = params[:push_notification_reg_id]
      if user_device.save
        render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
      else
        render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY)}
      end
    else
      render json: {status: StatusCode.response_message(StatusCode::USER_DEVICE_CHECKSUM_FAILED)}
    end
  end
end
