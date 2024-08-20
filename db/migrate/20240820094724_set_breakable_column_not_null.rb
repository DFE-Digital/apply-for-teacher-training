class SetBreakableColumnNotNull < ActiveRecord::Migration[7.1]
  def up
    add_check_constraint :application_work_history_breaks, 'breakable_id IS NOT NULL', name: 'application_work_history_breaks_breakable_id_null', validate: false
    add_check_constraint :application_work_history_breaks, 'breakable_type IS NOT NULL', name: 'application_work_history_breaks_breakable_type_null', validate: false
  end

  def down
    # Do nothing, the constraint should not be present
  end
end
