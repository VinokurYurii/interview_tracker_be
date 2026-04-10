# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoCompletePastStagesJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:position) { create(:position, user: user, company: company) }

  describe '#perform' do
    it 'marks planned stages with scheduled_at before yesterday as done' do
      stage = create(:interview_stage,
                     position: position,
                     status: 'planned',
                     scheduled_at: 3.days.ago)

      described_class.perform_now

      expect(stage.reload.status).to eq('done')
      expect(Notification.where(notifiable: stage).count).to eq(1)
    end

    it 'skips planned stages scheduled today' do
      stage = create(:interview_stage,
                     position: position,
                     status: 'planned',
                     scheduled_at: 2.hours.from_now)

      described_class.perform_now

      expect(stage.reload.status).to eq('planned')
      expect(Notification.count).to eq(0)
    end

    it 'skips planned stages scheduled yesterday afternoon (still within grace)' do
      travel_to Time.zone.local(2026, 4, 11, 9, 0, 0) do
        stage = create(:interview_stage,
                       position: position,
                       status: 'planned',
                       scheduled_at: Time.zone.local(2026, 4, 10, 18, 0, 0))

        described_class.perform_now

        expect(stage.reload.status).to eq('planned')
        expect(Notification.count).to eq(0)
      end
    end

    it 'completes planned stages scheduled two days ago' do
      travel_to Time.zone.local(2026, 4, 11, 9, 0, 0) do
        stage = create(:interview_stage,
                       position: position,
                       status: 'planned',
                       scheduled_at: Time.zone.local(2026, 4, 9, 14, 0, 0))

        described_class.perform_now

        expect(stage.reload.status).to eq('done')
      end
    end

    it 'skips planned stages with nil scheduled_at' do
      stage = create(:interview_stage,
                     position: position,
                     status: 'planned',
                     scheduled_at: nil)

      described_class.perform_now

      expect(stage.reload.status).to eq('planned')
      expect(Notification.count).to eq(0)
    end

    it 'skips done and declined stages' do
      done_stage = create(:interview_stage,
                          position: position,
                          status: 'done',
                          scheduled_at: 5.days.ago)
      declined_stage = create(:interview_stage,
                              position: position,
                              status: 'declined',
                              scheduled_at: 5.days.ago)

      described_class.perform_now

      expect(done_stage.reload.status).to eq('done')
      expect(declined_stage.reload.status).to eq('declined')
      expect(Notification.count).to eq(0)
    end

    it 'does not bump position updated_at when completing stages' do
      stage = create(:interview_stage,
                     position: position,
                     status: 'planned',
                     scheduled_at: 3.days.ago)
      original_position_updated_at = position.reload.updated_at

      travel_to(2.hours.from_now) do
        described_class.perform_now
      end

      expect(stage.reload.status).to eq('done')
      expect(position.reload.updated_at).to be_within(1.second).of(original_position_updated_at)
    end
  end
end
