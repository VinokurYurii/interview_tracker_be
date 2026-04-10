# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoRejectStalePositionsJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:company) { create(:company) }

  def create_position(status:, age_in_days:)
    travel_to(age_in_days.days.ago) do
      create(:position, user: user, company: company, status: status)
    end
  end

  describe '#perform' do
    it 'rejects active positions inactive for at least 30 days' do
      stale = create_position(status: 'active', age_in_days: 31)

      described_class.perform_now

      expect(stale.reload.status).to eq('rejected')
      expect(Notification.where(notifiable: stale).count).to eq(1)
    end

    it 'skips active positions with recent activity' do
      fresh = create_position(status: 'active', age_in_days: 5)

      described_class.perform_now

      expect(fresh.reload.status).to eq('active')
      expect(Notification.count).to eq(0)
    end

    it 'skips positions in non-active statuses' do
      stale_offer = create_position(status: 'offer', age_in_days: 60)
      stale_accepted = create_position(status: 'accepted', age_in_days: 60)
      stale_rejected = create_position(status: 'rejected', age_in_days: 60)

      described_class.perform_now

      expect(stale_offer.reload.status).to eq('offer')
      expect(stale_accepted.reload.status).to eq('accepted')
      expect(stale_rejected.reload.status).to eq('rejected')
      expect(Notification.count).to eq(0)
    end

    it 'processes multiple stale positions in one run' do
      first = create_position(status: 'active', age_in_days: 31)
      second = create_position(status: 'active', age_in_days: 45)

      described_class.perform_now

      expect(first.reload.status).to eq('rejected')
      expect(second.reload.status).to eq('rejected')
      expect(Notification.count).to eq(2)
    end
  end
end
