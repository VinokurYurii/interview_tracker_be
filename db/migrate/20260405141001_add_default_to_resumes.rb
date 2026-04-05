class AddDefaultToResumes < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:resumes, :default)
      add_column :resumes, :default, :boolean, default: false, null: false
    end
  end
end
