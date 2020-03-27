class RemovePersonalStatementFromApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_choices, :personal_statement, :text
  end
end
