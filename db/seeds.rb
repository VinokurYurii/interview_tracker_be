# frozen_string_literal: true

# Admin user seed.
# Development: uses default credentials.
# Production:  reads from ADMIN_EMAIL / ADMIN_PASSWORD env vars
#              (set on EC2, never committed to git).
#
# Usage on AWS:
#   ADMIN_EMAIL=your@email.com ADMIN_PASSWORD=securepass123 bin/rails db:seed

admin_email = ENV.fetch('ADMIN_EMAIL', 'admin@example.com')
admin_password = ENV.fetch('ADMIN_PASSWORD', 'password')

AdminUser.find_or_create_by!(email: admin_email) do |admin|
  admin.password = admin_password
end
