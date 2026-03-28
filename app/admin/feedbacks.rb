# frozen_string_literal: true

ActiveAdmin.register Feedback do
  menu priority: 6

  permit_params :interview_stage_id, :feedback_type, :content

  index do
    selectable_column
    id_column
    column(:interview_stage) { |f| "#{f.interview_stage.position.title} — #{f.interview_stage.stage_type}" }
    column :feedback_type
    column(:content) { |f| truncate(f.content, length: 80) }
    column :created_at
    actions
  end

  filter :feedback_type, as: :select, collection: Feedback::FEEDBACK_TYPES
  filter :created_at

  show do
    attributes_table do
      row :id
      row(:interview_stage) { |f| "#{f.interview_stage.position.title} — #{f.interview_stage.stage_type}" }
      row :feedback_type
      row :content
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :interview_stage, as: :select,
              collection: InterviewStage.includes(:position).map { |s| ["#{s.position.title} — #{s.stage_type}", s.id] }
      f.input :feedback_type, as: :select, collection: Feedback::FEEDBACK_TYPES
      f.input :content
    end
    f.actions
  end
end
