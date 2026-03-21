Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  namespace :api do
    scope module: :v1 do
      resource :user, only: %i[show update]
      resources :companies, only: %i[index create]
      resources :positions, only: %i[index show create update destroy]
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
