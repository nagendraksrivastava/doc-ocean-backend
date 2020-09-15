ActiveAdmin.register ExpertDetail do
  actions :all, except: [:new, :destroy]
  permit_params :category_ids

  form do |f|
    inputs 'Details' do
      input :category_ids, label: 'Category', as: :select,
        collection: Category.where(profession_id: f.object.profession_id).all.map{|c| [c.name, c.id]}
    end
    actions
  end

  index do
    column :name do |e|
      e.user.name
    end
    column :email do |e|
      e.user.email
    end
    column :profession do |e|
      e.profession.name
    end
    column :categories do |e|
      Category.where(id: e.category_ids).map(&:name).join(', ')
    end
    column :created_at
    column :updated_at
    actions
  end

  controller do
    def scoped_collection
      super.includes(:user, :profession)
    end
  end

end
