class PreBookAppointmentCost
  def initialize(expert_service_ids, profession_id, category_id)
    @services = ExpertService.where(id: expert_service_ids, profession_id: profession_id)
  end

  def calculate
    min_cost = min_appointment_cost
    visiting_charge_factor = AppointmentHelper.visiting_charge_factor(min_cost)
    {
      EXPERT_PLACE: min_cost.to_f.round(2),
      PATIENT_PLACE: (min_cost * visiting_charge_factor).to_f.round(2)
    }
  end

  def min_appointment_cost
    @services.inject(0.0) do |total, service|
      total += service.cost
    end
  end
end
