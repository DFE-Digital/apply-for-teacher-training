class AddRejectedAtAndRejectionReasonToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :rejected_at, :datetime
    add_column :application_choices, :rejection_reason, :string
  end
end
