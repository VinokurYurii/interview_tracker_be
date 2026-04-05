# frozen_string_literal: true

module Api
  module V1
    class ResumesController < Api::V1::ApplicationController
      before_action :set_resume, only: %i[show update destroy generate_analysis]

      def index
        resumes = policy_scope(Resume)
        render json: resumes
      end

      def show
        render json: @resume
      end

      def create
        authorize Resume

        result = Services::Resumes::Create.new(current_user, resume_params).call

        if result[:success]
          render json: result[:resume], status: :created
        else
          render json: { errors: result[:errors] }, status: :unprocessable_content
        end
      end

      def update
        result = Services::Resumes::Update.new(@resume, resume_params).call

        if result[:success]
          render json: result[:resume]
        else
          render json: { errors: result[:errors] }, status: :unprocessable_content
        end
      end

      def generate_analysis
        result = Services::Resumes::RequestAnalysis.new(@resume).call

        if result[:success]
          render json: result[:analysis], serializer: ResumeAnalysisSerializer, status: :accepted
        else
          render json: { error: result[:error] }, status: :unprocessable_content
        end
      end

      def destroy
        result = Services::Resumes::Destroy.new(@resume).call

        case result[:status]
        when :destroyed
          head :no_content
        when :file_removed
          render json: { warning: result[:warning], resume: ResumeSerializer.new(@resume).as_json },
                 status: :ok
        end
      end

      private

      def set_resume
        @resume = Resume.find(params[:id])
        authorize @resume
      end

      def resume_params
        params.expect(resume: %i[name file default])
      end
    end
  end
end
