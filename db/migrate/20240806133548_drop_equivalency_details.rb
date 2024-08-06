class DropEquivalencyDetails < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :application_qualifications, :equivalency_details, :string, if_exists: true
    end
  end
end
