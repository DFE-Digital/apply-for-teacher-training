class CreateEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :emails do |t|
      t.string :to, null: false
      t.string :subject, null: false
      t.string :mailer, null: false
      t.string :mail_template, null: false
      t.text :body, null: false
      t.string :notify_reference
      t.references :application_form, null: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
