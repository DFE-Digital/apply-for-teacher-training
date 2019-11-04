class CreateReferences < ActiveRecord::Migration[6.0]
  def change
    create_table :references do |t|
      t.string 'email_address', null: false
      t.string 'feedback'

      t.references :application_form, null: false, foreign_key: true

      t.timestamps
    end

    add_index :references, %i[application_form_id email_address], unique: true
  end
end
