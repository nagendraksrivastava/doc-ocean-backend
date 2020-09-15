class ExpertTracking
  include Mongoid::Document
  include Mongoid::Timestamps

  field :expert_detail_id, type: Integer
  field :profession_id, type: Integer
  field :locations, type: Array, default: [[0.0, 0.0]]
  field :current_location, type: Array, default: [0.0, 0.0]
  field :status, type: String
  field :locality_ids, type: Array, default: []
  field :last_ping_at, type: Time
  field :online, type: Boolean, default: false
  field :gender, type: String, default: ""
  field :category_ids, type: Array, default: []
  field :service_place, type: String, default: ""

  index({locations: "2d"})
  index({expert_detail_id: 1})
  index({profession_id: 1})
  index({category_ids: 1})
  index({service_place: 1})
end
