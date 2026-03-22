# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackPolicy, type: :policy do
  subject { described_class.new(user, feedback) }

  let(:user) { create(:user) }

  context 'when user owns the position' do
    let(:position) { create(:position, user: user) }
    let(:stage) { create(:interview_stage, position: position) }
    let(:feedback) { create(:feedback, interview_stage: stage) }

    it { is_expected.to be_index }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  context 'when user does not own the position' do
    let(:feedback) { create(:feedback) }

    it { is_expected.to be_index }
    it { is_expected.to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'Scope' do
    it 'returns only feedbacks for stages belonging to the user' do
      position = create(:position, user: user)
      stage = create(:interview_stage, position: position)
      own_feedback = create(:feedback, interview_stage: stage)
      create(:feedback)
      scope = described_class::Scope.new(user, Feedback).resolve

      expect(scope).to eq([own_feedback])
    end
  end
end
