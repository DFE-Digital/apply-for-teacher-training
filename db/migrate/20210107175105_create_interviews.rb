class CreateInterviews < ActiveRecord::Migration[6.0]
  def change
    create_table :interviews do |t|
      t.references :application_choice, null: false, foreign_key: { on_delete: :cascade }
      t.references :provider, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :date_and_time
      t.text :location
      t.text :additional_details

      t.timestamps
    end
  end
end
