# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show? = user == record
  def update? = user == record
end
