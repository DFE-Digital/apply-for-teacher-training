class AddInternationalDegreeColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :international, :boolean, null: false, default: false
    add_column :application_qualifications, :naric_reference, :string
    add_column :application_qualifications, :comparable_uk_degree, :string
  end
end
