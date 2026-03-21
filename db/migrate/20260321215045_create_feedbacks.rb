class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :interview_stage, null: false, foreign_key: true
      t.string :feedback_type, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :feedbacks, [:interview_stage_id, :feedback_type], unique: true
  end
end
