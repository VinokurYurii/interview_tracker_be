class CreatePositions < ActiveRecord::Migration[8.1]
  def change
    create_table :positions do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :vacancy_url, null: false
      t.string :status, null: false, default: 'active'
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
