# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InterviewStagePolicy, type: :policy do
  subject { described_class.new(user, stage) }

  let(:user) { create(:user) }

  context 'when user owns the position' do
    let(:position) { create(:position, user: user) }
    let(:stage) { create(:interview_stage, position: position) }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  context 'when user does not own the position' do
    let(:stage) { create(:interview_stage) }

    it { is_expected.to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'Scope' do
    it 'returns only stages for positions belonging to the user' do
      position = create(:position, user: user)
      own_stage = create(:interview_stage, position: position)
      create(:interview_stage)
      scope = described_class::Scope.new(user, InterviewStage).resolve

      expect(scope).to eq([own_stage])
    end
  end
end
