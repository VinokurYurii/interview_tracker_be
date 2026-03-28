# frozen_string_literal: true

ActiveAdmin.register Company do
  menu priority: 3

  permit_params :name, :site_link

  index do
    selectable_column
    id_column
    column :name
    column :site_link
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :site_link
      row :created_at
      row :updated_at
    end

    panel 'Positions' do
      table_for company.positions do
        column(:id) { |p| link_to p.id, admin_position_path(p) }
        column(:title) { |p| link_to p.title, admin_position_path(p) }
        column(:user) { |p| link_to "#{p.user.first_name} #{p.user.last_name}", admin_user_path(p.user) }
        column :status
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :site_link
    end
    f.actions
  end
end
