# frozen_string_literal: true

class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :site_link
end
