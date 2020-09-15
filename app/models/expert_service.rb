class ExpertService < ActiveRecord::Base
  belongs_to :category
  belongs_to :profession
  validates :name, :status, presence: true
  validate :category_and_profession_not_blank

  enum status: {active: 'active', inactive: 'inactive'}

  def details
    {
      id: id,
      name: name,
      cost: cost.to_f
    }
  end

  private
    def category_and_profession_not_blank
      if self.category_id.blank? && self.profession_id.blank?
        errors.add(:base, "Both category and profession can't be blank")
        false
      end
    end
end
