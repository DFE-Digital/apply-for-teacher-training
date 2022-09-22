class AddCascadeDeleteToEmailClickForeignKey < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :email_clicks, :emails
    add_foreign_key :email_clicks, :emails, on_delete: :cascade, validate: false
  end
end
