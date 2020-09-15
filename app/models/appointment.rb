class Appointment < ActiveRecord::Base
  include AASM
  APPOINTMENT_NUMBER_PREFIX = "APT-"
  enum service_type: {on_demand: 'on_demand', schedule: 'scheduled'}
  belongs_to :patient
  belongs_to :expert_detail
  belongs_to :patient_address, class_name: Address
  belongs_to :expert_address, class_name: Address
  has_one :rating, -> {where rated_by: current_user.id}
  has_many :opted_expert_services, autosave: true
  attr_accessor :profession_id

  validates :patient_id, :patient_address_id, :status, presence: true
  validate :valid_user?, on: :create
  validate :valid_schedule_time?, on: :create
  before_create :generate_appointment_number
  after_create :schedule!, if: :scheduled?
  after_create :compute_total_cost
  attr_accessor :response_hash

  enum status: {created: 'created', scheduled: 'scheduled', confirmed: 'confirmed',
    en_route: 'en_route', completed: 'completed', cancelled: 'cancelled', assign_failed: 'assign_failed', rejected: 'rejected' }

  aasm column: :status, whiny_transitions: false, enum: true do
    state :created, initial: true
    state :scheduled
    state :confirmed
    state :en_route
    state :completed
    state :cancelled
    state :assign_failed
    state :rejected

    event :confirm do
      transitions from: [:created, :scheduled], to: :confirmed,
          guards: [:expert_user?], before: [:set_confirmed_at], after: [:send_confirm_notification]
    end

    event :en_route do
      transitions from: :confirmed, to: :en_route, guards: [:expert_user?]
    end

    event :schedule do
      transitions from: :created, to: :scheduled, guards: [:scheduled?]
    end

    event :reject do
      transitions form: :scheduled, to: :rejected, guards: [:expert_user?]
    end

    event :complete do
      transitions from: [:confirmed, :en_route], to: :completed,
          guards: [:expert_user?], before: [:set_completed_at], after: [:send_complete_notification]
    end

    event :cancel do
      after do
        send_cancelled_notification
      end
      transitions from: [:created, :confirmed], to: :cancelled
      transitions from: :en_route, to: :cancelled, guards: [:expert_user?]
    end

    event :assign_fail do
      transitions from: [:created, :scheduled], to: :assign_failed
    end
  end

  def self.pending_statuses
    ['scheduled', 'confirmed', 'en_route']
  end

  def self.terminal_statuses
    ['cancelled', 'completed', 'assign_failed', 'rejected']
  end

  def confirmed?
    self.confirmed_at.present?
  end

  def scheduled?
    self.scheduled_at.present?
  end

  def service_type
    scheduled? ? Appointment.service_types[:schedule] : Appointment.service_types[:on_demand]
  end

  def details
    resp = {
      number: number,
      patient_name: patient.name,
      patient_gender: patient.gender,
      service_place: service_place,
      patient_age: 26,
      status: status,
      symptoms: symptoms,
      chronic_health_problems: patient.chronic_health_problems,
      instructions: instructions,
      created_at: created_at.strftime('%d-%m-%Y %H:%M'),
      opted_services: opted_services_detail,
      charge_components: charge_components,
      total_cost: self.total_cost.to_f.round(2),
      payment_mode: 'COD',
      distance: 2
    }

    resp.merge!(scheduled_at: scheduled_at.strftime('%d-%m-%Y %H:%M')) if scheduled?
    resp.merge!(confirmed_at: confirmed_at.strftime('%d-%m-%Y %H:%M')) if confirmed?
    resp.merge!(your_rating: {value: (rating.try(:value) || 0), comments: rating.try(:comments)}) if completed?
    if current_user.normal? && self.expert_address
      expert_address = self.expert_address
      expert_info = {
        image_url: expert_detail.user.image_url(:thumb),
        degree_list: expert_detail.degree_list.join(', '),
        specialization_list: expert_detail.specialization_list.join(', '),
        name: expert_detail.user.name,
        phone_no: expert_detail.user.phone_no,
        profession_code: expert_detail.profession.code,
        address: {
          address_line: expert_address.address_line,
          city: expert_address.city.try(:name),
          latitude: expert_address.latitude.to_f,
          longitude: expert_address.longitude.to_f
        }
      }

      if self.service_place == ExpertDetail.service_places[:PATIENT_PLACE] && self.confirmed?
        current_location = self.expert_detail.current_location
        expert_info[:current_location] = {
          latitude: current_location[0],
          longitude: current_location[1]
        }
      end

      resp[:expert] = expert_info
    end

    if current_user.expert?
      resp[:patient_address] = {
        address_line: patient_address.address_line,
        city: patient_address.city.try(:name),
        latitude: patient_address.latitude.to_f,
        longitude: patient_address.longitude.to_f
      }
    end
    resp
  end

  def opted_services_detail
    opted_expert_services.map do |s|
      {name: s.service_name, cost: s.cost.to_f.round(2)}
    end
  end

  def charge_components
    PostBookAppointmentCost.new(opted_expert_services).charge_components(self.service_place)
  end

  def update_status(action)
    self.class.allowed_update_events.include?(action.to_sym) &&
      self.send(action) && self.save
  end

  def add_rating(value, comments=nil)
    return false if !self.completed? || self.rating
    rating_to = current_user.expert? ? self.patient.user : self.expert_detail.user
    rating = self.build_rating(user: rating_to, value: value, comments: comments)
    rating.save
  end

  def assign_expert_if_not_present
    options = {}
    options[:profession_id] = self.profession_id
    options[:time] = self.scheduled_at if scheduled_at.present?
    location = [self.patient_address.latitude.to_f, self.patient_address.longitude.to_f]

    response = ExpertDetail.nearest_available_expert(location, options)
    if response[:status][:code] == StatusCode::SUCCESS
      self.expert_detail_id = response[:expert][:expert_detail_id]
      self.expert_address_id = response[:expert][:address][:id]
    end
  end

  def soft_assign_to_experts
    options = {}
    options[:profession_id] = self.profession_id
    options[:time] = self.scheduled_at if scheduled_at.present?
    location = [self.patient_address.latitude.to_f, self.patient_address.longitude.to_f]

    experts = ExpertDetail.available_experts(location, options)
    if experts.present?
      send_broadcast_notification(experts)
      self.response_hash = {status: StatusCode.response_message(StatusCode::SUCCESS), data: self.details}
      true
    else
      self.response_hash = {status: StatusCode.response_message(StatusCode::NO_EXPERTS_AVAILABLE)}
      false
    end
  end

  def send_broadcast_notification(experts)
    if experts.present?
      experts.each do |ex|
        expert = ex[:expert_detail]
        availability = ex[:availability]
        data = {availability_id: availability.id, address_id: availability.address_id}
        notification_content = new_appointment_notification_content
        data.merge!(notification_content: notification_content) if notification_content.present?
        send_notification(expert.user_id, data)
      end
    end
  end

  def self.with_user_scope(user)
    appointment_scope = Appointment.order('created_at desc')
    if user.expert?
      appointment_scope.where(expert_detail_id: user.expert_detail.id)
    else
      appointment_scope.where(patient_id: user.patient_ids)
    end
  end

  def self.rating_pending?(user)
    rating_pending_scope(user).any?
  end

  def self.last_pending_rating(user)
    rating_pending_scope(user).last
  end

  def on_notification_accept(notification)
    self.expert_detail = notification.user.expert_detail
    address_id = notification.data[:address_id]
    self.expert_address_id = address_id
    self.confirmed_at = Time.zone.now
    self.confirm!
  end

  def on_all_notfications_failed(notification)
    self.assign_fail!
  end

  def send_notification(user_id, data)
    CommandNotification.create(code: CommandNotification::EXPERT_NEW_APPOINTMENT,
      notifiable_type: self.class.to_s, notifiable_id: self.id, user_id: user_id, data: data)
  end

  def build_opted_services(opted_service_ids, profession_id, category_id)
    ExpertService.where(id: opted_service_ids, profession_id: profession_id, category_id: category_id).each do |es|
      self.opted_expert_services.build(service_id: es.id, service_name: es.name, cost: es.cost.to_f)
    end
  end

  def add_patient_address(patient_address)
    if patient_address.blank?
      errors.add(:base, StatusCode::MESSAGES[StatusCode::APPOINTMENT_PATIENT_ADDRESS_BLANK_ERROR])
      self.response_hash = {status: StatusCode.response_message(StatusCode::APPOINTMENT_PATIENT_ADDRESS_BLANK_ERROR)}
    else
      address = self.build_patient_address(patient_address.to_hash)
      address.user_id = current_user.id
      unless address.save
        error_message = address.errors.full_messages.join(', ')
        errors.add(:base, error_message)
        self.response_hash = {status: StatusCode.response_message(StatusCode::APPOINTMENT_INVALID_PATIENT_ADDRESS, error_message)}
        return
      end
      self.patient_address_id = address.id
    end
  end

  private
    def generate_appointment_number
      exists = true
      while exists do
        random = "#{APPOINTMENT_NUMBER_PREFIX}#{Array.new(5){rand(10)}.join}"
        exists = Appointment.where(number: random).count > 0 ? true : false
      end
      self.number = random
    end

    def valid_user?
      if !current_user.normal?
        errors.add(:base, 'Invalid user for booking appointment')
        false
      elsif !current_user.patient_ids.include?(self.patient_id)
        errors.add(:base, 'Patient doesn\'t belongs to user')
        false
      else
        true
      end
    end

    def expert_user?
      current_user.expert?
    end

    def set_confirmed_at
      confirmed_at = Time.zone.now
    end

    def set_completed_at
      completed_at = Time.zone.now
    end

    def self.allowed_update_events
      aasm.events.map(&:name)
    end

    def valid_schedule_time?
      return true if self.scheduled_at.blank?

      if self.scheduled_at < 3.hours.from_now
        errors.add(:base, StatusCode::MESSAGES[StatusCode::APPOINTMENT_SCHEDULE_TIME_PAST])
        self.response_hash = {status: StatusCode.response_message(StatusCode::APPOINTMENT_SCHEDULE_TIME_PAST)}
        return false
      end
      true
    end

    def compute_total_cost
      self.total_cost = PostBookAppointmentCost.new(opted_expert_services).total(self.service_place)
      self.save!
    end

    def self.rating_pending_scope(user)
      Appointment.with_user_scope(user).completed.
        joins('left join ratings on ratings.appointment_id = appointments.id').
        where('ratings.id' => nil)
    end

    def send_confirm_notification
      pn_template = Templates::PushNotification.patient_appointment_confirm
      pn_body = pn_template.body % [self.number]
      NotificationWorker.perform_async(self.patient.user_id, NotificationService::PUSH,
          {title: pn_template.title, body: pn_body})
    end

    def send_complete_notification
      pn_template = Templates::PushNotification.patient_appointment_complete
      pn_body = pn_template.body % [self.number]
      NotificationWorker.perform_async(self.patient.user_id, NotificationService::PUSH,
          {title: pn_template.title, body: pn_body})
    end

    def send_cancelled_notification
      if current_user
        if current_user.expert?
          pn_template = Templates::PushNotification.patient_appointment_cancelled
          pn_body = pn_template.body % [self.number]
          NotificationWorker.perform_async(self.patient.user_id, NotificationService::PUSH,
            {title: pn_template.title, body: pn_body})
        elsif current_user.normal? && self.expert_detail.present?
          pn_template = Templates::PushNotification.expert_appointment_cancelled
          pn_body = pn_template.body % [self.number]
          NotificationWorker.perform_async(self.expert_detail.user_id, NotificationService::PUSH,
            {title: pn_template.title, body: pn_body})
        end
      end
    end

    def new_appointment_notification_content
      content = {}
      if self.scheduled?
        template = Templates::PushNotification.expert_new_appointment
        content[:body] = template.body % [self.scheduled_at.strftime("%d-%h %H:%M")]
      end
      content
    end
end
