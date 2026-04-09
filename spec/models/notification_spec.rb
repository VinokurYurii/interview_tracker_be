# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      notification = create(:notification, user: user)

      expect(notification.user).to eq(user)
    end

    it 'belongs to a notifiable (polymorphic)' do
      position = create(:position)
      notification = create(:notification, notifiable: position)

      expect(notification.notifiable).to eq(position)
    end

    it 'can belong to an interview stage' do
      stage = create(:interview_stage)
      notification = create(:notification, notifiable: stage)

      expect(notification.notifiable).to eq(stage)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:notification)).to be_valid
    end

    it 'is invalid without a title' do
      expect(build(:notification, title: nil)).to be_invalid
    end

    it 'is invalid without a body' do
      expect(build(:notification, body: nil)).to be_invalid
    end
  end

  describe '.recent' do
    it 'returns notifications ordered by created_at desc' do
      user = create(:user)
      old = create(:notification, user: user, created_at: 2.days.ago)
      new_one = create(:notification, user: user, created_at: 1.hour.ago)

      expect(Notification.recent).to eq([new_one, old])
    end
  end

  describe 'read_at' do
    it 'is nil by default (unread)' do
      notification = create(:notification)

      expect(notification.read_at).to be_nil
    end

    it 'can be marked as read' do
      notification = create(:notification)
      read_time = Time.current
      notification.update!(read_at: read_time)

      expect(notification.read_at).to be_within(1.second).of(read_time)
    end
  end
end
