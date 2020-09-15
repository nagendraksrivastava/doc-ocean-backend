class Locality < ActiveRecord::Base
  belongs_to :city

  enum status: {'active' =>  'active', 'inactive' => 'inactive'}
  validates :name, presence: true, uniqueness: {scope: :city_id, case_sensitive: false}
  validates :latitude, :longitude, :city_id, presence: true

end
