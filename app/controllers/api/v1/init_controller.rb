class Api::V1::InitController < Api::BaseController
  skip_before_filter :authenticate_with_token!, only: [:on_start]

  def on_start
    params.require(:app_version)
    params.require(:app_type)

    latest_app_version = AppRelease.latest_app_version(params[:app_type])
    depreciated = AppRelease.app_version_depreciated?(params[:app_type], params[:app_version])

    status = if depreciated
      StatusCode.response_message(StatusCode::APP_VERSION_DEPRECIATED)
    else
      StatusCode.response_message(StatusCode::SUCCESS)
    end
    render json: {
      status: status,
      data: {
        latest_app_version: latest_app_version
      }
    }
  end

  def after_login
    data = {
      signup_pipeline: current_user.signup_pipeline
    }

    if current_user.normal?
      data.merge!(ongoing_appointments: current_user.confirmed_appointments.any?)
      data.merge!(on_demand_appointment_number: current_user.on_demand_in_progress_appointment.try(:number))
      data.merge!(rating_pending: Appointment.rating_pending?(current_user))
    end

    if current_user.expert?
      if current_user.complete?
        data.merge!(rating_pending: Appointment.rating_pending?(current_user))
      else
        signup_pipeline_data = current_user.signup_pipeline_data
        data.merge!(signup_pipeline_data: signup_pipeline_data) if signup_pipeline_data.present?
      end
    end

    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      data: data
    }
  end
end
