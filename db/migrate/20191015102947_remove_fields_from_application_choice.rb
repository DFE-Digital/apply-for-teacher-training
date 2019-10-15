class RemoveFieldsFromApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_choices, :course_ucas_code, :string
    remove_column :application_choices, :location_ucas_code, :string
    remove_column :application_choices, :provider_ucas_code, :string
  end
end
