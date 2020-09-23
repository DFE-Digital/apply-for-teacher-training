class AddStatusBeforeDeferralToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :status_before_deferral, :string
  end
end
