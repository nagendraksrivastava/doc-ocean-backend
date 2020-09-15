class VisitorsController < ApplicationController
  def signup_request
    SignupRequest.create(expert_params)
    redirect_to root_path, message: "Thank you for your request. Will reach you soon"
  end

  private
    def expert_params
      params.require(:expert).permit(:full_name, :email, :mobile, :profession)
    end
end
