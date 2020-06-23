class ChangeIndexOnCourseUniqueness < ActiveRecord::Migration[6.0]
  def change
    remove_index :courses, %i[provider_id code]
    add_index :courses, %i[recruitment_cycle_year provider_id code], unique: true, name: 'index_courses_on_cycle_provider_and_code'
  end
end
