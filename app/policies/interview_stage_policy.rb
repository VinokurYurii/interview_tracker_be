# frozen_string_literal: true

class InterviewStagePolicy < ApplicationPolicy
  def index? = true
  def show? = owner?
  def create? = true
  def update? = owner?
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:position).where(positions: { user: user })
    end
  end

  private

  def owner? = record.position.user == user
end
