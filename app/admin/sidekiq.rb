# frozen_string_literal: true

ActiveAdmin.register_page 'Sidekiq Dashboard' do
  menu priority: 99, label: 'Sidekiq'

  controller do
    def index
      redirect_to '/admin/sidekiq', allow_other_host: true
    end
  end
end
