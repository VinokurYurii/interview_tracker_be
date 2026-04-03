# frozen_string_literal: true

module Api
  module V1
    class ResumesController < Api::V1::ApplicationController
      before_action :set_resume, only: %i[show update destroy]

      def index
        resumes = policy_scope(Resume)
        render json: resumes
      end

      def show
        render json: @resume
      end

      def create
        resume = current_user.resumes.new(resume_params)
        authorize resume

        if resume.save
          render json: resume, status: :created
        else
          render json: { errors: resume.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @resume.update(resume_params)
          render json: @resume
        else
          render json: { errors: @resume.errors.full_messages }, status: :unprocessable_content
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
        params.expect(resume: %i[name file])
      end
    end
  end
end
