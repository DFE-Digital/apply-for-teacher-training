class CreatePersonalDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :personal_details do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :preferred_name
      t.datetime :date_of_birth
      t.string :nationality
      t.timestamps
    end
  end
end
