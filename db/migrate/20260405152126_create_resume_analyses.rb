class CreateResumeAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :resume_analyses do |t|
      t.references :resume, null: false, foreign_key: true, index: { unique: true }
      t.text :content
      t.integer :tokens_used
      t.string :model
      t.string :status, null: false, default: 'pending'
      t.text :error_message

      t.timestamps
    end
  end
end
