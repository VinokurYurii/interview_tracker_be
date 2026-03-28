# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 2

  permit_params :email, :first_name, :last_name, :password

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :created_at
    actions
  end

  filter :email
  filter :first_name
  filter :last_name
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :created_at
      row :updated_at
    end

    panel 'Positions' do
      table_for user.positions do
        column(:id) { |p| link_to p.id, admin_position_path(p) }
        column(:title) { |p| link_to p.title, admin_position_path(p) }
        column(:company) { |p| link_to p.company.name, admin_company_path(p.company) }
        column :status
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :password
    end
    f.actions
  end
end
