class Profession < ActiveRecord::Base
  has_many :categories

  def details
    {
      id: id,
      code: code,
      name: name,
      categories: categories.map do |c|
        {
          id: c.id,
          code: c.code,
          name: c.name
        }
      end
    }
  end
end
