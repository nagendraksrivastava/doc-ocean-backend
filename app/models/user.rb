class User < ActiveRecord::Base
  rolify
  include AASM
  self.inheritance_column = nil

  has_many :patients
  has_many :addresses
  has_one :expert_detail
  has_many :ratings
  has_one :image, as: :imageable
  accepts_nested_attributes_for :image

  enum type: {expert: 'EXPERT', normal: 'NORMAL', internal: 'INTERNAL'}
  enum role: [:user, :vip, :admin]
  enum gender: {male: 'MALE', female: 'FEMALE', other: 'OTHER'}
  enum login_status: {logged_in: 'logged_in', logged_out: 'logged_out'}

  validates :auth_token, uniqueness: true
  validates :phone_no, uniqueness: { scope: [:type, :email]}

  before_create :generate_authentication_token!
  after_initialize :set_default_role, :if => :new_record?
  after_create :add_myself_patient
  after_save do |u|
    if u.changes[:login_status].present? && u.expert? && u.expert_detail.present?
      online = u.login_status == User.login_statuses[:logged_in]
      u.expert_detail.update_online_status(online)
    end
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  aasm column: :signup_pipeline, :whiny_transitions => false do
   state :login, initial: true
   state :user_info
   state :address
   state :availability
   state :complete

   event :next do
     transitions from: :login, to: :user_info
     transitions from: :user_info, to: :address
     transitions from: :address, to: :availability
     transitions from: :availability, to: :complete
   end
  end

  def generate_authentication_token!
   begin
     self.auth_token = Devise.friendly_token
   end while self.class.exists?(auth_token: auth_token)
  end

  def set_default_role
   self.role ||= :user
  end

  def add_myself_patient
    return unless self.normal?
    self.patients.create!(name: name, date_of_birth: date_of_birth, phone_no: phone_no, myself: true, relationship: 'Other', gender: gender)
  end

  def details
    resp = {
      name: name,
      email: email,
      phone_no: phone_no,
      image_url: image_url(:thumb),
      gender: gender,
      city: 'Bengaluru',
      country: 'India'
    }
    if self.expert?
      resp.merge! expert_detail: {
        profession: expert_detail.profession.name,
        degree_list: expert_detail.degree_list,
        specialization_list: expert_detail.specialization_list,
        license_no: expert_detail.license_no,
        consulting_fee: expert_detail.consulting_fee.to_f,
        service_place: expert_detail.ui_service_place
      }
    end
    resp
  end

  def sign_in_response
    {
      auth_token: auth_token,
      name: name,
      email: email,
      phone_no: phone_no,
      image_url: image_url(:thumb),
      signup_pipeline: signup_pipeline
    }
  end

  def confirmed_appointments
    Appointment.with_user_scope(self).where(status: 'confirmed')
  end

  def on_demand_in_progress_appointment
    Appointment.with_user_scope(self).where.not(status: Appointment.terminal_statuses).where(scheduled_at: nil).last
  end

  def average_rating
    Rails.cache.fetch("rating-#{self.id}") do
      recent_ratings = ratings.order('id desc').limit(20).map(&:value)
      if recent_ratings.present?
        recent_ratings.reduce(:+) / recent_ratings.size.to_f
      else
        5.0
      end
    end
  end

  def image_url(style = :thumb)
    image.present? ? URI.join(Settings.host, image.url(style)).to_s : nil
  end

  def pending_appointments
    appointments = Appointment.with_user_scope(self).
      includes({patient: :user}, {expert_detail: :user}, {patient_address: :city}, {expert_address: :city}).
      where(status: Appointment.pending_statuses)
    appointments_with_status = appointments.group_by{|appointment| appointment.status}
    appointments_with_status.inject({}) do |response, (status, appointments)|
      response[status] = appointments.map{|appointment| appointment.details}
      response
    end
  end

  def valid_user_device
    UserDevice.find_by(user_id: self.id, status: UserDevice::statuses['active'])
  end

  def signup_pipeline_data
    if current_user.availability?
      address = current_user.addresses.first
      {address: address.details}
    else
      {}
    end
  end
end
