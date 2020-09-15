class Api::V1::ProfessionsController < Api::BaseController
  def index
    render json: {
      status: StatusCode.response_message(StatusCode::SUCCESS),
      professions: Profession.includes(:categories).all.map{|p| p.details}
    }
  end
end
