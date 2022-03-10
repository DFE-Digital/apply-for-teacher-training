class AddRejectionReasonsTypeToApplicationChoices < ActiveRecord::Migration[6.1]
  def up
    add_column :application_choices, :rejection_reasons_type, :string, null: false, default: 'reasons_for_rejection'
  end

  def down
    remove_column :application_choices, :rejection_reasons_type
  end
end
