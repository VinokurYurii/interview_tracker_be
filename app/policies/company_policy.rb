# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def index? = true
  def create? = true

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
