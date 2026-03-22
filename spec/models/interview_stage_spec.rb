# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InterviewStage, type: :model do
  describe 'associations' do
    it 'belongs to a position' do
      position = create(:position)
      stage = create(:interview_stage, position: position)

      expect(stage.position).to eq(position)
    end

    it 'has many feedbacks' do
      stage = create(:interview_stage)
      create(:feedback, interview_stage: stage, feedback_type: 'self_review')
      create(:feedback, interview_stage: stage, feedback_type: 'company')

      expect(stage.feedbacks.count).to eq(2)
    end

    it 'destroys feedbacks when destroyed' do
      stage = create(:interview_stage)
      create(:feedback, interview_stage: stage)

      expect { stage.destroy }.to change(Feedback, :count).by(-1)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:interview_stage)).to be_valid
    end

    it 'is invalid without a stage_type' do
      expect(build(:interview_stage, stage_type: nil)).to be_invalid
    end

    it 'is invalid without a status' do
      expect(build(:interview_stage, status: nil)).to be_invalid
    end

    it 'raises on unknown stage_type' do
      expect { build(:interview_stage, stage_type: 'unknown') }.to raise_error(ArgumentError)
    end

    it 'raises on unknown status' do
      expect { build(:interview_stage, status: 'unknown') }.to raise_error(ArgumentError)
    end
  end

  describe 'status' do
    it 'defaults to planned' do
      stage = create(:interview_stage)

      expect(stage.status).to eq('planned')
    end

    it 'accepts all valid statuses' do
      %w[planned done declined].each do |status|
        expect(build(:interview_stage, status: status)).to be_valid
      end
    end
  end

  describe 'stage_type' do
    it 'accepts all valid stage types' do
      %w[hr screening technical live_coding system_design take_home client managerial final offer].each do |type|
        expect(build(:interview_stage, stage_type: type)).to be_valid
      end
    end
  end
end
