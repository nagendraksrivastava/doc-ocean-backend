class PostBookAppointmentCost
  def initialize(opted_services)
    @opted_services = opted_services
  end

  def charge_components(service_place)
    min_cost = min_appointment_cost
    charge_factor = AppointmentHelper.charge_factor(service_place, min_cost)
    components = @opted_services.map do |os|
      {name: os.service_name, cost: (charge_factor * os.cost.to_f).round(2)}
    end
    components << {name: 'Total', cost: total_cost(components)}
  end

  def min_appointment_cost
    @opted_services.inject(0.0) do |total, service|
      total += service.cost
    end
  end

  def total_cost(components)
    components.sum{|c| c[:cost]}.round(2)
  end

  def total(service_place)
    components = charge_components(service_place)
    total_cost(components).to_f.round(2)
  end
end
