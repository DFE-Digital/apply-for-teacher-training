class AddCourseSubjectCodesAndFundingType < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :subject_codes, :jsonb, null: true
    add_column :courses, :funding_type, :string, null: true
  end
end
