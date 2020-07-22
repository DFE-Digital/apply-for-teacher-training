class AddAdditionalNationalitiesColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :third_nationality, :string
    add_column :application_forms, :fourth_nationality, :string
    add_column :application_forms, :fifth_nationality, :string
    remove_column :application_forms, :multiple_nationalities_details, :string
  end
end
