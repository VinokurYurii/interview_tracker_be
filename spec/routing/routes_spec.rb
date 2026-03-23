# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  describe 'Devise' do
    it { expect(post:   '/api/auth/sign_in').to  route_to('api/auth/sessions#create') }
    it { expect(delete: '/api/auth/sign_out').to route_to('api/auth/sessions#destroy') }

    it { expect(post:   '/api/auth/sign_up').to  route_to('api/auth/registrations#create') }
    it { expect(patch:  '/api/auth/sign_up').to  route_to('api/auth/registrations#update') }
    it { expect(delete: '/api/auth/sign_up').to  route_to('api/auth/registrations#destroy') }
  end

  describe 'API' do
    it { expect(get:   '/api/user').to route_to('api/v1/users#show') }
    it { expect(patch: '/api/user').to route_to('api/v1/users#update') }
  end
end
