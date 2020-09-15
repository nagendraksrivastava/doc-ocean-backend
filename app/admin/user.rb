ActiveAdmin.register User do
  actions :index, :show, :edit, :update
  permit_params :name, :email, :phone_no, image_attributes: [:id, :attachment]

  filter :email_eq, label: 'Email'
  filter :phone_no_eq, label: 'Phone Number'
  filter :type_eq, as: :select, collection: User.types.keys.map{|t| [t.upcase, t]}, label: 'User Type'

  index do
    column :name
    column :email
    column :phone_no
    column :type do |u|
      u.type.upcase
    end
    column :signup_pipeline do |u|
      u.signup_pipeline.upcase
    end
    column :created_at
    column :updated_at
    actions
  end

  show do |user|
    attributes_table do
      row :name
      row :email
      row :phone_no
      row :type do |u|
        u.type.upcase
      end
      if user.image.present?
        row :image do |u|
          image_tag u.image_url
        end
      end
      row :signup_pipeline do |u|
        u.signup_pipeline.upcase
      end
      row :created_at
      row :updated_at
    end
  end

  form :html => { :multipart => true } do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :email
      f.input :phone_no
    end
    f.inputs 'User Image', for: [:image, f.object.image || f.object.build_image] do |im|
      im.input :attachment, as: :file
    end
    f.actions
  end
end
