class CreateEmailClicks < ActiveRecord::Migration[7.0]
  def change
    create_table :email_clicks do |t|
      t.references :email, null: false, foreign_key: true
      t.string :path, null: false
      t.timestamps
    end
  end
end
