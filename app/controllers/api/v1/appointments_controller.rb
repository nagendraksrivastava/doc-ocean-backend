class Api::V1::AppointmentsController < Api::BaseController
  before_filter :set_appointment, only: [:update_status, :your_rating, :show, :status]
  before_filter :add_new_patient, only: [:create]

  def index
    appointments = Appointment.with_user_scope(current_user).order('created_at desc').includes({patient: :user}, {expert_detail: :user}, {patient_address: :city}, {expert_address: :city})
    appointments = appointments.where(status: params[:status]) if params[:status].present?
    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      appointments: appointments.map{|appointment| appointment.details}
    }
  end

  def update_status
    params.require(:status)

    if @appointment.blank?
      render json:{
        status: StatusCode.response_message(StatusCode::NO_RECORD_FOUND)
      }
    else
      if @appointment.update_status(params[:status])
        render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
      else
        render json: {status: StatusCode.response_message(StatusCode::APPOINTMENT_STATUS_UPDATE_FAILED)}
      end
    end
  end

  def create
    params.require(:category_id)
    params.require(:profession_id)
    params.require(:opted_service_ids)

    appointment = Appointment.new(appointment_params)
    ActiveRecord::Base.transaction do
      appointment.profession_id = params[:profession_id]
      appointment.build_opted_services(params[:opted_service_ids], params[:profession_id], params[:category_id])
      appointment.add_patient_address(params[:patient_address]) if params[:patient_address_id].blank?
      unless appointment.save && (appointment.scheduled? || appointment.soft_assign_to_experts)
        raise ActiveRecord::Rollback
      end
    end
    render json: appointment.response_hash
  end

  def show
    if @appointment.present?
      render json: {
        status: StatusCode.response_message(StatusCode::SUCCESS),
        appointment: @appointment.details
      }
    else
      render json:{
        status: StatusCode.response_message(StatusCode::NO_RECORD_FOUND)
      }
    end
  end

  def status
    if @appointment.present?
      render json: {
        status: StatusCode.response_message(StatusCode::SUCCESS),
        appointment_status: @appointment.status
      }
    else
      render json:{
        status: StatusCode.response_message(StatusCode::NO_RECORD_FOUND)
      }
    end
  end

  def pending_rating
    appointment = Appointment.last_pending_rating(current_user)
    if appointment.present?
      render json: {
        status: StatusCode.response_message(StatusCode::SUCCESS),
        data: appointment.details
      }
    else
      render json: {
        status: StatusCode.response_message(StatusCode::NO_RECORD_FOUND)
      }
    end
  end

  def your_rating
    if @appointment.present?
      params.require(:value)
      if @appointment.add_rating(params[:value].to_i, params[:comments])
        render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
      else
        render json: {status: StatusCode.response_message(StatusCode::APPOINTMENT_RATING_FAILED)}
      end
    else
      render json:{
        status: StatusCode.response_message(StatusCode::NO_RECORD_FOUND)
      }
    end
  end

  def soft_assigned_appointment #Used for showing notification
    if current_user.expert?
      appointment = Appointment.find_by(number: params[:number], status: 'created')
      if appointment.present?
        render json: {
          status: StatusCode.response_message(StatusCode::SUCCESS),
          appointment: appointment.details
        }
        return
      end
    end
    render json:{
      status: StatusCode.response_message(StatusCode::NO_RECORD_FOUND)
    }
  end

  private
    def appointment_params
      params.require(:appointment).permit(:patient_id, :expert_detail_id, :profession_id,
        :patient_address_id, :expert_address_id, :scheduled_at, :instructions, :service_place, :symptoms)
    end

    def set_appointment
      params.require(:number)
      @appointment = Appointment.with_user_scope(current_user).find_by(number: params[:number])
    end

    def add_new_patient
      return if params[:patient_id].present?
      patient_params = params[:patient]
      render json: {status: StatusCode.response_message(StatusCode::PATIENT_DETAILS_REQUIRED)} and return if patient_params.blank? || (patient_params[:name].blank? || (patient_params[:age].blank? && patient_params[:date_of_birth].blank?))
      date_of_birth = Date.today - patient_params[:age].to_i.years if patient_params[:age].present?
      patient = current_user.patients.create!(name: patient_params[:name], date_of_birth: patient_params[:date_of_birth] || date_of_birth, relationship: patient_params[:relationship], gender: patient_params[:gender])
      params[:appointment][:patient_id] = patient.id
    end
end
