class AddFurtherInformationFieldsToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :further_information, :boolean
    add_column :application_forms, :further_information_details, :text
  end
end
