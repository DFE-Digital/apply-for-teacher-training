class AddApplicationQualificationsStartYear < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :start_year, :string
  end
end
