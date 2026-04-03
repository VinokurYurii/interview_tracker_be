# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resume, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      resume = create(:resume, user: user)

      expect(resume.user).to eq(user)
    end

    it 'has many positions' do
      resume = create(:resume)
      position = create(:position, resume: resume, user: resume.user)

      expect(resume.positions).to include(position)
    end

    it 'nullifies positions on destroy' do
      resume = create(:resume)
      position = create(:position, resume: resume, user: resume.user)

      resume.destroy

      expect(position.reload.resume_id).to be_nil
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:resume)).to be_valid
    end

    it 'is invalid without a name' do
      expect(build(:resume, name: nil)).to be_invalid
    end

    it 'is invalid with a duplicate name for the same user' do
      user = create(:user)
      create(:resume, name: 'Backend CV', user: user)

      expect(build(:resume, name: 'Backend CV', user: user)).to be_invalid
    end

    it 'is valid with the same name for different users' do
      create(:resume, name: 'Backend CV')

      expect(build(:resume, name: 'Backend CV')).to be_valid
    end
  end

  describe 'file validations' do
    it 'is valid with a PDF file' do
      expect(build(:resume, :with_file)).to be_valid
    end

    it 'is invalid with a non-PDF file' do
      resume = build(:resume)
      resume.file.attach(
        io: StringIO.new('not a pdf'),
        filename: 'test.txt',
        content_type: 'text/plain'
      )

      expect(resume).to be_invalid
      expect(resume.errors[:file]).to include('must be a PDF')
    end

    it 'is invalid with a file over 10 MB' do
      resume = build(:resume)
      resume.file.attach(
        io: StringIO.new('x' * (11.megabytes)),
        filename: 'large.pdf',
        content_type: 'application/pdf'
      )

      expect(resume).to be_invalid
      expect(resume.errors[:file]).to include('must be less than 10 MB')
    end
  end
end
