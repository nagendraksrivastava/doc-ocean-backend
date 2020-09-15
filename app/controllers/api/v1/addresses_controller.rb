class Api::V1::AddressesController < Api::BaseController

  def index
    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      addresses: current_user.addresses.active.where('tag is not NULL and tag REGEXP ?', '^.+$').map{|a| a.details}
    }
  end

  def create
    address = current_user.addresses.build(address_params)
    if address.save
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS), address_id: address.id}
    else
      render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY)}
    end
  end

  def destroy
    address = current_user.addresses.find_by(id: params[:id])
    if address.present?
      address.update_attribute(:status, Address.statuses[:disabled])
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
    else
      render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY)}
    end
  end

  private
    def address_params
      params.require(:address).permit(:address_line, :locality_id, :city_id,
          :latitude, :longitude, :landmark, :tag)
    end
end
