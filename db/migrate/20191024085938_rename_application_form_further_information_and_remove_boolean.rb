class RenameApplicationFormFurtherInformationAndRemoveBoolean < ActiveRecord::Migration[6.0]
  def change
    remove_column(:application_forms, :further_information, :boolean)
    rename_column(:application_forms, :further_information_details, :further_information)
  end
end
