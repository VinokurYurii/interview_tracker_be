# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyPolicy, type: :policy do
  subject { described_class.new(user, company) }

  let(:user) { create(:user) }
  let(:company) { create(:company) }

  it { is_expected.to be_index }
  it { is_expected.to be_create }
  it { is_expected.not_to be_show }
  it { is_expected.not_to be_update }
  it { is_expected.not_to be_destroy }

  describe 'Scope' do
    it 'returns all companies' do
      companies = create_list(:company, 3)
      scope = described_class::Scope.new(user, Company).resolve

      expect(scope).to match_array(companies)
    end
  end
end
