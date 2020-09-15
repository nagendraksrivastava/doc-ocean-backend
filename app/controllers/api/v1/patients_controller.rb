class Api::V1::PatientsController < Api::BaseController

  def index
    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      patients: current_user.patients.map{|patient| patient.details}
    }
  end

  def relationships
    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      relationships: Patient::RELATIONSHIPS
    }
  end

  def create
    patient = current_user.patients.build(patient_params)
    if patient.save
      render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
    else
      render json: {status: StatusCode.response_message(StatusCode::PATIENT_CREATION_FAILED)}
    end
  end

  private
    def patient_params
      params.require(:patient).permit(:name, :date_of_birth, :phone_no, :relationship, :chronic_health_problems, :email, :gender)
    end
end
