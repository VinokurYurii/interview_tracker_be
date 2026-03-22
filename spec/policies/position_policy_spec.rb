# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PositionPolicy, type: :policy do
  subject { described_class.new(user, position) }

  let(:user) { create(:user) }

  context 'when user owns the position' do
    let(:position) { create(:position, user: user) }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  context 'when user does not own the position' do
    let(:position) { create(:position) }

    it { is_expected.to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'Scope' do
    it 'returns only positions belonging to the user' do
      own_position = create(:position, user: user)
      create(:position)
      scope = described_class::Scope.new(user, Position).resolve

      expect(scope).to eq([own_position])
    end
  end
end
