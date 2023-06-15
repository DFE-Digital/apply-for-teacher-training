class AddPersonalStatementToApplicationChoice < ActiveRecord::Migration[7.0]
  def change
    add_column :application_choices, :personal_statement, :text
  end
end
