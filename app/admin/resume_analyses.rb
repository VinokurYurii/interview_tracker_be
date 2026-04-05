# frozen_string_literal: true

ActiveAdmin.register ResumeAnalysis do
  menu priority: 6

  actions :index, :show

  index do
    selectable_column
    id_column
    column(:resume) { |ra| link_to ra.resume.name, admin_resume_path(ra.resume) }
    column :status
    column :model
    column :tokens_used
    column :created_at
    actions
  end

  filter :status, as: :select, collection: ResumeAnalysis::STATUSES
  filter :model
  filter :created_at

  show do
    attributes_table do
      row :id
      row(:resume) { |ra| link_to ra.resume.name, admin_resume_path(ra.resume) }
      row :status
      row :model
      row :tokens_used
      row(:content) { |ra| simple_format(ra.content) }
      row(:error_message) { |ra| ra.error_message if ra.failed? }
      row :created_at
      row :updated_at
    end
  end
end
