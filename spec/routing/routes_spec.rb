require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  describe 'Devise' do
    it { expect(get:    '/users/sign_in').to  route_to('users/sessions#new') }
    it { expect(post:   '/users/sign_in').to  route_to('users/sessions#create') }
    it { expect(delete: '/users/sign_out').to route_to('users/sessions#destroy') }

    it { expect(get:   '/users/password/new').to  route_to('users/passwords#new') }
    it { expect(get:   '/users/password/edit').to route_to('users/passwords#edit') }
    it { expect(post:  '/users/password').to      route_to('users/passwords#create') }
    it { expect(patch: '/users/password').to      route_to('users/passwords#update') }

    it { expect(get:    '/users/sign_up').to route_to('users/registrations#new') }
    it { expect(post:   '/users').to         route_to('users/registrations#create') }
    it { expect(patch:  '/users').to         route_to('users/registrations#update') }
    it { expect(delete: '/users').to         route_to('users/registrations#destroy') }
  end

  describe 'API' do
    it { expect(get:   '/api/user').to route_to('api/v1/users#show') }
    it { expect(patch: '/api/user').to route_to('api/v1/users#update') }
  end
end
