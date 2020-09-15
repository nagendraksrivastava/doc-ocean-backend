namespace :appointment do
  task clear_unassigned_appointments: :environment do
    Appointment.where(status: Appointment.statuses[:created]).
      where('created_at < ?', (Time.zone.now - GlobalSetting::AUTO_ASSIGN_FAIL_THRESHOLD)).each do |a|
      a.assign_fail!
    end
  end
end
