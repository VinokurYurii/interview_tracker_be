# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::InterviewStages::AutoComplete do
  include ActiveSupport::Testing::TimeHelpers

  describe '#call' do
    let(:user) { create(:user) }
    let(:company) { create(:company) }
    let(:position) { create(:position, user: user, company: company) }
    let(:cutoff_at) { 1.day.ago.beginning_of_day }

    context 'when stage is planned and scheduled before cutoff' do
      let!(:stage) do
        create(:interview_stage,
               position: position,
               status: 'planned',
               scheduled_at: 3.days.ago)
      end

      it 'marks the stage as done' do
        described_class.new(stage: stage, cutoff_at: cutoff_at).call

        expect(stage.reload.status).to eq('done')
      end

      it 'creates a notification for the position owner' do
        expect do
          described_class.new(stage: stage, cutoff_at: cutoff_at).call
        end.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(user)
        expect(notification.notifiable).to eq(stage)
        expect(notification.title).to eq('Interview stage marked as completed')
        expect(notification.body).to include(position.title, company.name)
      end

      it 'does not bump the parent position updated_at (touch cascade bypass)' do
        position_updated_at = position.reload.updated_at

        travel_to(2.hours.from_now) do
          described_class.new(stage: stage, cutoff_at: cutoff_at).call
        end

        expect(position.reload.updated_at).to be_within(1.second).of(position_updated_at)
      end

      it 'advances the stage updated_at' do
        original_updated_at = stage.updated_at

        travel_to(2.hours.from_now) do
          described_class.new(stage: stage, cutoff_at: cutoff_at).call
        end

        expect(stage.reload.updated_at).to be > original_updated_at
      end
    end

    context 'when stage is already done' do
      it 'returns nil and does not create a notification' do
        stage = create(:interview_stage,
                       position: position,
                       status: 'done',
                       scheduled_at: 3.days.ago)

        expect do
          described_class.new(stage: stage, cutoff_at: cutoff_at).call
        end.not_to change(Notification, :count)
      end
    end

    context 'when stage is declined' do
      it 'returns nil and does not change status' do
        stage = create(:interview_stage,
                       position: position,
                       status: 'declined',
                       scheduled_at: 3.days.ago)

        result = described_class.new(stage: stage, cutoff_at: cutoff_at).call

        expect(result).to be_nil
        expect(stage.reload.status).to eq('declined')
      end
    end

    context 'when scheduled_at is nil' do
      it 'returns nil' do
        stage = create(:interview_stage,
                       position: position,
                       status: 'planned',
                       scheduled_at: nil)

        result = described_class.new(stage: stage, cutoff_at: cutoff_at).call

        expect(result).to be_nil
        expect(stage.reload.status).to eq('planned')
      end
    end

    context 'when scheduled_at is fresher than cutoff' do
      it 'returns nil' do
        stage = create(:interview_stage,
                       position: position,
                       status: 'planned',
                       scheduled_at: 1.hour.ago)

        result = described_class.new(stage: stage, cutoff_at: cutoff_at).call

        expect(result).to be_nil
        expect(stage.reload.status).to eq('planned')
      end
    end
  end
end
