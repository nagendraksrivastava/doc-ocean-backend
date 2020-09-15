class Api::V1::ExpertDetailsController < Api::BaseController
  #before_filter :current_user_expert?

  def create
    if current_user.expert? && current_user.expert_detail.blank?
      current_user.build_expert_detail(expert_detail_params)
      if current_user.save
        render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
      else
        render json: {status: StatusCode.response_message(StatusCode::UNPROCESSABLE_ENTITY)}
      end
    else
      render json: {status: StatusCode.response_message(StatusCode::USER_IS_NOT_EXPERT)}
    end
  end

  def nearest_experts
    params.require(:latitude)
    params.require(:longitude)
    params.require(:profession_id)
    params.require(:category_id)
    params.permit(:latitude, :longitude, :profession_id, :category_id)
    params.require(:opted_service_ids)

    location = [params[:latitude].to_f, params[:longitude].to_f]
    options = {profession_id: params[:profession_id], category_id: params[:category_id], opted_service_ids: params[:opted_service_ids]}
    options[:time] = Time.zone.parse(params[:schedule_time]) if params[:schedule_time].present?
    render json: ExpertDetail.nearest_available_experts(location, options)
  end

  def ping_update
    params.require(:latitude)
    params.require(:longitude)

    current_user.expert_detail.ping_update(params)
    render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
  end

  def pending_appointments
    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      data: current_user.pending_appointments
    }
  end

  def appointments
    appointments = Appointment.with_user_scope(current_user).order('created_at desc').includes({patient: :user}, {expert_detail: :user}, {patient_address: :city}, {expert_address: :city})
    appointments = appointments.where(status: params[:status]) if params[:status].present?
    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      appointments: appointments.map{|appointment| appointment.details}
    }
  end

  def services
    if params[:profession_id] || params[:category_id]
      services = ExpertService.active.where('profession_id = ? AND (category_id = ? OR category_id IS NULL)', params[:profession_id], params[:category_id])
      render json: {
        status: StatusCode.response_message(StatusCode::SUCCESS),
        services: services.map(&:details)
      }
    else
      render json: {
        status: StatusCode.response_message(StatusCode::BAD_REQUEST)
      }
    end
  end

  private
    def expert_detail_params
      params.require(:expert_detail).permit(:profession_id, :license_no,
                      :consulting_fee, :specialization_list, :degree_list)
    end

    def current_user_expert?
      unless current_user.expert?
        render json: {
          status: StatusCode.response_message(StatusCode::USER_IS_NOT_EXPERT)
        }
        return
      end
    end

end
