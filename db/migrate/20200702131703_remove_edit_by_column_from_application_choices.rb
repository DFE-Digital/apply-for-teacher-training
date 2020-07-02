class RemoveEditByColumnFromApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_choices, :edit_by, :datetime
  end
end
