class RemoveOfferedCourseOptionIdFromApplicationChoices < ActiveRecord::Migration[6.1]
  def up
    raise 'nil current_course_option_id values' \
      unless ApplicationChoice.where(current_course_option_id: nil).count.zero?

    safety_assured { remove_column :application_choices, :offered_course_option_id }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
