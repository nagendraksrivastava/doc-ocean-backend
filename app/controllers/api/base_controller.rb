class Api::BaseController < ApplicationController
  before_filter :authenticate_with_token!

  private
    def update_user_device(user = nil)
      UserDevice.add_or_update_device(user || current_user, params[:device_id])
    end
end
