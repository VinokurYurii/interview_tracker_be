# frozen_string_literal: true

ActiveAdmin.register InterviewStage do
  menu priority: 5

  permit_params :position_id, :stage_type, :status, :scheduled_at, :notes, :calendar_link

  index do
    selectable_column
    id_column
    column(:position) { |s| s.position.title }
    column :stage_type
    column :status
    column :scheduled_at
    column :created_at
    actions
  end

  filter :stage_type, as: :select, collection: InterviewStage::STAGE_TYPES
  filter :status, as: :select, collection: InterviewStage::STATUSES
  filter :scheduled_at
  filter :created_at

  show do
    attributes_table do
      row :id
      row(:position) { |s| s.position.title }
      row :stage_type
      row :status
      row :scheduled_at
      row :notes
      row :calendar_link
      row :created_at
      row :updated_at
    end

    panel 'Feedbacks' do
      table_for interview_stage.feedbacks do
        column(:id) { |f| link_to f.id, admin_feedback_path(f) }
        column :feedback_type
        column(:content) { |f| truncate(f.content, length: 80) }
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :position, as: :select, collection: Position.all.map { |p| [p.title, p.id] }
      f.input :stage_type, as: :select, collection: InterviewStage::STAGE_TYPES
      f.input :status, as: :select, collection: InterviewStage::STATUSES
      f.input :scheduled_at, as: :datepicker
      f.input :notes
      f.input :calendar_link
    end
    f.actions
  end
end
