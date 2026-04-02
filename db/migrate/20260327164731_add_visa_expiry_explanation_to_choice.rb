class AddVisaExpiryExplanationToChoice < ActiveRecord::Migration[8.0]
  def change
    add_column :application_choices, :visa_explanation, :string
    add_column :application_choices, :visa_explanation_details, :string
  end
end
