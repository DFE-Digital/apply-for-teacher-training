class CreateUCASMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :ucas_matches do |t|
      t.references :candidate, null: false, foreign_key: true
      t.json :matching_data
      t.string :matching_state

      t.timestamps
    end
  end
end
