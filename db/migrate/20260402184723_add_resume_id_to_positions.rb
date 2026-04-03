class AddResumeIdToPositions < ActiveRecord::Migration[8.1]
  def change
    add_reference :positions, :resume, null: true, foreign_key: { on_delete: :nullify }
  end
end
