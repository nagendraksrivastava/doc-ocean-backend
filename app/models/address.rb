class Address < ActiveRecord::Base
  belongs_to :city
  belongs_to :locality
  belongs_to :user
  has_many :availabilities

  enum status: {'active' => 'active', 'disabled' => 'disabled'}
  validates :address_line, :user_id, presence: true

  def details
    response = {
      id: id,
      address_line: address_line,
      locality: locality.try(:name),
      locality_id: locality_id,
      city: city.try(:name),
      city_id: city_id,
      landmark: landmark,
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      phone_no: phone_no,
      tag: tag
    }

    if user.expert?
      availabilities = self.availabilities.map(&:details)
      response.merge!(timings: availabilities)
    end
    response
  end
end
