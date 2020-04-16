class AddCourseSubjectCodesAndFundingType < ActiveRecord::Migration[6.0]
  def change
    change_table :courses, bulk: true do |t|
      t.jsonb :subject_codes, null: true
      t.string :funding_type, null: true
    end
  end
end
