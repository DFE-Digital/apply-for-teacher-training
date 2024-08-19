class DropApplicationFormIdFromApplicationExperience < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_reference :application_experiences, :application_form, foreign_key: true, index: false, if_exists: true
    end
  end
end
