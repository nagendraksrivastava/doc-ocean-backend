class Category < ActiveRecord::Base
  belongs_to :profession
  enum status: {active: 'active', inactive: 'inactive'}
end
