class City < ActiveRecord::Base
  has_many :localities

  enum status: {'active' =>  'active', 'inactive' => 'inactive'}
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  def active_loaclities
    localities.active.map do |l|
      {id: l.id, name: l.name, latitude: l.latitude.to_f, longitude: l.longitude.to_f}
    end
  end
end
