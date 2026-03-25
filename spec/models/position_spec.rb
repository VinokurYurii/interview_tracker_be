# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Position, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      position = create(:position, user: user)

      expect(position.user).to eq(user)
    end

    it 'belongs to a company' do
      company = create(:company)
      position = create(:position, company: company)

      expect(position.company).to eq(company)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:position)).to be_valid
    end

    it 'is invalid without a title' do
      expect(build(:position, title: nil)).to be_invalid
    end

    it 'raises on unknown status assignment' do
      position = build(:position)
      expect { position.status = 'unknown' }.to raise_error(ArgumentError)
    end
  end

  describe 'status' do
    it 'defaults to active' do
      position = create(:position)

      expect(position.status).to eq('active')
    end

    it 'accepts all valid statuses' do
      %w[active rejected offer accepted].each do |status|
        expect(build(:position, status: status)).to be_valid
      end
    end
  end
end
