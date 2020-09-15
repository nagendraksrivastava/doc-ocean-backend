module AppointmentHelper
  def self.charge_factor(service_place, min_cost)
    if service_place == ExpertDetail.service_places['EXPERT_PLACE']
      1
    else
      visiting_charge_factor(min_cost)
    end
  end

  def self.visiting_charge_factor(min_cost)
    if min_cost > 1000
      1.3
    elsif min_cost > 500
      1.5
    else
      2
    end
  end
end
