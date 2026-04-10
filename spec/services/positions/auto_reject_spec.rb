# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Positions::AutoReject do
  include ActiveSupport::Testing::TimeHelpers

  describe '#call' do
    let(:user) { create(:user) }
    let(:company) { create(:company) }
    let(:inactive_days) { 30 }

    def build_stale_position(status: 'active')
      position = nil
      travel_to(40.days.ago) do
        position = create(:position, user: user, company: company, status: status)
      end
      position
    end

    context 'when position is active and stale' do
      it 'marks the position as rejected' do
        position = build_stale_position

        described_class.new(position: position, inactive_days: inactive_days).call

        expect(position.reload.status).to eq('rejected')
      end

      it 'creates a notification for the owner' do
        position = build_stale_position

        expect do
          described_class.new(position: position, inactive_days: inactive_days).call
        end.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(user)
        expect(notification.notifiable).to eq(position)
        expect(notification.title).to eq('Position marked as rejected due to inactivity')
        expect(notification.body).to include(position.title, company.name, '30 days')
      end

      it 'returns the created notification' do
        position = build_stale_position

        result = described_class.new(position: position, inactive_days: inactive_days).call

        expect(result).to be_a(Notification)
      end
    end

    context 'when position is no longer active' do
      it 'returns nil and does not change anything' do
        position = build_stale_position(status: 'offer')

        expect do
          described_class.new(position: position, inactive_days: inactive_days).call
        end.not_to change(Notification, :count)

        expect(position.reload.status).to eq('offer')
      end
    end

    context 'when position activity is fresher than the threshold' do
      it 'returns nil and does not reject' do
        position = create(:position, user: user, company: company, status: 'active')

        result = described_class.new(position: position, inactive_days: inactive_days).call

        expect(result).to be_nil
        expect(position.reload.status).to eq('active')
      end
    end

    context 'when notification creation fails' do
      it 'rolls back the status change' do
        position = build_stale_position
        allow(Notification).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Notification.new))

        expect do
          described_class.new(position: position, inactive_days: inactive_days).call
        end.to raise_error(ActiveRecord::RecordInvalid)

        expect(position.reload.status).to eq('active')
      end
    end
  end
end
