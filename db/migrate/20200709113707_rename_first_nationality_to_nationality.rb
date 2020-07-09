class RenameFirstNationalityToNationality < ActiveRecord::Migration[6.0]
  def change
    rename_column :application_forms, :first_nationality, :nationality
  end
end
