# frozen_string_literal: true

ActiveAdmin.setup do |config|
  config.site_title = 'Interview Tracker'

  # Devise authentication method called in before_action for all admin controllers.
  config.authentication_method = :authenticate_admin_user!

  # Method to retrieve the currently logged in admin user.
  config.current_user_method = :current_admin_user

  # Logout link path and HTTP method.
  config.logout_link_path = :destroy_admin_user_session_path

  # Disable comments — no active_admin_comments table needed.
  config.comments = false

  # Enable batch actions (select + bulk operations).
  config.batch_actions = true

  # Exclude sensitive attributes from display, forms, and exports.
  config.filter_attributes = [:encrypted_password, :password, :password_confirmation]

  # Date/time display format.
  config.localize_format = :long
end
