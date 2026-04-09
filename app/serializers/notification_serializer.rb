# frozen_string_literal: true

class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :read_at, :created_at
end
