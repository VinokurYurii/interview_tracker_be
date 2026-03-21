require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has many positions' do
      user = create(:user)
      create_list(:position, 2, user: user)

      expect(user.positions.count).to eq(2)
    end

    it 'has many companies through positions' do
      user = create(:user)
      company1, company2 = create_list(:company, 2)
      create(:position, user: user, company: company1)
      create(:position, user: user, company: company2)

      expect(user.companies).to contain_exactly(company1, company2)
    end

    it 'destroys positions when destroyed' do
      user = create(:user)
      create_list(:position, 2, user: user)

      expect { user.destroy }.to change(Position, :count).by(-2)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:user)).to be_valid
    end

    it 'is invalid without a first_name' do
      expect(build(:user, first_name: nil)).to be_invalid
    end

    it 'is invalid without a last_name' do
      expect(build(:user, last_name: nil)).to be_invalid
    end

    it 'is invalid with a first_name longer than 50 characters' do
      expect(build(:user, first_name: 'a' * 51)).to be_invalid
    end

    it 'is invalid with a last_name longer than 50 characters' do
      expect(build(:user, last_name: 'a' * 51)).to be_invalid
    end

    it 'is invalid without an email' do
      expect(build(:user, email: nil)).to be_invalid
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'test@example.com')
      expect(build(:user, email: 'test@example.com')).to be_invalid
    end

    it 'is invalid without a password' do
      expect(build(:user, password: nil)).to be_invalid
    end
  end
end
