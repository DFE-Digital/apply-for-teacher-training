class AddSchoolPlacementAutoSelectedToApplicationChoice < ActiveRecord::Migration[7.1]
  def change
    add_column :application_choices, :school_placement_auto_selected, :boolean, default: false, null: false
  end
end
