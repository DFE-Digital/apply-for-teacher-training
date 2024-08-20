class ValidateApplicationWorkHistoryBreakBreakableColumns < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    validate_check_constraint :application_work_history_breaks, name: 'application_work_history_breaks_breakable_id_null'
    change_column_null :application_work_history_breaks, :breakable_id, false
    remove_check_constraint :application_work_history_breaks, name: 'application_work_history_breaks_breakable_id_null'

    validate_check_constraint :application_work_history_breaks, name: 'application_work_history_breaks_breakable_type_null'
    change_column_null :application_work_history_breaks, :breakable_type, false
    remove_check_constraint :application_work_history_breaks, name: 'application_work_history_breaks_breakable_type_null'
  end

  def down
    change_column_null :application_work_history_breaks, :breakable_id, true
    change_column_null :application_work_history_breaks, :breakable_type, true
  end
end
