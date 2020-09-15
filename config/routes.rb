require 'api_constraints'

Rails.application.routes.draw do
  root to: 'visitors#index'
  resources :visitors, only: [:index]
  post 'signup_request', controller: :visitors, action: :signup_request

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api, defaults: {format: :json} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      post 'register', controller: :users, action: :create
      post 'login', controller: :sessions, action: :create
      post 'logout', controller: :sessions, action: :destroy
      get 'profile', controller: :users, action: :show
      post 'forgot_password', controller: :users, action: :forgot_password
      resources :patients, only: [:index, :create]

      get 'cities', controller: :locations, action: :cities
      get 'localities', controller: :locations, action: :localities
      resources :addresses, only: [:index, :create, :destroy]
      resources :expert_details, only: [:create]
      post 'expert/ping', controller: :expert_details, action: :ping_update
      get 'expert/appointments', controller: :expert_details, action: :appointments

      post 'availabilities/multiple', controller: :availabilities, action: :create_multiple
      resources :availabilities, only: [:create, :destroy]

      resources :professions, only: [:index]
      post 'experts', controller: :expert_details, action: :nearest_experts
      get 'expert/services', controller: :expert_details, action: :services

      get 'appointments/:number/soft_assigned_appointment', controller: :appointments, action: :soft_assigned_appointment

      resources :appointments, only: [:index, :create]
      post 'appointments/:number/update_status', controller: :appointments, action: :update_status
      post 'appointments/:number/your_rating', controller: :appointments, action: :your_rating
      get 'appointments/pending_rating', controller: :appointments, action: :pending_rating
      get 'appointments/:number', controller: :appointments, action: :show
      get 'appointments/:number/status', controller: :appointments, action: :status
      get 'appointments/:number/track', controller: :appointments, action: :show

      post 'user_devices/add_reg_id', controller: :user_devices, action: :create_or_update
      get 'user_relationships', controller: :patients, action: :relationships


      #Init resources
      get 'init/on_start', controller: :init, action: :on_start
      get 'init/after_login', controller: :init, action: :after_login

      #Sign Up flow
      post 'sign_up/expert_detail', controller: :sign_up_flow, action: :expert_detail
      post 'sign_up/address', controller: :sign_up_flow, action: :address
      post 'sign_up/availabilities', controller: :sign_up_flow, action: :availabilities

      #Notifications
      resources :notifications, only: [] do
        member do
          post :received
          post :accept
          post :reject
        end
      end
    end
  end
end
