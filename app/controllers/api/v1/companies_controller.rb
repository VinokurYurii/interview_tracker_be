# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < Api::V1::ApplicationController
      def index
        companies = policy_scope(Company)
        render json: companies
      end

      def create
        company = Company.new(company_params)
        authorize company

        if company.save
          render json: company, status: :created
        else
          render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def company_params
        params.expect(company: %i[name site_link])
      end
    end
  end
end
