# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def index? = true
  def mark_read? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.where(user: user)
  end

  private

  def owner? = record.user == user
end
