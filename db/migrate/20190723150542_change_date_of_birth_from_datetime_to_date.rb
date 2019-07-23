class ChangeDateOfBirthFromDatetimeToDate < ActiveRecord::Migration[5.2]
  def change
    change_column :personal_details, :date_of_birth, :date
  end
end
