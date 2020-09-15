ActiveAdmin.register Appointment do
  actions :index, :show

  config.sort_order = 'updated_at_desc'

  filter :number_eq, as: :string, label: 'Appointment Number'
  filter :status_in, as: :select, collection: Appointment.statuses.keys.map{|x| [x.upcase, x]}

  index do
    column :number
    column :status do |ap|
      ap.status.upcase
    end
    column :service_place
    column :created_at
    column :scheduled_at
    column :confirmed_at
    actions
  end

  show do
    attributes_table do
      row :number
      row :status do |ap|
        ap.status.upcase
      end
      row :service_place
      row :created_at
      row :confirmed_at
      row :scheduled_at
      row :opted_services do |ap|
        ap.opted_expert_services.select(:service_name).map(&:service_name).join(', ')
      end
      row :patient_name do |ap|
        ap.patient.name
      end
      row :patient_dob do |ap|
        ap.patient.date_of_birth
      end
      row :user_relationship_with_patient do |ap|
        ap.patient.relationship
      end
      row :chronic_health_problems do |ap|
        ap.patient.chronic_health_problems
      end
      row :symptoms do |ap|
        ap.symptoms
      end
      row :instructions do |ap|
        ap.instructions
      end
      row :patient_address do |ap|
        p_address = ap.patient_address
        "#{p_address.address_line}, (#{p_address.latitude.to_f}, #{p_address.longitude.to_f})"
      end
      row :user_email do |ap|
        ap.patient.user.email
      end
      row :user_phone_number do |ap|
        ap.patient.user.phone_no
      end

      row :expert_name do |ap|
        ap.expert_detail.user.name rescue "-"
      end
      row :exper_phone_number do |ap|
        ap.expert_detail.user.phone_no rescue "-"
      end
      row :expert_address do |ap|
        e_address = ap.expert_address
        if e_address
          "#{e_address.address_line}, (#{e_address.latitude.to_f}, #{e_address.longitude.to_f})"
        else
          "-"
        end
      end
      row :updated_at
    end
  end
end
