class RemoveDateOfBirthFromPersonalDetails < ActiveRecord::Migration[5.2]
  def change
    remove_column :personal_details, :date_of_birth, :datetime
  end
end
