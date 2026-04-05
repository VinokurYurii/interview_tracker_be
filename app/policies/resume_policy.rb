# frozen_string_literal: true

class ResumePolicy < ApplicationPolicy
  def index? = true
  def show? = owner?
  def create? = true
  def update? = owner?
  def destroy? = owner?
  def generate_analysis? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.where(user: user)
  end

  private

  def owner? = record.user == user
end
