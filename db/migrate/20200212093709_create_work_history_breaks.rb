class CreateWorkHistoryBreaks < ActiveRecord::Migration[6.0]
  def change
    create_table :work_history_breaks do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }

      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.text :reason, null: false

      t.timestamps
    end
  end
end
