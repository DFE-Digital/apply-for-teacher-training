class SetExperienceableColumnNotNul < ActiveRecord::Migration[7.1]
  def up
    add_check_constraint :application_experiences, 'experienceable_id IS NOT NULL', name: 'application_experiences_experienceable_id_null', validate: false
    add_check_constraint :application_experiences, 'experienceable_type IS NOT NULL', name: 'application_experiences_experienceable_type_null', validate: false
  end

  def down
    # Do nothing, the constraint should not be present
  end
end
