class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string :course_code
      t.string :provider_code
      t.string :accredited_body_code

      t.timestamps
    end
  end
end
