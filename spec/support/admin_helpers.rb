# frozen_string_literal: true

module AdminHelpers
  def admin_sign_in(admin_user)
    post '/admin/login', params: {
      admin_user: { email: admin_user.email, password: admin_user.password }
    }
  end
end

RSpec.configure do |config|
  config.include AdminHelpers, admin: true

  config.before(admin: true) do
    Rack::Attack.enabled = false
  end

  config.after(admin: true) do
    Rack::Attack.enabled = true
  end
end
