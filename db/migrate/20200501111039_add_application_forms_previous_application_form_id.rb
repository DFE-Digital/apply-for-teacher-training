class AddApplicationFormsPreviousApplicationFormId < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :previous_application_form_id, :integer
    add_foreign_key :application_forms, :application_forms, column: :previous_application_form_id
  end
end
