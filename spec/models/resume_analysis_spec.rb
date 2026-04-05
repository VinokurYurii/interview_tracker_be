# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResumeAnalysis, type: :model do
  describe 'associations' do
    it 'belongs to a resume' do
      resume = create(:resume)
      analysis = create(:resume_analysis, resume: resume)

      expect(analysis.resume).to eq(resume)
    end
  end

  describe 'validations' do
    it 'is invalid without a status' do
      analysis = build(:resume_analysis, status: nil)

      expect(analysis).not_to be_valid
    end

    it 'enforces one analysis per resume at database level' do
      resume = create(:resume)
      create(:resume_analysis, resume: resume)

      expect { create(:resume_analysis, resume: resume) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'enum' do
    it 'defines status enum' do
      analysis = build(:resume_analysis)

      expect(analysis).to respond_to(:pending?, :processing?, :completed?, :failed?)
    end
  end
end
