class MakeExpertIdNotMandatoryInAppointment < ActiveRecord::Migration
  def change
    change_column_null(:appointments, :expert_detail_id, true)
  end
end
