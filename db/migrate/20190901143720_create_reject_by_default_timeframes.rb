class CreateRejectByDefaultTimeframes < ActiveRecord::Migration[5.2]
  def change
    create_table :reject_by_default_timeframes do |t|
      t.datetime :from_date, null: false
      t.datetime :to_date, null: false
      t.integer :number_of_working_days_until_rejection, null: false
      t.timestamps
    end
  end
end
