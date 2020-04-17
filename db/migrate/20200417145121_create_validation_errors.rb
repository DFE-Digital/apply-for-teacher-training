class CreateValidationErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :validation_errors do |t|
      t.string :form_object, null: false
      t.integer :user_id, null: false
      t.string :user_type, null: false
      t.string :request_path, null: false
      t.jsonb :details

      t.timestamps
    end

    add_index :validation_errors, :form_object
  end
end
