class Patient < ActiveRecord::Base
  belongs_to :user
  enum gender: {male: 'MALE', female: 'FEMALE', other: 'OTHER'}

  validates :name, :date_of_birth, :relationship, presence: true
  RELATIONSHIPS = %w(Daughter Son Mother Father Uncle Brother Sister Friend Relative Other)
  validates :relationship, inclusion: RELATIONSHIPS


  def details
    {
      id: id,
      name: name,
      date_of_birth: date_of_birth,
      relationship: relationship,
      phone_no: phone_no,
      myself: myself,
      chronic_health_problems: chronic_health_problems,
      email: email,
      gender: gender
    }
  end
end
