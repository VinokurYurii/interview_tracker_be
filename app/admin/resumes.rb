# frozen_string_literal: true

ActiveAdmin.register Resume do
  menu priority: 5

  permit_params :name, :user_id, :file

  index do
    selectable_column
    id_column
    column :name
    column(:user) { |r| "#{r.user.first_name} #{r.user.last_name}" }
    column(:file) { |r| r.file.attached? ? 'Attached' : 'No file' }
    column :created_at
    actions
  end

  filter :name
  filter :user, as: :select, collection: -> { User.all.map { |u| ["#{u.first_name} #{u.last_name}", u.id] } }
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row(:user) { |r| "#{r.user.first_name} #{r.user.last_name}" }
      row(:file) do |r|
        if r.file.attached?
          link_to 'Download', rails_blob_path(r.file, disposition: 'attachment')
        else
          'No file'
        end
      end
      row :created_at
      row :updated_at
    end

    panel 'Linked Positions' do
      table_for resume.positions do
        column(:id) { |p| link_to p.id, admin_position_path(p) }
        column :title
        column :status
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.all.map { |u| ["#{u.first_name} #{u.last_name}", u.id] }
      f.input :name
      f.input :file, as: :file
    end
    f.actions
  end
end
