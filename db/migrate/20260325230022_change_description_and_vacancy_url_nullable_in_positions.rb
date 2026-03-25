class ChangeDescriptionAndVacancyUrlNullableInPositions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :positions, :description, true
    change_column_null :positions, :vacancy_url, true
  end
end
