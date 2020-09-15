class  Api::V1::NotificationsController < Api::BaseController
  before_filter :set_notification

  def received
    ActiveRecord::Base.transaction do
      if @notification.received? || @notification.receive!
        render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
      else
        render json: {status: StatusCode.response_message(StatusCode::INVALID_NOTIFICATION_STATUS_TRANSITION)}
      end
    end
  end

  def accept
    ActiveRecord::Base.transaction do
      if @notification.accepted? || @notification.accept!
        render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
      else
        @notification.reject!
        render json: {status: StatusCode.response_message(StatusCode::NOTIFICATION_FAILED_TO_UPDATE)}
      end
    end
  end

  def reject
    ActiveRecord::Base.transaction do
      if @notification.rejected? || @notification.reject!
        render json: {status: StatusCode.response_message(StatusCode::SUCCESS)}
      else
        render json: {status: StatusCode.response_message(StatusCode::NOTIFICATION_FAILED_TO_UPDATE)}
      end
    end
  end

  private
    def set_notification
      @notification = Notification.find_by(user_id: current_user.id, id: params[:id])
      unless @notification
        render json: {status: StatusCode.response_message(StatusCode::INVALID_NOTIFICATION)}
        return
      end
    end
end
