# frozen_string_literal: true

module Services
  module Resumes
    class ExtractText
      attr_reader :resume

      def initialize(resume)
        @resume = resume
      end

      def call
        raise ArgumentError, 'Resume has no attached file' unless resume.file.attached?

        resume.file.open do |tempfile|
          reader = PDF::Reader.new(tempfile.path)
          reader.pages.map(&:text).join("\n")
        end
      end
    end
  end
end
