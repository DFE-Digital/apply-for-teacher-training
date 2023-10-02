class DropUniqueIndexOnApplicationChoiceFormAndCourse < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    remove_index :application_choices, %w[application_form_id course_option_id], name: 'index_course_option_to_application_form_id', algorithm: :concurrently, if_exists: true
  end

  def down
    add_index :application_choices, %w[application_form_id course_option_id], name: 'index_course_option_to_application_form_id', algorithm: :concurrently, unique: true
  end
end
