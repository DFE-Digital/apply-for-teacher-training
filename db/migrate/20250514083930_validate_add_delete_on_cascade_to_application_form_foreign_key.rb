class ValidateAddDeleteOnCascadeToApplicationFormForeignKey < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :adviser_sign_up_requests, :application_forms
  end
end
