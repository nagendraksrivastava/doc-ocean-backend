module Templates
  class PushNotification
    class << self
      def patient_appointment_confirm
        OpenStruct.new(
          title: "Appointment Confirmed",
          body: "Your appointment %s has been confirmed by our expert"
        )
      end

      def patient_appointment_complete
        OpenStruct.new(
          title: "Appointment Complete",
          body: "Your appointment %s has been completed by our expert"
        )
      end

      def patient_appointment_cancelled
        OpenStruct.new(
          title: "Appointment Cancelled",
          body: "Your appointment %s has been cancelled. Please contact customer support for any queries"
        )
      end

      def expert_appointment_cancelled
        OpenStruct.new(
          title: "Appointment Cancelled",
          body: "Your appointment %s has been cancelled by user"
        )
      end

      def expert_new_appointment
        OpenStruct.new(
          title: "New Scheduled Appointment",
          body: "You have got a scheduled appointment at %s"
        )
      end
    end
  end
end
