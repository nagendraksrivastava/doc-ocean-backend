class Api::V1::SignUpFlowController < Api::BaseController

  def expert_detail
    ActiveRecord::Base.transaction do
      if current_user.expert? && current_user.expert_detail.blank?
        expert_detail = current_user.build_expert_detail(expert_detail_params)
        image_params = params[:expert_detail][:image]
        if image_params.present?
          image_decoder = ImageDecoder.new(image_params)
          result = image_decoder.process
          if result.success
            image = current_user.build_image
            image.attachment = result.image
            image.save
            image_decoder.delete_tmp_file
          end
        end

        if current_user.user_info? && current_user.next!
          render json: {
            status: StatusCode.response_message(StatusCode::SUCCESS),
            signup_pipeline: current_user.signup_pipeline
          }
          return
        end
      end
      render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY), errors: current_user.errors.full_messages}
      raise ActiveRecord::Rollback
    end
  end

  def address
    success = true
    ActiveRecord::Base.transaction do
      address = current_user.addresses.build(address_params)
      success &&= address.save
      if success && params[:address][:availabilities].present?
        params[:address][:availabilities].each do |availability|
          availability = address.availabilities.build(availability.permit(:day, :start_time, :end_time))
          availability.user = current_user
          success &&= availability.save
          break unless success
        end
      end
      if success && current_user.address? && current_user.next!
        render json: {
          status: StatusCode.response_message(StatusCode::SUCCESS),
          address_id: address.id,
          signup_pipeline: current_user.signup_pipeline
        }
      else
        render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY)}
        raise ActiveRecord::Rollback
      end
    end
  end

  def availabilities
    params.require(:address_id)
    params.require(:availabilities)

    address = current_user.addresses.find_by(id: params[:address_id])
    if address.present?
      ActiveRecord::Base.transaction do
        params[:availabilities].each do |availability_params|
          availability = Availability.new(availability_params.permit(:day, :start_time, :end_time))
          availability.address = address
          availability.user = current_user
          availability.save
        end
        if current_user.availability? && current_user.next!
          render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
        else
          render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY)}
          raise ActiveRecord::Rollback
        end
      end
    else
      render json: {status: StatusCode.response_message(StatusCode::INVALID_USER_ADDRESS)}
    end
  end

  private
    def address_params
      params.require(:address).permit(:address_line, :locality_id, :city_id,
          :latitude, :longitude, :landmark, :tag, :phone_no)
    end

    def expert_detail_params
      params.require(:expert_detail).permit(:profession_id, :license_no,
                      :consulting_fee, :specialization_list, :degree_list, :service_place)
    end

end
