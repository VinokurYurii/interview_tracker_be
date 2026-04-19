# frozen_string_literal: true

class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :read_at, :created_at,
             :notifiable_id, :notifiable_type, :metadata

  def metadata
    case object.notifiable
    when InterviewStage
      { position_id: object.notifiable.position_id }
    else
      {}
    end
  end
end
