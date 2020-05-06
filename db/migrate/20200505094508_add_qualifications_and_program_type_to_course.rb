class AddQualificationsAndProgramTypeToCourse < ActiveRecord::Migration[6.0]
  def change
    change_table :courses, bulk: true do |t|
      t.jsonb :qualifications, null: true
      t.string :program_type, null: true
    end
  end
end
