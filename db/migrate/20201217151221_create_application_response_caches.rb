class CreateApplicationResponseCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :application_response_caches do |t|
      t.references :application_choice, null: false, foreign_key: { on_delete: :cascade }
      t.jsonb :response_body

      t.timestamps
    end
  end
end
