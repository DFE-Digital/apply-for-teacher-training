class AddPreviousLastNamesToApplicationForms < ActiveRecord::Migration[8.1]
  def change
    add_column :application_forms, :previous_last_names, :string
  end
end
