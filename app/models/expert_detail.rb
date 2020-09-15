class ExpertDetail < ActiveRecord::Base
  acts_as_taggable_on :specializations
  acts_as_taggable_on :degrees

  belongs_to :profession
  belongs_to :user, -> {where('type = ?', User.types[:expert])}
  serialize :category_ids

  enum service_place: {"EXPERT_PLACE": "EXPERT_PLACE", "PATIENT_PLACE": "PATIENT_PLACE", "ALL": "ALL"}

  after_save :add_or_update_details_in_mongo
  SEARCH_RADIUS = 3


  def category_ids=(comma_separated_ids)
    self[:category_ids] = (comma_separated_ids || "").split(',').map(&:strip).map(&:to_i)
  end

  def add_or_update_details_in_mongo
    expert_tracking = ExpertTracking.find_or_initialize_by(expert_detail_id: self.id)
    addresses = self.user.addresses
    expert_tracking.profession_id = profession_id
    expert_tracking.locations = addresses.map{|a| [a.latitude.to_f, a.longitude.to_f]}
    expert_tracking.locality_ids = addresses.map(&:locality_id)
    expert_tracking.online = true
    expert_tracking.status = 'active'
    expert_tracking.service_place = service_place
    expert_tracking.gender = user.gender || ''
    expert_tracking.category_ids = self.category_ids
    expert_tracking.save!
  end

  def update_online_status(online)
    expert_tracking = ExpertTracking.find_or_initialize_by(expert_detail_id: self.id)
    expert_tracking.online = online
    expert_tracking.save!
  end

  def ping_update(data)
    expert_tracking = ExpertTracking.find_by(expert_detail_id: self.id)
    expert_tracking.current_location = [data[:latitude].to_f, data[:longitude].to_f]
    if data[:status].present?
      expert_tracking.online = (data[:status] == 'online' ? true : false)
    end
    expert_tracking.last_ping_at = Time.zone.now
    expert_tracking.save
  end

  def self.nearest_available_experts(location, options = {})
    time = options[:time] || Time.zone.now
    experts_with_availability = available_experts(location, options)
    experts = experts_with_availability.map do |details|
      OnDemandResponse.new(details[:expert_detail], details[:availability], options).response
    end
    return {status: StatusCode.response_message(StatusCode::SUCCESS), experts: experts, appointment_costs: ExpertDetail.appointment_costs(options)} if experts.present?
    return {status: StatusCode.response_message(StatusCode::NO_EXPERTS_AVAILABLE_FOR_SCHEDULE_TIME)} if options[:time].present?
    return {status: StatusCode.response_message(StatusCode::NO_EXPERTS_AVAILABLE)}
  end

  def self.available_experts(location, options = {})
    usable_experts = nerest_usable_experts(location, options)
    time = options[:time] || Time.zone.now
    if usable_experts.present?
      experts = ExpertDetail.joins(:user => {:addresses => :availabilities}).
        where('expert_details.id IN (?)', usable_experts.map{|ue| ue.expert_detail_id}).
        where('availabilities.day = ? and availabilities.start_time <= ? and availabilities.end_time > ?', time.strftime('%^a'), time.strftime('%H:%M'), (time + 5.minutes).strftime('%H:%M')).all.
        includes(:profession, :degrees, :specializations, {:user => [:image, {:addresses => [:city, :locality, :availabilities]}]})
      experts.map do |expert_detail|
        availability = expert_detail.availability(time)
        {expert_detail: expert_detail, availability: availability} if availability
      end
    else
      []
    end
  end

  def self.nerest_usable_experts(location, options = {})
    usable_experts = ExpertTracking.where(online: true, status: 'active')
    usable_experts = usable_experts.where(profession_id: options[:profession_id].to_i) if options[:profession_id]
    usable_experts = usable_experts.where(:category_ids.all => Array(options[:category_id].to_i)) if options[:category_id]
    usable_experts = usable_experts.or({service_place: options[:service_place]}, {service_place: ExpertDetail.service_places["ALL"]}) if options[:service_place]
    usable_experts.geo_near(location).max_distance(UnitConverter.km_to_geospace(ExpertDetail::SEARCH_RADIUS))
  end

  def self.nearest_available_expert(location, options = {})
    response = nearest_available_experts(location, options)
    if response[:status][:code] == StatusCode::SUCCESS
      expert = response[:experts].values.flatten.first
      {status: StatusCode.response_message(StatusCode::SUCCESS), expert: expert}
    else
      {status: StatusCode.response_message(StatusCode::NO_EXPERTS_AVAILABLE)}
    end
  end

  def self.expert_available_for_schedule_time(location, time, options)
    options[:time] = time
    experts_with_availability = available_experts(location, options)
    if experts_with_availability.present?
      {status: StatusCode.response_message(StatusCode::SUCCESS), experts_with_availability: experts_with_availability}
    else
      {status: StatusCode.response_message(StatusCode::NO_EXPERTS_AVAILABLE_FOR_SCHEDULE_TIME)}
    end
  end

  def details
    resp = user.details
    resp.merge!(expert_detail_id: id, rating: user.average_rating)
    resp = resp.merge!(resp.delete(:expert_detail))
    resp.merge!(address: user.addresses[0].details)
  end

  def availability(time)
    Availability.active.where('day = ? and start_time <= ? and end_time > ? and user_id = ?',
      time.strftime('%^a'), time.strftime('%H:%M'), (time + 5.minutes).strftime('%H:%M'), self.user.id).first
  end

  def self.appointment_costs(options)
    PreBookAppointmentCost.new(options[:opted_service_ids], options[:profession_id], options[:category_id]).calculate
  end

  def current_location
    ExpertTracking.find_by(expert_detail_id: self.id).try(:location) || [0, 0]
  end

  def ui_service_place
    case service_place
    when ExpertDetail.service_places['ALL']
      'Expert place, Patient place'
    when ExpertDetail.service_places['EXPERT_PLACE']
      'Expert place'
    when ExpertDetail.service_places['PATIENT_PLACE']
      'Patient place'
    end
  end
end
