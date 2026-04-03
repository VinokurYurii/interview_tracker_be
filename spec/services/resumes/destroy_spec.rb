# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Resumes::Destroy do
  describe '#call' do
    context 'when resume has no linked positions' do
      it 'destroys the resume and returns :destroyed status' do
        resume = create(:resume, :with_file)

        result = described_class.new(resume).call

        expect(result[:status]).to eq(:destroyed)
        expect(Resume.exists?(resume.id)).to be(false)
      end
    end

    context 'when resume has linked positions' do
      it 'purges the file but keeps the record' do
        resume = create(:resume, :with_file)
        create(:position, resume: resume, user: resume.user)

        result = described_class.new(resume).call

        expect(result[:status]).to eq(:file_removed)
        expect(result[:warning]).to be_present
        expect(Resume.exists?(resume.id)).to be(true)
        expect(resume.reload.file).not_to be_attached
      end
    end

    context 'when resume has linked positions but no file' do
      it 'keeps the record and returns :file_removed status' do
        resume = create(:resume)
        create(:position, resume: resume, user: resume.user)

        result = described_class.new(resume).call

        expect(result[:status]).to eq(:file_removed)
        expect(Resume.exists?(resume.id)).to be(true)
      end
    end
  end
end
