# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :request, admin: true do
  let(:admin_user) { create(:admin_user) }

  before { admin_sign_in(admin_user) }

  describe 'GET /admin' do
    it 'renders the dashboard' do
      get '/admin'
      expect(response).to have_http_status(:ok)
    end
  end
end
