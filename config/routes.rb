require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  authenticate :admin_user do
    mount Sidekiq::Web => '/admin/sidekiq'
  end
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :users,
             path: 'api/auth',
             path_names: { sign_in: 'sign_in', sign_out: 'sign_out', registration: 'sign_up' },
             controllers: {
               sessions: 'api/auth/sessions',
               registrations: 'api/auth/registrations'
             },
             skip: [:passwords] # TODO: Add password reset routes when React frontend is ready

  namespace :api do
    scope module: :v1 do
      resource :user, only: %i[show update]
      resources :companies, only: %i[index create]
      resources :positions, only: %i[index show create update destroy] do
        resources :interview_stages, only: %i[index show create update destroy] do
          resources :feedbacks, only: %i[index create update destroy]
        end
      end
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
