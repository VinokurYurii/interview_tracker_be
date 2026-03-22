# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'associations' do
    it 'belongs to an interview stage' do
      stage = create(:interview_stage)
      feedback = create(:feedback, interview_stage: stage)

      expect(feedback.interview_stage).to eq(stage)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:feedback)).to be_valid
    end

    it 'is invalid without a feedback_type' do
      expect(build(:feedback, feedback_type: nil)).to be_invalid
    end

    it 'is invalid without content' do
      expect(build(:feedback, content: nil)).to be_invalid
    end

    it 'is invalid with duplicate feedback_type for same stage' do
      stage = create(:interview_stage)
      create(:feedback, interview_stage: stage, feedback_type: 'self_review')

      expect(build(:feedback, interview_stage: stage, feedback_type: 'self_review')).to be_invalid
    end

    it 'allows same feedback_type on different stages' do
      stage1 = create(:interview_stage)
      stage2 = create(:interview_stage)
      create(:feedback, interview_stage: stage1, feedback_type: 'self_review')

      expect(build(:feedback, interview_stage: stage2, feedback_type: 'self_review')).to be_valid
    end

    it 'raises on unknown feedback_type' do
      expect { build(:feedback, feedback_type: 'unknown') }.to raise_error(ArgumentError)
    end
  end

  describe 'feedback_type' do
    it 'accepts all valid feedback types' do
      stage = create(:interview_stage)
      %w[self_review company].each_with_index do |type, i|
        stage_for_type = i.zero? ? stage : create(:interview_stage)
        expect(build(:feedback, interview_stage: stage_for_type, feedback_type: type)).to be_valid
      end
    end
  end
end
