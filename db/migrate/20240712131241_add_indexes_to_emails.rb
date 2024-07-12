class AddIndexesToEmails < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    add_index :emails, :mailer, algorithm: :concurrently
    add_index :emails, :mail_template, algorithm: :concurrently
  end
end
