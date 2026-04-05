# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Resumes::Update do
  describe '#call' do
    context 'with valid params' do
      it 'updates the resume and returns success' do
        resume = create(:resume, name: 'Old Name')

        result = described_class.new(resume, { name: 'New Name' }).call

        expect(result[:success]).to be(true)
        expect(result[:resume].name).to eq('New Name')
      end
    end

    context 'with invalid params' do
      it 'returns failure with errors' do
        resume = create(:resume)

        result = described_class.new(resume, { name: '' }).call

        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Name can't be blank")
      end
    end

    context 'when setting resume as default' do
      it 'clears default from other resumes of the same user' do
        user = create(:user)
        old_default = create(:resume, user: user, default: true)
        resume = create(:resume, user: user)

        result = described_class.new(resume, { default: true }).call

        expect(result[:success]).to be(true)
        expect(result[:resume].default).to be(true)
        expect(old_default.reload.default).to be(false)
      end

      it 'does not affect resumes of other users' do
        user = create(:user)
        other_user = create(:user)
        other_default = create(:resume, user: other_user, default: true)
        resume = create(:resume, user: user)

        described_class.new(resume, { default: true }).call

        expect(other_default.reload.default).to be(true)
      end
    end

    context 'with duplicate name for same user' do
      it 'returns failure with errors' do
        user = create(:user)
        create(:resume, user: user, name: 'Taken Name')
        resume = create(:resume, user: user)

        result = described_class.new(resume, { name: 'Taken Name' }).call

        expect(result[:success]).to be(false)
        expect(result[:errors]).to include('Name has already been taken')
      end
    end
  end
end
