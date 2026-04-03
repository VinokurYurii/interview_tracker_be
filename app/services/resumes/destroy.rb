# frozen_string_literal: true

module Services
  module Resumes
    class Destroy
      attr_reader :resume

      def initialize(resume)
        @resume = resume
      end

      def call
        if resume.positions.exists?
          resume.file.purge if resume.file.attached?
          { status: :file_removed, warning: 'Resume has linked positions. File deleted but record retained.' }
        else
          resume.destroy!
          { status: :destroyed }
        end
      end
    end
  end
end
