require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'associations' do
    it 'has many positions' do
      company = create(:company)
      user1, user2 = create_list(:user, 2)
      create(:position, company: company, user: user1)
      create(:position, company: company, user: user2)

      expect(company.positions.count).to eq(2)
    end

    it 'has many users through positions' do
      company = create(:company)
      user1, user2 = create_list(:user, 2)
      create(:position, company: company, user: user1)
      create(:position, company: company, user: user2)

      expect(company.users).to contain_exactly(user1, user2)
    end

    it 'destroys positions when destroyed' do
      company = create(:company)
      create(:position, company: company)

      expect { company.destroy }.to change(Position, :count).by(-1)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:company)).to be_valid
    end

    it 'is invalid without a name' do
      expect(build(:company, name: nil)).to be_invalid
    end

    it 'is valid without a site_link' do
      expect(build(:company, site_link: nil)).to be_valid
    end
  end
end
