class AddSelectableSchoolToProvider < ActiveRecord::Migration[7.1]
  def change
    add_column :providers, :selectable_school, :boolean, default: false, null: false
  end
end
