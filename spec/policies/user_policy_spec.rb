# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:user) { create(:user) }

  context 'when user is the record owner' do
    let(:record) { user }

    it { is_expected.to be_show }
    it { is_expected.to be_update }
  end

  context 'when user is not the record owner' do
    let(:record) { create(:user) }

    it { is_expected.not_to be_show }
    it { is_expected.not_to be_update }
  end
end
