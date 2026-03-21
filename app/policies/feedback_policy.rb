# frozen_string_literal: true

class FeedbackPolicy < ApplicationPolicy
  def index? = true
  def create? = true
  def update? = owner?
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(interview_stage: :position).where(positions: { user: user })
    end
  end

  private

  def owner? = record.interview_stage.position.user == user
end
