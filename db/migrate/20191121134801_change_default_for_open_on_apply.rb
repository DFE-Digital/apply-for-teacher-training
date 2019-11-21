class ChangeDefaultForOpenOnApply < ActiveRecord::Migration[6.0]
  def change
    change_column_default :courses, :open_on_apply, false
  end
end
