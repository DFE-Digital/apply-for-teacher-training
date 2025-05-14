class AddDeleteOnCascadeToApplicationFormForeignKey < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :adviser_sign_up_requests, :application_forms

    add_foreign_key :adviser_sign_up_requests, :application_forms, on_delete: :cascade, null: false, validate: false
  end
end
