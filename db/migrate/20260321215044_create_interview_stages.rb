class CreateInterviewStages < ActiveRecord::Migration[8.1]
  def change
    create_table :interview_stages do |t|
      t.references :position, null: false, foreign_key: true
      t.string :stage_type, null: false
      t.string :status, null: false, default: 'planned'
      t.datetime :scheduled_at
      t.string :calendar_link
      t.text :notes

      t.timestamps
    end

    add_index :interview_stages, [:position_id, :stage_type]
  end
end
