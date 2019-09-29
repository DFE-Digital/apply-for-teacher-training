class CreateApplicationStages < ActiveRecord::Migration[6.0]
  def change
    create_table :application_stages do |t|
      t.integer 'simultaneous_applications_limit', null: false
      t.datetime 'from_time', null: false
      t.datetime 'to_time', null: false
      t.string 'type'
      t.timestamps
    end
  end
end
