class DontAllowNullForStatus < ActiveRecord::Migration[6.0]
  def change
    change_column_null :application_choices, :status, false, 'unsubmitted'
  end
end
