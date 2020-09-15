ActiveAdmin.register AppRelease do
  permit_params :app_version, :numeric_version, :depreciated,
                :released, :features, :app_type

  form do |f|
    f.inputs do
      input :app_version
      input :numeric_version
      input :depreciated, as: :boolean
      input :released, as: :boolean
      input :features, as: :text
      input :app_type, as: :select, collection: AppRelease.app_types
    end
    actions
  end
end
