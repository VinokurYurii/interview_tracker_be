# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResumePolicy, type: :policy do
  subject { described_class.new(user, resume) }

  let(:user) { create(:user) }

  context 'when user owns the resume' do
    let(:resume) { create(:resume, user: user) }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  context 'when user does not own the resume' do
    let(:resume) { create(:resume) }

    it { is_expected.to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'Scope' do
    it 'returns only resumes belonging to the user' do
      own_resume = create(:resume, user: user)
      create(:resume)
      scope = described_class::Scope.new(user, Resume).resolve

      expect(scope).to eq([own_resume])
    end
  end
end
