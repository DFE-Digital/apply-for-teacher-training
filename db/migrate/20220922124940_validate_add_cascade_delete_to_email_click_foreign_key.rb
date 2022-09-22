class ValidateAddCascadeDeleteToEmailClickForeignKey < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :email_clicks, :emails
  end
end
