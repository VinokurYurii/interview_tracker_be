require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Interview Tracker API',
        version: 'v1'
      },
      paths: {},
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer
          }
        }
      },
      security: [{ bearer_auth: [] }]
    }
  }

  config.openapi_format = :yaml
end
