class AddRejectionReasonsTypeToApplicationChoices < ActiveRecord::Migration[6.1]
  def change
    add_column :application_choices, :rejection_reasons_type, :string
  end
end
