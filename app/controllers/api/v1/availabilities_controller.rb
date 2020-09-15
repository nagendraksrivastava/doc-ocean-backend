class Api::V1::AvailabilitiesController < Api::BaseController

  def create
    availability = Availability.new(availability_params)
    availability.user = current_user
    if availability.save
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
    else
      render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY, availability.errors.full_messages.join(', '))}
    end
  end

  def create_multiple
    params.require(:address_id)
    params.require(:availabilities)

    address = current_user.addresses.find_by(id: params[:address_id])
    if address.present?
      params[:availabilities].each do |availability_params|
        availability = Availability.new(availability_params.permit(:day, :start_time, :end_time))
        availability.address = address
        availability.user = current_user
        availability.save
      end
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
    else
      render json: {status: StatusCode.response_message(StatusCode::INVALID_USER_ADDRESS)}
    end
  end

  def destroy
    availability = Availability.active.find_by(user_id: current_user.id, address_id: params[:address_id])
    if availability.present?
      availability.update_attribute(:status, Availability.statuses['inactive'])
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
    else
      render json: {status: StatusCode.response_message(StatusCode::NO_RECORD_FOUND)}
    end
  end

  private
    def availability_params
      params.require(:availability).permit(:address_id, :day, :start_time, :end_time)
    end
end
