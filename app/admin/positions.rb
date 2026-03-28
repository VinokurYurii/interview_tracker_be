# frozen_string_literal: true

ActiveAdmin.register Position do
  menu priority: 4

  permit_params :title, :status, :description, :vacancy_url, :user_id, :company_id

  index do
    selectable_column
    id_column
    column :title
    column(:user) { |p| "#{p.user.first_name} #{p.user.last_name}" }
    column(:company) { |p| p.company.name }
    column :status
    column :created_at
    actions
  end

  filter :title
  filter :status, as: :select, collection: Position::STATUSES
  filter :user, as: :select, collection: -> { User.all.map { |u| ["#{u.first_name} #{u.last_name}", u.id] } }
  filter :company, as: :select, collection: -> { Company.all.map { |c| [c.name, c.id] } }
  filter :created_at

  show do
    attributes_table do
      row :id
      row :title
      row(:user) { |p| "#{p.user.first_name} #{p.user.last_name}" }
      row(:company) { |p| p.company.name }
      row :status
      row :description
      row :vacancy_url
      row :created_at
      row :updated_at
    end

    panel 'Interview Stages' do
      table_for position.interview_stages do
        column(:id) { |s| link_to s.id, admin_interview_stage_path(s) }
        column :stage_type
        column :status
        column :scheduled_at
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.all.map { |u| ["#{u.first_name} #{u.last_name}", u.id] }
      f.input :company, as: :select, collection: Company.all.map { |c| [c.name, c.id] }
      f.input :title
      f.input :status, as: :select, collection: Position::STATUSES
      f.input :description
      f.input :vacancy_url
    end
    f.actions
  end
end
