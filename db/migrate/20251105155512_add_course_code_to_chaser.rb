class AddCourseCodeToChaser < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference(
      :chasers_sent,
      :course_id,
      null: true,
      index: { algorithm: :concurrently },
    )
  end
end
