class RemoveDefaultAndNotNullConstraintsFromConfidential < ActiveRecord::Migration[8.0]
  def change
    change_column_null :references, :confidential, true
    change_column_default :references, :confidential, from: true, to: nil
  end
end
