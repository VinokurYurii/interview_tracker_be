# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Resumes::Create do
  describe '#call' do
    let(:user) { create(:user) }

    context 'with valid params' do
      it 'creates a resume and returns success' do
        params = { name: 'My Resume' }

        result = described_class.new(user, params).call

        expect(result[:success]).to be(true)
        expect(result[:resume]).to be_persisted
        expect(result[:resume].name).to eq('My Resume')
        expect(result[:resume].user).to eq(user)
      end
    end

    context 'when user has no default resume' do
      it 'sets the new resume as default' do
        result = described_class.new(user, { name: 'First' }).call

        expect(result[:resume].default).to be(true)
      end
    end

    context 'when user already has a default resume' do
      it 'does not override existing default' do
        create(:resume, user: user, default: true)

        result = described_class.new(user, { name: 'Second' }).call

        expect(result[:resume].default).to be(false)
      end
    end

    context 'when creating a resume with default: true' do
      it 'clears default from other resumes' do
        existing = create(:resume, user: user, default: true)

        result = described_class.new(user, { name: 'New Default', default: true }).call

        expect(result[:success]).to be(true)
        expect(result[:resume].default).to be(true)
        expect(existing.reload.default).to be(false)
      end
    end

    context 'with invalid params' do
      it 'returns failure with errors' do
        params = { name: '' }

        result = described_class.new(user, params).call

        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Name can't be blank")
      end
    end

    context 'with duplicate name for same user' do
      it 'returns failure with errors' do
        create(:resume, user: user, name: 'My Resume')
        params = { name: 'My Resume' }

        result = described_class.new(user, params).call

        expect(result[:success]).to be(false)
        expect(result[:errors]).to include('Name has already been taken')
      end
    end
  end
end
