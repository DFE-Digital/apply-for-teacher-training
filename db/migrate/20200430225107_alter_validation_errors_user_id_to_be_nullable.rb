class AlterValidationErrorsUserIdToBeNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :validation_errors, :user_id, true
    change_column_null :validation_errors, :user_type, true
  end
end
