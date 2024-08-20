class AllowNilApplicationFormIdForWorkBreaks < ActiveRecord::Migration[7.1]
  def change
    change_column_null :application_work_history_breaks, :application_form_id, true
  end
end
